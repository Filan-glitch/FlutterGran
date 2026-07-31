import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/providers.dart';
import 'package:fluttergran/data/board/fake_board_source.dart';
import 'package:fluttergran/data/db/database.dart';
import 'package:fluttergran/data/db/game_repository.dart';
import 'package:fluttergran/domain/board_event.dart';
import 'package:fluttergran/domain/segment.dart';

/// Longer than the assembler's 50 ms dedupe window, so a test that emits the
/// same body twice gets two events rather than one.
Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 60));

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
      ],
    );
    // Stands in for the diagnostics screen keeping the sync alive.
    container.listen(calibrationSyncProvider, (_, _) {});
  });

  tearDown(() async {
    container.dispose();
    await board.dispose();
    await database.close();
  });

  test('the shipped table decodes an uncalibrated board', () async {
    final events = <BoardEvent>[];
    container.read(boardReaderProvider).events.listen(events.add);

    board.emitBody('3.4');
    await settle();

    expect(
      events.single,
      isA<DartHit>().having(
        (e) => e.segment,
        'segment',
        const Segment(20, Ring.triple),
      ),
    );
  });

  test('a correction changes what the next dart decodes to', () async {
    final events = <BoardEvent>[];
    container.read(boardReaderProvider).events.listen(events.add);

    // The board turns out to send 3.4 for something other than the triple 20.
    await repository.recordCalibration(
      body: '3.4',
      segment: const Segment(19, Ring.doubleRing),
      corrected: true,
    );
    await settle();

    board.emitBody('3.4');
    await settle();

    expect(
      events.single,
      isA<DartHit>().having(
        (e) => e.segment,
        'segment',
        const Segment(19, Ring.doubleRing),
      ),
      reason: 'the correction must reach the live decoder, not a rebuilt one',
    );
  });

  test('a code the shipped table has never seen can be taught', () async {
    final events = <BoardEvent>[];
    container.read(boardReaderProvider).events.listen(events.add);

    // 4.1 is an empty matrix slot in the shipped table.
    board.emitBody('4.1');
    await settle();
    expect(events.single, isA<UnknownFrame>());

    await repository.recordCalibration(
      body: '4.1',
      segment: const Segment(20, Ring.triple),
      corrected: true,
    );
    await settle();

    board.emitBody('4.1');
    await settle();
    expect(events.last, isA<DartHit>());
  });

  test('confirming a code does not override anything', () async {
    final events = <BoardEvent>[];
    container.read(boardReaderProvider).events.listen(events.add);

    await repository.recordCalibration(
      body: '3.4',
      segment: const Segment(20, Ring.triple),
      corrected: false,
    );
    await settle();

    board.emitBody('3.4');
    await settle();

    expect(
      (events.single as DartHit).segment,
      const Segment(20, Ring.triple),
    );
    expect(container.read(segmentCodecProvider).overrides, isEmpty);
  });

  test('coverage counts every verified segment, corrected or not', () async {
    container.listen(calibrationCoverageProvider, (_, _) {});

    await repository.recordCalibration(
      body: '3.4',
      segment: const Segment(20, Ring.triple),
      corrected: false,
    );
    await repository.recordCalibration(
      body: '4.1',
      segment: const Segment(5, Ring.doubleRing),
      corrected: true,
    );
    await settle();

    expect(container.read(calibrationCoverageProvider), {
      const Segment(20, Ring.triple),
      const Segment(5, Ring.doubleRing),
    });
  });

  test('clearing calibration restores the shipped table', () async {
    final events = <BoardEvent>[];
    container.read(boardReaderProvider).events.listen(events.add);

    await repository.recordCalibration(
      body: '3.4',
      segment: const Segment(19, Ring.doubleRing),
      corrected: true,
    );
    await settle();

    await repository.clearAllCalibrations();
    await settle();

    board.emitBody('3.4');
    await settle();

    expect(
      (events.single as DartHit).segment,
      const Segment(20, Ring.triple),
    );
    expect(container.read(calibrationCoverageProvider), isEmpty);
  });

  test('a frame carries its raw body alongside the decode', () async {
    final frames = <String>[];
    container
        .read(boardReaderProvider)
        .frames
        .listen((frame) => frames.add(frame.body));

    board.emitBatch(['3.4', '9.9', 'BTN']);
    await settle();

    expect(frames, ['3.4', '9.9', 'BTN']);
  });
}
