import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/game_repository.dart';
import '../domain/board_event.dart';
import '../domain/x01/game_config.dart';
import '../domain/x01/leg_reducer.dart';
import '../domain/x01/leg_state.dart';
import '../domain/x01/thrown_dart.dart';
import 'providers.dart';

/// The leg, plus the one piece of state the rules do not care about: whether
/// the player has acknowledged the turn that just ended.
class GameSession {
  const GameSession({required this.leg, required this.acknowledgedTurns});

  final LegState leg;

  /// How many completed turns have been dismissed from the summary.
  final int acknowledgedTurns;

  /// Whether a turn has ended and its summary is still showing.
  bool get awaitingTurnConfirm => leg.turns.length > acknowledgedTurns;

  /// The turn being shown, or null when play is live.
  Turn? get pendingTurn =>
      awaitingTurnConfirm ? leg.turns[acknowledgedTurns] : null;
}

/// Owns the dart log and turns board events into scoring.
///
/// Every mutation goes through [foldLeg], so the leg is always a pure function
/// of the darts thrown. Undo does not reverse anything - it replays a shorter
/// log.
class GameController extends Notifier<GameSession> {
  /// Whether a leg is open in front of someone.
  ///
  /// Distinct from whether a game is being persisted: this is about whether
  /// anyone is looking. Board input is ignored when it is false, which is what
  /// stops a dart thrown at the board scoring into a leg the player already
  /// walked away from.
  bool _live = false;

  @override
  GameSession build() {
    final config = ref.watch(gameConfigProvider);

    ref.listen(boardEventsProvider, (previous, next) {
      final event = next.value;
      if (event != null) handleBoardEvent(event);
    });

    return GameSession(leg: initialLegState(config), acknowledgedTurns: 0);
  }

  void handleBoardEvent(BoardEvent event) {
    // Only the board path is gated. `addDart` is the manual entry path, driven
    // by a screen that by definition is open.
    if (!_live) return;

    switch (event) {
      case DartHit(:final segment):
        addDart(ThrownDart(segment));
      case BoardMiss():
        addDart(const ThrownDart.miss());
      case ButtonPress():
        // The board's only confirmed input, bound to the one action the game
        // can live without if the 132's touch sensor turns out to be silent.
        confirmTurn();
      case UnknownFrame():
        // Surfaced by the diagnostics screen, never scored.
        break;
    }
  }

  /// Records a dart. Ignored while a turn summary is showing, so a stray frame
  /// arriving as the player walks to the board cannot score for the next
  /// player.
  void addDart(ThrownDart dart) {
    if (state.leg.isFinished || state.awaitingTurnConfirm) return;

    final ordinal = state.leg.darts.length;
    final thrownBy = state.leg.currentPlayerId;

    final leg = foldLeg(state.leg.config, [...state.leg.darts, dart]);
    state = GameSession(
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
  ///
  /// Works across turn and player boundaries, and back out of a finished leg.
  void undo() {
    final darts = state.leg.darts;
    if (darts.isEmpty) return;

    final wasFinished = state.leg.isFinished;
    final leg = foldLeg(state.leg.config, darts.sublist(0, darts.length - 1));
    state = GameSession(
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

  /// Mirrors a change into the database, if a game is being persisted.
  ///
  /// Fire and forget: the in-memory log is the source of truth during play, and
  /// blocking a dart on disk would put storage latency in the way of scoring.
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
    state = GameSession(
      leg: state.leg,
      acknowledgedTurns: state.leg.turns.length,
    );
  }

  /// Starts a fresh leg under [config], or the current one if omitted.
  void restart([GameConfig? config]) {
    _live = true;
    state = GameSession(
      leg: initialLegState(config ?? state.leg.config),
      acknowledgedTurns: 0,
    );
  }

  /// Steps away from the leg without ending it.
  ///
  /// The leg stays in the database exactly as it was, unfinished and
  /// resumable. All this does is stop the board scoring into it.
  void leave() => _live = false;

  /// Picks a leg back up from its stored dart log.
  ///
  /// Callers must set [gameConfigProvider] before calling this: [build] watches
  /// it and rebuilds to an empty leg whenever it changes, which would discard
  /// whatever was just restored.
  void resume(GameConfig config, List<ThrownDart> darts) {
    _live = true;
    final leg = foldLeg(config, darts);
    state = GameSession(
      leg: leg,
      // Every completed turn counts as already acknowledged. Resuming must not
      // re-present the summary of a turn the player confirmed before leaving.
      acknowledgedTurns: leg.turns.length,
    );
  }
}
