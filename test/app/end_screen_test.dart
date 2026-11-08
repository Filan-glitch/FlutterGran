import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/providers.dart';
import 'package:fluttergran/app/screens/game_screen.dart';
import 'package:fluttergran/data/board/fake_board_source.dart';
import 'package:fluttergran/data/db/database.dart';
import 'package:fluttergran/data/db/game_repository.dart';
import 'package:fluttergran/domain/x01/leg_state.dart';
import 'package:fluttergran/domain/x01/match_state.dart';

import '../support/darts.dart';
import '../support/database.dart';
import '../support/pump.dart';
import '../support/sound.dart';

void main() {
  late AppDatabase database;
  late GameRepository repository;
  late FakeBoardSource board;
  late ProviderContainer container;

  setUp(() {
    database = memoryDatabase();
    repository = GameRepository(database);
    board = FakeBoardSource();
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
        boardSourceProvider.overrideWithValue(board),
        soundPlayerProvider.overrideWithValue(MuteSoundPlayer()),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await board.dispose();
    await database.close();
  });

  /// Seats two players and puts the first leg of a [legsToPlay] match on
  /// screen, on a score that checks out with one dart.
  Future<MatchConfig> open(WidgetTester tester, {int legsToPlay = 3}) async {
    final finn = await repository.addPlayer('Finn');
    final ada = await repository.addPlayer('Ada');
    final config = MatchConfig(
      startScore: 40,
      playerIds: [finn.id, ada.id],
      legsToPlay: legsToPlay,
    );

    await container.read(matchProvider.notifier).start(config);
    await pumpApp(tester, const GameScreen(), container: container);
    await pumpFrames(tester, count: 12);
    return config;
  }

  /// Wins the leg on screen with a single double, as the player at the oche.
  Future<void> checkout(WidgetTester tester) async {
    container.read(gameProvider.notifier).addDart(d(20));
    await pumpFrames(tester, count: 12);
    // The turn is held for confirmation, exactly as it is during play.
    if (container.read(gameProvider).awaitingTurnConfirm) {
      container.read(gameProvider.notifier).confirmTurn();
      await pumpFrames(tester, count: 12);
    }
  }

  /// What the figures block says, ignoring the scoreboard behind it - which
  /// shows the same numbers for the leg that has just ended.
  Finder inFigures(String text) => find.descendant(
    of: find.byKey(matchFiguresKey),
    matching: find.text(text),
  );

  testWidgets('a leg won mid-match offers the next one', (tester) async {
    await open(tester);
    await checkout(tester);

    expect(find.text('LEG WON'), findsOneWidget);
    // Twice over: the scoreboard column above, and the winner below it.
    expect(find.text('FINN'), findsNWidgets(2));
    expect(find.text('THROW LEG 2'), findsOneWidget);

    // One leg up in a best of three, so the match is not called yet.
    expect(find.text('MATCH WON'), findsNothing);
    expect(find.text('1 – 0 · 1 LEG TO WIN IT'), findsOneWidget);
  });

  testWidgets('throwing the next leg puts the board back', (tester) async {
    await open(tester);
    await checkout(tester);

    await tester.tap(find.text('THROW LEG 2'));
    await pumpFrames(tester, count: 12);

    expect(find.text('LEG WON'), findsNothing);
    expect(find.text('THROW LEG 2'), findsNothing);

    // A fresh leg on the full score, with the throw rotated to the second seat.
    expect(container.read(gameProvider).leg.config.startingSeat, 1);
    expect(find.text('40'), findsWidgets);
  });

  testWidgets('winning the match shows both players and the way out', (
    tester,
  ) async {
    await open(tester, legsToPlay: 1);
    await checkout(tester);

    expect(find.text('MATCH WON'), findsOneWidget);
    expect(find.text('REMATCH'), findsOneWidget);
    expect(find.text('BACK TO SETUP'), findsOneWidget);

    // Both players' figures, not just the winner's.
    expect(find.text('AVERAGE'), findsNWidgets(2));
    expect(find.text('FIRST NINE'), findsNWidgets(2));
    expect(find.text('BEST OUT'), findsNWidgets(2));

    // 40 checked out in one dart, from the winner's column only.
    expect(find.text('40'), findsWidgets);
    expect(find.text('1'), findsWidgets);
  });

  testWidgets('the figures wait for the legs they are computed from', (
    tester,
  ) async {
    // Held open, so the card is caught in the state it mounts in.
    final held = Completer<List<LegState>>();
    container.dispose();
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
        boardSourceProvider.overrideWithValue(board),
        soundPlayerProvider.overrideWithValue(MuteSoundPlayer()),
        decidedMatchLegsProvider.overrideWith((ref) => held.future),
      ],
    );

    await open(tester, legsToPlay: 1);
    await checkout(tester);

    expect(find.text('MATCH WON'), findsOneWidget);
    // Ten rows, every one of them empty: a figure computed from the final leg
    // alone is not a match figure, and would read exactly like one.
    expect(find.text('AVERAGE'), findsNWidgets(2));
    expect(inFigures('—'), findsNWidgets(10));

    held.complete(const []);
    await pumpFrames(tester, count: 12);

    expect(inFigures('120.0'), findsWidgets, reason: '40 in one dart');
  });

  testWidgets('legs that cannot be read are said to be missing', (
    tester,
  ) async {
    container.dispose();
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
        boardSourceProvider.overrideWithValue(board),
        soundPlayerProvider.overrideWithValue(MuteSoundPlayer()),
        decidedMatchLegsProvider.overrideWith(
          (ref) => Future<List<LegState>>.error(Exception('no database')),
        ),
      ],
    );

    await open(tester, legsToPlay: 1);
    await checkout(tester);

    expect(find.text('THE EARLIER LEGS COULD NOT BE READ'), findsOneWidget);
    expect(
      inFigures('—'),
      findsNWidgets(10),
      reason: 'the final leg on its own is not the match',
    );

    // The match itself is not in doubt - it was folded from the darts, not
    // read back - so the winner and the way out are still there.
    expect(find.text('MATCH WON'), findsOneWidget);
    expect(find.text('REMATCH'), findsOneWidget);

    // Torn down inside the test rather than at teardown: a failed provider is
    // disposed with the tree, and the timers that cancel its subscription need
    // frames to fire in or they are reported as still pending.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('undoing the winning dart takes the match back', (tester) async {
    await open(tester, legsToPlay: 1);
    await checkout(tester);
    expect(find.text('MATCH WON'), findsOneWidget);

    container.read(gameProvider.notifier).undo();
    await pumpFrames(tester, count: 12);

    // Nothing had to be retracted: the tally is folded from the darts, so
    // removing the dart removes the match.
    expect(find.text('MATCH WON'), findsNothing);
    expect(find.text('LEG WON'), findsNothing);
    expect(container.read(matchStateProvider)!.isFinished, isFalse);
  });

  testWidgets('a rematch starts a fresh match on the same format', (
    tester,
  ) async {
    final config = await open(tester, legsToPlay: 1);
    await checkout(tester);

    final decided = container.read(matchProvider)!.matchId;

    await tester.tap(find.text('REMATCH'));
    await pumpFrames(tester, count: 12);

    expect(find.text('MATCH WON'), findsNothing);

    final session = container.read(matchProvider)!;
    expect(session.matchId, isNot(decided), reason: 'a new match, not a leg');
    expect(session.config.legsToPlay, config.legsToPlay);
    expect(session.config.playerIds, config.playerIds);
    expect(session.decidedLegs, isEmpty);
    expect(container.read(gameProvider).leg.darts, isEmpty);
  });
}
