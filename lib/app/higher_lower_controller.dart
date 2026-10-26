import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/game_repository.dart';
import '../domain/board_event.dart';
import '../domain/higher_lower/higher_lower_config.dart';
import '../domain/higher_lower/higher_lower_leg_state.dart';
import '../domain/higher_lower/higher_lower_reducer.dart';
import '../domain/x01/thrown_dart.dart';
import 'providers.dart';

/// The leg, plus the one piece of state the rules do not care about:
/// whether the player has acknowledged the turn that just ended.
///
/// Mirrors Bulling's `BullingSession` exactly - see x01's `GameSession` for
/// why acknowledgement lives here rather than in the leg.
class HigherLowerSession {
  const HigherLowerSession({
    required this.leg,
    required this.acknowledgedTurns,
  });

  final HigherLowerLegState leg;

  final int acknowledgedTurns;

  bool get awaitingTurnConfirm => leg.turns.length > acknowledgedTurns;

  HigherLowerTurn? get pendingTurn =>
      awaitingTurnConfirm ? leg.turns[acknowledgedTurns] : null;
}

/// Owns the dart log for a Higher/Lower leg and turns board events into
/// turns.
///
/// Structured exactly like `BullingController` - every mutation goes
/// through [foldHigherLower], so the leg is always a pure function of the
/// darts thrown, and undo replays a shorter log rather than reversing
/// anything, eliminations included.
class HigherLowerController extends Notifier<HigherLowerSession> {
  bool _live = false;
  bool _manualOverrideOpen = false;

  @override
  HigherLowerSession build() {
    final config = ref.watch(higherLowerConfigProvider);

    final events = ref.watch(boardEventsProvider).listen(handleBoardEvent);
    ref.onDispose(events.cancel);

    _manualOverrideOpen = ref.read(keypadOverrideProvider);
    ref.listen(keypadOverrideProvider, (previous, next) {
      _manualOverrideOpen = next;
    });

    return HigherLowerSession(
      leg: initialHigherLowerLegState(config),
      acknowledgedTurns: 0,
    );
  }

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
  /// frame arriving as the player walks to the board cannot count for the
  /// next player.
  void addDart(ThrownDart dart) {
    if (state.leg.isFinished || state.awaitingTurnConfirm) return;

    final ordinal = state.leg.darts.length;
    final thrownBy = state.leg.currentPlayerId;

    final leg = foldHigherLower(state.leg.config, [...state.leg.darts, dart]);
    state = HigherLowerSession(
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
    final leg = foldHigherLower(
      state.leg.config,
      darts.sublist(0, darts.length - 1),
    );
    state = HigherLowerSession(
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
    state = HigherLowerSession(
      leg: state.leg,
      acknowledgedTurns: state.leg.turns.length,
    );
  }

  /// Ends the turn now and hands over: the next dart not thrown is a miss.
  ///
  /// The board button's job, the same as `GameController.endTurn`. In this
  /// mode a miss ends the turn on its own and puts the player out, so one is
  /// all it takes.
  void endTurn() {
    if (state.leg.isFinished) return;
    if (!state.awaitingTurnConfirm) addDart(const ThrownDart.miss());
    confirmTurn();
  }

  /// Starts a fresh leg under [config], or the current one if omitted.
  void restart([HigherLowerConfig? config]) {
    _live = true;
    state = HigherLowerSession(
      leg: initialHigherLowerLegState(config ?? state.leg.config),
      acknowledgedTurns: 0,
    );
  }

  /// Steps away from the leg without ending it.
  void leave() => _live = false;

  /// Picks a leg back up from its stored dart log.
  ///
  /// Callers must set [higherLowerConfigProvider] before calling this, the
  /// same requirement `BullingController.resume` documents.
  void resume(HigherLowerConfig config, List<ThrownDart> darts) {
    _live = true;
    final leg = foldHigherLower(config, darts);
    state = HigherLowerSession(leg: leg, acknowledgedTurns: leg.turns.length);
  }
}
