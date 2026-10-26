import 'package:flutter/material.dart';

import '../domain/atc/atc_stop.dart';
import '../domain/bulling/bulling_config.dart';
import '../domain/game_mode.dart';
import '../domain/higher_lower/higher_lower_config.dart';
import '../domain/training/training_drill.dart';
import '../domain/x01/game_config.dart';
import '../l10n/app_localizations.dart';

/// One rules page's worth of subject matter - a game mode, or training.
///
/// Not [GameMode] (`domain/game_mode.dart`): that enum is tied to having an
/// engine, a resumable leg type, and a stats calculator, all switched over
/// exhaustively in a few places. Training has none of those - it isn't a
/// [GameMode] - but it does need a rules page, so this is its own small
/// enum rather than a stretch of that one. It also carries [IconData], which
/// keeps it out of `lib/domain/`.
enum RulesTopic {
  x01,
  aroundTheClock,
  bulling,
  higherLower,
  training;

  /// The rules page for a playable [GameMode].
  static RulesTopic of(GameMode mode) => switch (mode) {
    GameMode.x01 => RulesTopic.x01,
    GameMode.aroundTheClock => RulesTopic.aroundTheClock,
    GameMode.bulling => RulesTopic.bulling,
    GameMode.higherLower => RulesTopic.higherLower,
  };
}

/// One headline number on a rules page, scoreboard-style: `501`, `22`,
/// `1–4`, with the small capitals naming it.
typedef RulesFact = ({String figure, String label});

extension RulesTopicPresentation on RulesTopic {
  /// Reuses `Icons.fitness_center` for training - the same icon the main
  /// menu's Training row already shows, so the overview card matches it.
  IconData get icon => switch (this) {
    RulesTopic.x01 => Icons.exposure_zero,
    RulesTopic.aroundTheClock => Icons.schedule,
    RulesTopic.bulling => Icons.adjust,
    RulesTopic.higherLower => Icons.swap_vert,
    RulesTopic.training => Icons.fitness_center,
  };

  /// The mode's name, as the mode-select tile shows it - read from
  /// [gameModeRegistry] for the playable modes, so a rules page never
  /// names its game differently from picking it does.
  String displayName(AppLocalizations l10n) => switch (this) {
    RulesTopic.x01 => _registryName(GameMode.x01),
    RulesTopic.aroundTheClock => _registryName(GameMode.aroundTheClock),
    RulesTopic.bulling => _registryName(GameMode.bulling),
    RulesTopic.higherLower => _registryName(GameMode.higherLower),
    RulesTopic.training => l10n.trainingMenuLabel.toUpperCase(),
  };

  static String _registryName(GameMode mode) => gameModeRegistry
      .firstWhere((descriptor) => descriptor.id == mode)
      .displayName;

  /// The whole game in a sentence, under the name on the rules page.
  String objective(AppLocalizations l10n) => switch (this) {
    RulesTopic.x01 => l10n.rulesX01Objective,
    RulesTopic.aroundTheClock => l10n.rulesAtcObjective,
    RulesTopic.bulling => l10n.rulesBullingObjective,
    RulesTopic.higherLower => l10n.rulesHigherLowerObjective,
    RulesTopic.training => l10n.rulesTrainingObjective,
  };

  /// The numbers that define the mode, read off the same domain constants
  /// the setup screens offer, so the rules can't advertise a 901 nobody can
  /// pick.
  List<RulesFact> facts(AppLocalizations l10n) {
    final players = (
      figure: '1–${GameConfig.maxPlayers}',
      label: l10n.rulesFactPlayers,
    );
    return switch (this) {
      RulesTopic.x01 => [
        (
          figure: GameConfig.offeredStartScores.join(' · '),
          label: l10n.rulesFactStart,
        ),
        players,
        (figure: '3', label: l10n.rulesFactDarts),
      ],
      RulesTopic.aroundTheClock => [
        (figure: '${AtcStop.track.length}', label: l10n.rulesFactStops),
        players,
      ],
      RulesTopic.bulling => [
        (
          figure: BullingConfig.offeredTargets.join(' · '),
          label: l10n.rulesFactTarget,
        ),
        players,
      ],
      RulesTopic.higherLower => [
        (
          figure:
              '${HigherLowerConfig.startHigher} · '
              '${HigherLowerConfig.startLower}',
          label: l10n.rulesFactStart,
        ),
        (
          figure: '${HigherLowerConfig.minPlayers}–${GameConfig.maxPlayers}',
          label: l10n.rulesFactPlayers,
        ),
        (figure: '3', label: l10n.rulesFactDarts),
      ],
      RulesTopic.training => [
        (figure: '1', label: l10n.rulesFactPlayer),
        (figure: '${TrainingDrill.values.length}', label: l10n.rulesFactDrills),
      ],
    };
  }

  /// This topic's detail-screen `AppBar` title.
  String title(AppLocalizations l10n) => switch (this) {
    RulesTopic.x01 => l10n.rulesX01Title,
    RulesTopic.aroundTheClock => l10n.rulesAtcTitle,
    RulesTopic.bulling => l10n.rulesBullingTitle,
    RulesTopic.higherLower => l10n.rulesHigherLowerTitle,
    RulesTopic.training => l10n.rulesTrainingTitle,
  };

  /// One-line tagline for the overview screen's picker row.
  String overview(AppLocalizations l10n) => switch (this) {
    RulesTopic.x01 => l10n.rulesX01Overview,
    RulesTopic.aroundTheClock => l10n.rulesAtcOverview,
    RulesTopic.bulling => l10n.rulesBullingOverview,
    RulesTopic.higherLower => l10n.rulesHigherLowerOverview,
    RulesTopic.training => l10n.rulesTrainingOverview,
  };
}
