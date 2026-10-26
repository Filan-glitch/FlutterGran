import 'package:fluttergran/domain/higher_lower/higher_lower_config.dart';
import 'package:fluttergran/domain/x01/game_config.dart';
import 'package:test/test.dart';

void main() {
  test('stores the roster in throwing order', () {
    final config = HigherLowerConfig(playerIds: [3, 1]);
    expect(config.playerIds, [3, 1]);
  });

  test('every leg opens on higher 45 and lower 26', () {
    expect(HigherLowerConfig.startHigher, 45);
    expect(HigherLowerConfig.startLower, 26);
  });

  test('refuses a single player - last one standing needs an opponent', () {
    expect(
      () => HigherLowerConfig(playerIds: [1]),
      throwsA(isA<AssertionError>()),
    );
  });

  test('refuses more players than GameConfig.maxPlayers', () {
    final tooMany = [for (var i = 1; i <= GameConfig.maxPlayers + 1; i++) i];
    expect(
      () => HigherLowerConfig(playerIds: tooMany),
      throwsA(isA<AssertionError>()),
    );
  });

  test('refuses the same player in two seats', () {
    expect(
      () => HigherLowerConfig(playerIds: [1, 1]),
      throwsA(isA<AssertionError>()),
    );
  });
}
