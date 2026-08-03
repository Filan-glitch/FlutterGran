import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/audio/sound_controller.dart';
import 'package:fluttergran/app/providers.dart';
import 'package:fluttergran/app/screens/game_screen.dart';
import 'package:fluttergran/app/theme.dart';
import 'package:fluttergran/data/board/fake_board_source.dart';
import 'package:fluttergran/data/db/database.dart';
import 'package:fluttergran/data/db/game_repository.dart';
import 'package:fluttergran/domain/segment.dart';
import 'package:fluttergran/domain/x01/match_state.dart';
import 'package:fluttergran/domain/x01/thrown_dart.dart';

/// Silent, so the end of a leg does not go looking for an audio plugin.
class _MutePlayer implements SoundPlayer {
  @override
  void playCue(String asset) {}

  @override
  void playSpeech(String asset, {Duration after = Duration.zero}) {}

  @override
  void silence() {}

  @override
  Future<void> dispose() async {}
}

void main() {
  late AppDatabase database;
  late GameRepository repository;
  late FakeBoardSource board;
  late ProviderContainer container;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = GameRepository(database);
    board = FakeBoardSource();
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
        boardSourceProvider.overrideWithValue(board),
        soundPlayerProvider.overrideWithValue(_MutePlayer()),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await board.dispose();
    await database.close();
  });

  ThrownDart d(int n) => ThrownDart(Segment(n, Ring.doubleRing));

  /// Pumps frames without settling: the roster query and the database writes
  /// both land a frame or two after the tap that caused them.
  Future<void> frames(WidgetTester tester) async {
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
  }

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
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: buildTheme(), home: const GameScreen()),
      ),
    );
    await frames(tester);
    return config;
  }

  /// Wins the leg on screen with a single double, as the player at the oche.
  Future<void> checkout(WidgetTester tester) async {
    container.read(gameProvider.notifier).addDart(d(20));
    await frames(tester);
    // The turn is held for confirmation, exactly as it is during play.
    if (container.read(gameProvider).awaitingTurnConfirm) {
      container.read(gameProvider.notifier).confirmTurn();
      await frames(tester);
    }
  }

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
    await frames(tester);

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

  testWidgets('undoing the winning dart takes the match back', (tester) async {
    await open(tester, legsToPlay: 1);
    await checkout(tester);
    expect(find.text('MATCH WON'), findsOneWidget);

    container.read(gameProvider.notifier).undo();
    await frames(tester);

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
    await frames(tester);

    expect(find.text('MATCH WON'), findsNothing);

    final session = container.read(matchProvider)!;
    expect(session.matchId, isNot(decided), reason: 'a new match, not a leg');
    expect(session.config.legsToPlay, config.legsToPlay);
    expect(session.config.playerIds, config.playerIds);
    expect(session.decidedLegs, isEmpty);
    expect(container.read(gameProvider).leg.darts, isEmpty);
  });
}
