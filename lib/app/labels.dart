import 'package:flutter/widgets.dart';

import '../domain/atc/atc_variant.dart';
import '../domain/bulling/bulling_variant.dart';
import '../domain/game_mode.dart';
import '../domain/x01/x01_rules.dart';
import 'l10n_extensions.dart';

/// How an [X01InRule] reads on the setup chip and the rules pages - the
/// localized counterpart to [X01InRuleChecks.label].
String x01InRuleLabel(BuildContext context, X01InRule rule) {
  final l10n = context.l10n;
  return switch (rule) {
    X01InRule.straight => l10n.x01RuleStraight,
    X01InRule.double => l10n.x01RuleDouble,
    X01InRule.master => l10n.x01RuleMaster,
  };
}

/// How an [X01OutRule] reads on the setup chip, the rules pages and the
/// stats screen's checkout rows. See [x01InRuleLabel].
String x01OutRuleLabel(BuildContext context, X01OutRule rule) {
  final l10n = context.l10n;
  return switch (rule) {
    X01OutRule.straight => l10n.x01RuleStraight,
    X01OutRule.double => l10n.x01RuleDouble,
    X01OutRule.master => l10n.x01RuleMaster,
  };
}

/// The short label for an [AtcVariant], wherever one is shown.
String atcVariantLabel(BuildContext context, AtcVariant variant) {
  final l10n = context.l10n;
  return switch (variant) {
    AtcVariant.anyPart => l10n.atcVariantAnyPart,
    AtcVariant.masters => l10n.atcVariantMasters,
    AtcVariant.doublesOnly => l10n.atcVariantDoublesOnly,
  };
}

/// The short label for a [BullseyeValue], wherever one is shown.
String bullseyeValueLabel(BuildContext context, BullseyeValue value) {
  final l10n = context.l10n;
  return switch (value) {
    BullseyeValue.two => l10n.bullseyeValueTwo,
    BullseyeValue.three => l10n.bullseyeValueThree,
  };
}

/// [mode]'s name as the mode-select tile shows it, read from
/// [gameModeRegistry] so every screen names a game the same way.
String gameModeName(GameMode mode) => gameModeRegistry
    .firstWhere((descriptor) => descriptor.id == mode)
    .displayName;

/// `hits` out of `darts` as a whole percentage such as `42%`, or a dash when
/// no darts have been thrown.
String hitRateText(int hits, int darts) =>
    darts == 0 ? '—' : '${(hits * 100 / darts).round()}%';
