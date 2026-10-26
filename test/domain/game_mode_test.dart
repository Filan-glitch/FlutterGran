import 'package:fluttergran/domain/game_mode.dart';
import 'package:test/test.dart';

void main() {
  test('the registry lists x01, Around the Clock, Bulling and Higher/Lower, all available', () {
    expect(gameModeRegistry.map((mode) => mode.id), [
      GameMode.x01,
      GameMode.aroundTheClock,
      GameMode.bulling,
      GameMode.higherLower,
    ]);
    expect(gameModeRegistry.every((mode) => mode.isAvailable), isTrue);
  });
}
