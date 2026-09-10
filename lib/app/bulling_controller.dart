import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/game_repository.dart';
import '../domain/board_event.dart';
import '../domain/bulling/bulling_config.dart';
import '../domain/bulling/bulling_leg_state.dart';
import '../domain/bulling/bulling_reducer.dart';
import '../domain/x01/thrown_dart.dart';
import 'providers.dart';

/// The leg, plus the one piece of state the rules do not care about:
/// whether the player has acknowledged the turn that just ended.
///
/// Mirrors x01's `GameSession` and Around the Clock's `AtcSession` exactly —
/// see either type's own doc.
class BullingSession {
  const BullingSession({required this.leg, required this.acknowledgedTurns});

  final BullingLegState leg;

  final int acknowledgedTurns;

  bool get awaitingTurnConfirm => leg.turns.length > acknowledgedTurns;

  BullingTurn? get pendingTurn =>
      awaitingTurnConfirm ? leg.turns[acknowledgedTurns] : null;
}

/// Owns the dart log for a Bulling leg and turns board events into points.
///
/// Structured exactly like `AtcController` — every mutation goes through
/// [foldBulling], so the leg is always a pure function of the darts thrown,
/// and undo replays a shorter log rather than reversing anything. Like
/// Around the Clock, this mode has no match wrapping yet.
class BullingController extends Notifier<BullingSession> {
  bool _live = false;
  bool _manualOverrideOpen = false;

  @override
  BullingSession build() {
    final config = ref.watch(bullingConfigProvider);

    ref.listen(boardEventsProvider, (previous, next) {
      final event = next.value;
      if (event != null) handleBoardEvent(event);
    });

    _manualOverrideOpen = ref.read(keypadOverrideProvider);
    ref.listen(keypadOverrideProvider, (previous, next) {
      _manualOverrideOpen = next;
    });

    return BullingSession(
      leg: initialBullingLegState(config),
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
        confirmTurn();
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
  /// Callers must set [bullingConfigProvider] before calling this, the same
  /// requirement `AtcController.resume` documents.
  void resume(BullingConfig config, List<ThrownDart> darts) {
    _live = true;
    final leg = foldBulling(config, darts);
    state = BullingSession(leg: leg, acknowledgedTurns: leg.turns.length);
  }
}
