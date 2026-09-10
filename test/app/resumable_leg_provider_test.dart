import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttergran/app/providers.dart';
import 'package:fluttergran/data/board/fake_board_source.dart';
import 'package:fluttergran/data/db/database.dart';
import 'package:fluttergran/data/db/game_repository.dart';
import 'package:fluttergran/domain/atc/atc_config.dart';
import 'package:fluttergran/domain/atc/atc_variant.dart';
import 'package:fluttergran/domain/bulling/bulling_config.dart';
import 'package:fluttergran/domain/bulling/bulling_variant.dart';
import 'package:fluttergran/domain/segment.dart';
import 'package:fluttergran/domain/x01/game_config.dart';
import 'package:fluttergran/domain/x01/thrown_dart.dart';

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
  });

  /// `resumableLegProvider.future` only ever resolves to the *first* value
  /// the stream emits after the provider is built - so every test seeds its
  /// data before this is called, not after, or the future would resolve to
  /// whatever the query saw before there was anything to find.
  ///
  /// Providers auto-dispose, and `read` alone does not keep one alive - the
  /// listener stands in for the widget that would otherwise watch it.
  Future<ResumableLeg?> readResumable() {
    container.listen(resumableLegProvider, (_, _) {});
    return container.read(resumableLegProvider.future);
  }

  tearDown(() async {
    container.dispose();
    await board.dispose();
    await database.close();
  });

  test('an x01 leg round-trips as ResumableX01Leg', () async {
    final finn = await repository.addPlayer('Finn');
    final gameId = await repository.startGame(
      GameConfig(startScore: 501, playerIds: [finn.id]),
    );
    await repository.appendDart(
      gameId: gameId,
      ordinal: 0,
      playerId: finn.id,
      dart: const ThrownDart.miss(),
    );

    final resumable = await readResumable();
    expect(resumable, isA<ResumableX01Leg>());
    expect(resumable!.gameId, gameId);
    expect((resumable as ResumableX01Leg).leg.currentPlayerId, finn.id);
  });

  test('an ATC leg round-trips as ResumableAtcLeg', () async {
    final finn = await repository.addPlayer('Finn');
    final gameId = await repository.startAtcGame(
      AtcConfig(playerIds: [finn.id], variant: AtcVariant.anyPart),
    );
    await repository.appendDart(
      gameId: gameId,
      ordinal: 0,
      playerId: finn.id,
      dart: ThrownDart(Segment(1, Ring.outerSingle)),
    );

    final resumable = await readResumable();
    expect(resumable, isA<ResumableAtcLeg>());
    expect(resumable!.gameId, gameId);
    expect((resumable as ResumableAtcLeg).leg.stopIndex[finn.id], 1);
  });

  test('a Bulling leg round-trips as ResumableBullingLeg', () async {
    final finn = await repository.addPlayer('Finn');
    final gameId = await repository.startBullingGame(
      BullingConfig(
        playerIds: [finn.id],
        bullseyeValue: BullseyeValue.two,
        target: 21,
      ),
    );
    await repository.appendDart(
      gameId: gameId,
      ordinal: 0,
      playerId: finn.id,
      dart: ThrownDart(Segment.outerBull),
    );

    final resumable = await readResumable();
    expect(resumable, isA<ResumableBullingLeg>());
    expect(resumable!.gameId, gameId);
    expect((resumable as ResumableBullingLeg).leg.scoreFor(finn.id), 1);
  });

  test('nothing in progress resolves to null', () async {
    expect(await readResumable(), isNull);
  });
}
