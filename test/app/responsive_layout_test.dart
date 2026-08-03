import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/audio/sound_controller.dart';
import 'package:fluttergran/app/providers.dart';
import 'package:fluttergran/app/screens/game_screen.dart';
import 'package:fluttergran/app/theme.dart';
import 'package:fluttergran/app/widgets/dart_keypad.dart';
import 'package:fluttergran/data/board/fake_board_source.dart';
import 'package:fluttergran/data/db/database.dart';
import 'package:fluttergran/data/db/game_repository.dart';
import 'package:fluttergran/domain/segment.dart';
import 'package:fluttergran/domain/x01/match_state.dart';
import 'package:fluttergran/domain/x01/thrown_dart.dart';

/// The three shapes the app is laid out for, in logical pixels.
const phonePortrait = Size(411, 923); // Pixel 9a
const phoneLandscape = Size(923, 411); // the same phone, turned
const tablet = Size(834, 1194); // a 10-inch tablet, upright

/// Silent, so nothing goes looking for an audio plugin.
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

  ThrownDart t(int n) => ThrownDart(Segment(n, Ring.triple));

  Future<void> frames(WidgetTester tester) async {
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
  }

  /// Puts a leg on screen in a viewport of exactly [size], the way the device
  /// would - the app's own scaling included, since that is part of the layout.
  Future<void> openAt(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final finn = await repository.addPlayer('Finn');
    final ada = await repository.addPlayer('Ada');
    await container
        .read(matchProvider.notifier)
        .start(MatchConfig(startScore: 501, playerIds: [finn.id, ada.id]));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildTheme(),
          builder: (context, child) {
            final media = MediaQuery.of(context);
            return MediaQuery(
              data: media.copyWith(
                textScaler: TextScaler.linear(typeScaleFor(media.size)),
              ),
              child: child!,
            );
          },
          home: const GameScreen(),
        ),
      ),
    );
    await frames(tester);
  }

  /// Where a widget sits, for asking whether two things are side by side.
  Rect where(WidgetTester tester, Finder finder) => tester.getRect(finder);

  group('the leg fits the screen it is played on', () {
    for (final (name, size) in const [
      ('a phone held upright', phonePortrait),
      ('a phone on its side', phoneLandscape),
      ('a tablet', tablet),
    ]) {
      testWidgets('nothing overflows on $name', (tester) async {
        await openAt(tester, size);

        // An overflow is reported as an exception against the frame, which is
        // what the yellow stripes are drawn from.
        expect(tester.takeException(), isNull);

        // Every key is reachable, not just painted.
        expect(find.byType(DartKeypad), findsOneWidget);
        expect(find.text('20'), findsOneWidget);
        expect(find.text('BULL'), findsOneWidget);
        expect(find.text('MISS'), findsOneWidget);
      });
    }
  });

  group('the arrangement follows the width', () {
    testWidgets('a phone upright stacks the keypad under the score', (
      tester,
    ) async {
      await openAt(tester, phonePortrait);

      final score = where(tester, find.text('501').first);
      final keypad = where(tester, find.byType(DartKeypad));

      expect(
        keypad.top,
        greaterThan(score.bottom),
        reason: 'below, not beside',
      );
    });

    for (final (name, size) in const [
      ('a phone on its side', phoneLandscape),
      ('a tablet', tablet),
    ]) {
      testWidgets('$name puts the keypad beside the score', (tester) async {
        await openAt(tester, size);

        final score = where(tester, find.text('501').first);
        final keypad = where(tester, find.byType(DartKeypad));

        expect(keypad.left, greaterThan(score.left));
        expect(
          keypad.top,
          lessThan(score.bottom),
          reason: 'side by side, sharing the height',
        );
      });
    }
  });

  group('type grows with the device', () {
    test('a phone is the size the styles are written at', () {
      expect(typeScaleFor(phonePortrait), 1);
      expect(typeScaleFor(phoneLandscape), 1);
    });

    test('a tablet is read from further away', () {
      expect(typeScaleFor(tablet), greaterThan(1));
      expect(
        typeScaleFor(const Size(1024, 1366)),
        greaterThan(typeScaleFor(tablet)),
      );
    });

    testWidgets('the score is drawn bigger on a tablet', (tester) async {
      await openAt(tester, phonePortrait);
      final onPhone = tester.getSize(find.text('501').first);

      await tester.pumpWidget(const SizedBox.shrink());
      await openAt(tester, tablet);
      final onTablet = tester.getSize(find.text('501').first);

      expect(onTablet.height, greaterThan(onPhone.height));
    });
  });

  group('a held turn survives a short viewport', () {
    testWidgets('the confirmation fits a phone on its side', (tester) async {
      await openAt(tester, phoneLandscape);

      final controller = container.read(gameProvider.notifier);
      for (var i = 0; i < 3; i++) {
        controller.addDart(t(20));
      }
      await frames(tester);

      expect(tester.takeException(), isNull);
      expect(find.text('180'), findsWidgets);
      expect(find.text('NEXT PLAYER'), findsOneWidget);
    });
  });
}
