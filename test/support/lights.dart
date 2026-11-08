/// Keeping the board's LED ring out of a test.
library;

import 'package:flutter_riverpod/misc.dart';
import 'package:fluttergran/app/providers.dart';

/// Overrides the LED setting to off, so no reaction is scheduled on the ring
/// and no timer is left pending when the test ends.
Override lightsOff() => ledEnabledProvider.overrideWith(_LightsOff.new);

class _LightsOff extends BoolSetting {
  _LightsOff() : super('led.enabled');

  @override
  bool build() => false;
}
