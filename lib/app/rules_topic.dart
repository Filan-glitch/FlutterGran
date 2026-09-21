import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// One rules page's worth of subject matter - a game mode, or training.
///
/// Not [GameMode] (`domain/game_mode.dart`): that enum is tied to having an
/// engine, a resumable leg type, and a stats calculator, all switched over
/// exhaustively in a few places. Training has none of those - it isn't a
/// [GameMode] - but it does need a rules page, so this is its own small
/// enum rather than a stretch of that one. It also carries [IconData], which
/// keeps it out of `lib/domain/`.
enum RulesTopic { x01, aroundTheClock, bulling, training }

extension RulesTopicPresentation on RulesTopic {
  /// Reuses `Icons.fitness_center` for training - the same icon the main
  /// menu's Training row already shows, so the overview card matches it.
  IconData get icon => switch (this) {
    RulesTopic.x01 => Icons.exposure_zero,
    RulesTopic.aroundTheClock => Icons.schedule,
    RulesTopic.bulling => Icons.adjust,
    RulesTopic.training => Icons.fitness_center,
  };

  /// This topic's detail-screen `AppBar` title.
  String title(AppLocalizations l10n) => switch (this) {
    RulesTopic.x01 => l10n.rulesX01Title,
    RulesTopic.aroundTheClock => l10n.rulesAtcTitle,
    RulesTopic.bulling => l10n.rulesBullingTitle,
    RulesTopic.training => l10n.rulesTrainingTitle,
  };

  /// One-line tagline for the overview screen's picker row.
  String overview(AppLocalizations l10n) => switch (this) {
    RulesTopic.x01 => l10n.rulesX01Overview,
    RulesTopic.aroundTheClock => l10n.rulesAtcOverview,
    RulesTopic.bulling => l10n.rulesBullingOverview,
    RulesTopic.training => l10n.rulesTrainingOverview,
  };
}
