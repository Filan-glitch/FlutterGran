import 'package:fluttergran/domain/bulling/bulling_config.dart';
import 'package:fluttergran/domain/bulling/bulling_variant.dart';
import 'package:fluttergran/domain/x01/game_config.dart';
import 'package:test/test.dart';

void main() {
  test('stores the roster, bullseye value, and target', () {
    final config = BullingConfig(
      playerIds: [1, 2],
      bullseyeValue: BullseyeValue.three,
      target: 21,
    );
    expect(config.playerIds, [1, 2]);
    expect(config.bullseyeValue, BullseyeValue.three);
    expect(config.target, 21);
  });

  test('BullseyeValue.points reads as 2 or 3', () {
    expect(BullseyeValue.two.points, 2);
    expect(BullseyeValue.three.points, 3);
  });

  test('refuses an empty roster', () {
    expect(
      () => BullingConfig(
        playerIds: [],
        bullseyeValue: BullseyeValue.two,
        target: 21,
      ),
      throwsA(isA<AssertionError>()),
    );
  });

  test('refuses more players than GameConfig.maxPlayers', () {
    final tooMany = [for (var i = 1; i <= GameConfig.maxPlayers + 1; i++) i];
    expect(
      () => BullingConfig(
        playerIds: tooMany,
        bullseyeValue: BullseyeValue.two,
        target: 21,
      ),
      throwsA(isA<AssertionError>()),
    );
  });

  test('refuses a duplicate seat', () {
    expect(
      () => BullingConfig(
        playerIds: [1, 1],
        bullseyeValue: BullseyeValue.two,
        target: 21,
      ),
      throwsA(isA<AssertionError>()),
    );
  });

  test('refuses a target of zero or below', () {
    expect(
      () => BullingConfig(
        playerIds: [1],
        bullseyeValue: BullseyeValue.two,
        target: 0,
      ),
      throwsA(isA<AssertionError>()),
    );
  });
}
