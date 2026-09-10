import '../atc/atc_stop.dart';
import '../x01/leg_state.dart';

part 'atc_stats.dart';
part 'bulling_stats.dart';
part 'x01_stats.dart';

/// A player's record in one game mode.
///
/// The extension point: [X01Stats] is the only implementation today, because
/// x01 is the only mode with an engine. A future mode's stats shape has no
/// reason to look anything like x01's - checkout percentage means nothing in
/// a game with no checkout - so nothing about this type is speculative
/// beyond "some mode produced some record." Sealed, with each subtype in its
/// own `part` file (as [X01Stats] is here) so a future mode adds a file, not
/// an edit to this one - and so every `switch` over [ModeStats] stays
/// exhaustive, forcing every reader to handle the new mode explicitly.
sealed class ModeStats {
  const ModeStats();
}
