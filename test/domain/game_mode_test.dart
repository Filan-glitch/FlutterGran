import 'package:fluttergran/domain/game_mode.dart';
import 'package:test/test.dart';

void main() {
  test('the registry lists x01, Around the Clock, and Bulling, all available', () {
    expect(gameModeRegistry.map((mode) => mode.id), [
      GameMode.x01,
      GameMode.aroundTheClock,
      GameMode.bulling,
    ]);
    expect(gameModeRegistry.every((mode) => mode.isAvailable), isTrue);
  });
}
