/// [BullingController], which owns a Bulling leg's dart log, scores board and
/// keypad darts and stores each one.
///
/// {@category App}
library;

import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/game_repository.dart';
import '../domain/board_event.dart';
import '../domain/bulling/bulling_config.dart';
import '../domain/bulling/bulling_leg_state.dart';
import '../domain/bulling/bulling_reducer.dart';
import '../domain/x01/thrown_dart.dart';
import 'game_controller.dart' show GameController, GameSession;
import 'providers.dart';

/// A Bulling leg plus how many of its turns have been acknowledged - the
/// counterpart of x01's [GameSession].
class BullingSession {
  const BullingSession({required this.leg, required this.acknowledgedTurns});

  final BullingLegState leg;

  final int acknowledgedTurns;

  bool get awaitingTurnConfirm => leg.turns.length > acknowledgedTurns;

  BullingTurn? get pendingTurn =>
      awaitingTurnConfirm ? leg.turns[acknowledgedTurns] : null;
}

/// Owns the dart log for a Bulling leg, the way [GameController] does for
/// x01, folding it through [foldBulling].
///
/// The one difference: this mode has no matches, so no result is reported
/// to one.
class BullingController extends Notifier<BullingSession> {
  bool _live = false;
  bool _manualOverrideOpen = false;

  @override
  BullingSession build() {
    final config = ref.watch(bullingConfigProvider);

    final events = ref.watch(boardEventsProvider).listen(handleBoardEvent);
    ref.onDispose(events.cancel);

    _manualOverrideOpen = ref.read(keypadOverrideProvider);
    ref.listen(keypadOverrideProvider, (previous, next) {
      _manualOverrideOpen = next;
    });

    return BullingSession(
      leg: initialBullingLegState(config),
      acknowledgedTurns: 0,
    );
  }

  /// Applies one event from the board, gated as in
  /// [GameController.handleBoardEvent].
  void handleBoardEvent(BoardEvent event) {
    if (!_live) return;

    switch (event) {
      case DartHit(:final segment):
        if (_manualOverrideOpen) return;
        addDart(ThrownDart(segment));
      case BoardMiss():
        if (_manualOverrideOpen) return;
        addDart(const ThrownDart.miss());
      case ButtonPress():
        endTurn();
      case UnknownFrame():
        break;
    }
  }

  /// Records a dart. Ignored while a turn summary is showing, so a stray
  /// frame arriving as the player walks to the board cannot score for the
  /// next player.
  void addDart(ThrownDart dart) {
    if (state.leg.isFinished || state.awaitingTurnConfirm) return;

    final ordinal = state.leg.darts.length;
    final thrownBy = state.leg.currentPlayerId;

    final leg = foldBulling(state.leg.config, [...state.leg.darts, dart]);
    state = BullingSession(
      leg: leg,
      acknowledgedTurns: state.acknowledgedTurns,
    );

    _persist((repository, gameId) async {
      await repository.appendDart(
        gameId: gameId,
        ordinal: ordinal,
        playerId: thrownBy,
        dart: dart,
      );
      if (leg.winnerId case final winner?) {
        await repository.finishGame(gameId, winner);
      }
    });
  }

  /// Drops the last dart thrown and replays the leg without it.
  void undo() {
    final darts = state.leg.darts;
    if (darts.isEmpty) return;

    final wasFinished = state.leg.isFinished;
    final leg = foldBulling(
      state.leg.config,
      darts.sublist(0, darts.length - 1),
    );
    state = BullingSession(
      leg: leg,
      acknowledgedTurns: min(state.acknowledgedTurns, leg.turns.length),
    );

    _persist((repository, gameId) async {
      await repository.truncateLog(gameId, leg.darts.length);
      if (wasFinished && !leg.isFinished) {
        await repository.reopenGame(gameId);
      }
    });
  }

  void _persist(
    Future<void> Function(GameRepository repository, int gameId) write,
  ) {
    final gameId = ref.read(currentGameIdProvider);
    if (gameId == null) return;
    unawaited(write(ref.read(gameRepositoryProvider), gameId));
  }

  /// Dismisses the turn summary and hands over.
  void confirmTurn() {
    if (!state.awaitingTurnConfirm) return;
    state = BullingSession(
      leg: state.leg,
      acknowledgedTurns: state.leg.turns.length,
    );
  }

  /// Ends the turn now and hands over: every dart not thrown is a miss, as
  /// in [GameController.endTurn]. A miss never finishes this leg either, so
  /// the last one always closes the turn.
  void endTurn() {
    if (state.leg.isFinished) return;
    if (!state.awaitingTurnConfirm) {
      for (var left = state.leg.dartsLeftThisTurn; left > 0; left--) {
        addDart(const ThrownDart.miss());
      }
    }
    confirmTurn();
  }

  /// Starts a fresh leg under [config], or the current one if omitted.
  void restart([BullingConfig? config]) {
    _live = true;
    state = BullingSession(
      leg: initialBullingLegState(config ?? state.leg.config),
      acknowledgedTurns: 0,
    );
  }

  /// Steps away from the leg without ending it.
  void leave() => _live = false;

  /// Picks a leg back up from its stored dart log.
  ///
  /// Callers must set [bullingConfigProvider] first - see
  /// [GameController.resume].
  void resume(BullingConfig config, List<ThrownDart> darts) {
    _live = true;
    final leg = foldBulling(config, darts);
    state = BullingSession(leg: leg, acknowledgedTurns: leg.turns.length);
  }
}
