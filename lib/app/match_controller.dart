import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/x01/game_config.dart';
import '../domain/x01/match_state.dart';
import 'providers.dart';

/// The match the leg on screen belongs to.
///
/// Holds only the legs that are already behind the current one. The leg being
/// played is deliberately not folded in here: it lives in [gameProvider], and
/// reading it from there is what makes undoing the checkout that won a leg put
/// the match tally back without anything having to be retracted.
class MatchSession {
  const MatchSession({
    required this.matchId,
    required this.config,
    required this.decidedLegs,
  });

  final int matchId;
  final MatchConfig config;

  /// Winner of each leg finished before the one on screen, oldest first.
  final List<int> decidedLegs;
}

/// Starts matches, and moves them on a leg at a time.
///
/// Nothing about the match is counted incrementally: [matchStateProvider] folds
/// [MatchSession.decidedLegs] plus whatever the current leg has done, so the
/// tally is a pure function of the darts thrown, exactly like the leg itself.
class MatchController extends Notifier<MatchSession?> {
  /// Result last written to the match row, so a leg settling twice in a row
  /// does not write the same thing twice.
  int? _recordedWinner;

  @override
  MatchSession? build() => null;

  /// Opens a match and puts its first leg on screen.
  Future<void> start(MatchConfig config) async {
    final started = await ref.read(gameRepositoryProvider).startMatch(config);

    state = MatchSession(
      matchId: started.matchId,
      config: config,
      decidedLegs: const [],
    );
    _openLeg(config.legConfig(0), started.gameId);
  }

  /// Throws the next leg of the match.
  ///
  /// Does nothing when the leg on screen is unfinished or when it decided the
  /// match - the caller is the one that knows which of those it is showing.
  Future<void> startNextLeg() async {
    final session = state;
    final winner = ref.read(gameProvider).leg.winnerId;
    if (session == null || winner == null) return;

    final decided = [...session.decidedLegs, winner];
    final match = foldMatch(session.config, decided);
    final next = match.nextLegConfig;
    if (next == null) return;

    final gameId = await ref
        .read(gameRepositoryProvider)
        .startNextLeg(
          matchId: session.matchId,
          config: session.config,
          legNumber: match.nextLegNumber,
        );

    state = MatchSession(
      matchId: session.matchId,
      config: session.config,
      decidedLegs: decided,
    );
    _openLeg(next, gameId);
  }

  /// Restores the match a stored leg belongs to, or clears the session for a
  /// leg that was played outside one.
  Future<void> resumeFrom(int gameId) async {
    final repository = ref.read(gameRepositoryProvider);
    final game = await repository.loadGame(gameId);
    final matchId = game?.matchId;
    if (matchId == null) {
      state = null;
      return;
    }

    final config = await repository.loadMatchConfig(matchId);
    if (config == null) {
      state = null;
      return;
    }

    state = MatchSession(
      matchId: matchId,
      config: config,
      decidedLegs: await repository.legWinners(
        matchId,
        beforeLegNumber: game!.legNumber ?? 0,
      ),
    );
  }

  /// Records the match result the moment a leg settles it.
  ///
  /// Called with the leg's winner, or null when a checkout was undone. Writing
  /// on the way past means a decided match is never left looking open just
  /// because nobody pressed anything afterwards.
  void legSettled(int? legWinner) {
    final session = state;
    if (session == null) return;

    final match = foldMatch(session.config, [
      ...session.decidedLegs,
      ?legWinner,
    ]);
    if (match.winnerId == _recordedWinner) return;
    _recordedWinner = match.winnerId;

    final repository = ref.read(gameRepositoryProvider);
    unawaited(
      match.winnerId == null
          ? repository.reopenMatch(session.matchId)
          : repository.finishMatch(session.matchId, match.winnerId!),
    );
  }

  /// Plays the same format again, with the same players in the same seats.
  ///
  /// A new match rather than a continuation: the one just finished keeps its
  /// result, and the rematch starts on leg one with the throw back at the first
  /// seat. Asking for it from the setup screen would mean re-picking a roster
  /// that has not changed.
  Future<void> rematch() async {
    final session = state;
    if (session == null) return;

    // The old match's result is written and done with; the new one has not
    // been called yet, and must not be compared against it.
    _recordedWinner = null;
    await start(session.config);
  }

  /// Steps away from the match without ending it. The rows stay exactly as
  /// they are, and [resumeFrom] can pick the whole thing back up.
  void leave() {
    state = null;
    _recordedWinner = null;
  }

  /// Puts a leg in front of the player, persisted and live.
  ///
  /// The order matters: `GameController.build` watches the config and rebuilds
  /// to an empty leg when it changes, so the config has to be set before the
  /// controller is started.
  void _openLeg(GameConfig legConfig, int gameId) {
    ref.read(gameConfigProvider.notifier).update(legConfig);
    ref.read(currentGameIdProvider.notifier).set(gameId);
    ref.read(gameProvider.notifier).restart(legConfig);
  }
}
