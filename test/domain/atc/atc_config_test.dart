import 'package:fluttergran/domain/atc/atc_config.dart';
import 'package:fluttergran/domain/atc/atc_variant.dart';
import 'package:fluttergran/domain/x01/game_config.dart';
import 'package:test/test.dart';

void main() {
  test('stores the roster and variant', () {
    final config = AtcConfig(playerIds: [1, 2], variant: AtcVariant.masters);
    expect(config.playerIds, [1, 2]);
    expect(config.variant, AtcVariant.masters);
  });

  test('refuses an empty roster', () {
    expect(
      () => AtcConfig(playerIds: [], variant: AtcVariant.anyPart),
      throwsA(isA<AssertionError>()),
    );
  });

  test('refuses more players than GameConfig.maxPlayers', () {
    final tooMany = [for (var i = 1; i <= GameConfig.maxPlayers + 1; i++) i];
    expect(
      () => AtcConfig(playerIds: tooMany, variant: AtcVariant.anyPart),
      throwsA(isA<AssertionError>()),
    );
  });

  test('refuses a duplicate seat', () {
    expect(
      () => AtcConfig(playerIds: [1, 1], variant: AtcVariant.anyPart),
      throwsA(isA<AssertionError>()),
    );
  });
}
