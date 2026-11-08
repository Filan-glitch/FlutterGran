import '../atc/atc_stop.dart';
import '../x01/leg_state.dart';
import '../x01/x01_rules.dart';

part 'atc_stats.dart';
part 'bulling_stats.dart';
part 'higher_lower_stats.dart';
part 'x01_stats.dart';

/// A player's record in one game mode.
///
/// Sealed, one subtype per mode in its own `part` file, so every `switch`
/// over it is exhaustive and a new mode must be handled by every reader.
sealed class ModeStats {
  const ModeStats();
}
