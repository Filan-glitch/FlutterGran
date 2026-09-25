// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get selectGameModeTitle => 'SELECT GAME MODE';

  @override
  String get comingSoonLabel => 'COMING SOON';

  @override
  String get moreModesComingLabel => 'MORE MODES COMING';

  @override
  String get x01SetupTitle => 'X01 SETUP';

  @override
  String get startScoreLabel => 'Start score';

  @override
  String get bestOfLabel => 'Best of';

  @override
  String get firstToLabel => 'First to';

  @override
  String get inRuleLabel => 'In';

  @override
  String get outRuleLabel => 'Out';

  @override
  String get playersLabel => 'Players';

  @override
  String get tapToAddPlayers => 'tap to add, in throwing order';

  @override
  String seatsOfMax(int seated, int max) {
    return '$seated of $max';
  }

  @override
  String get addPlayerFieldLabel => 'Add a player';

  @override
  String couldNotLoadPlayers(String error) {
    return 'Could not load players: $error';
  }

  @override
  String get noPlayersYet => 'No players yet. Add the first one above.';

  @override
  String get pickAtLeastOnePlayer => 'PICK AT LEAST ONE PLAYER';

  @override
  String get startLeg => 'START LEG';

  @override
  String startBestOf(int legs) {
    return 'START BEST OF $legs';
  }

  @override
  String get x01RuleStraight => 'Straight';

  @override
  String get x01RuleDouble => 'Double';

  @override
  String get x01RuleMaster => 'Master';

  @override
  String get rosterTitle => 'ROSTER';

  @override
  String removedPlayerSnackbar(String name) {
    return 'Removed $name';
  }

  @override
  String get undoLabel => 'UNDO';

  @override
  String get playButton => 'PLAY';

  @override
  String get trainingMenuLabel => 'Training';

  @override
  String get rulesMenuLabel => 'Rules';

  @override
  String get statisticsMenuLabel => 'Statistics';

  @override
  String get rosterMenuLabel => 'Roster';

  @override
  String get settingsMenuLabel => 'Settings';

  @override
  String get legInProgressLabel => 'LEG IN PROGRESS';

  @override
  String get resumeLabel => 'RESUME';

  @override
  String get settingsTitle => 'SETTINGS';

  @override
  String get soundSectionTitle => 'Sound';

  @override
  String get cuesAndCommentaryLabel => 'Cues and commentary';

  @override
  String get cuesAndCommentaryDetail =>
      'A click per dart, a buzz on a bust, a fanfare for a 180';

  @override
  String get spokenTotalsLabel => 'Spoken totals';

  @override
  String get spokenTotalsDetail => 'Each turn read out loud';

  @override
  String get boardLightsSectionTitle => 'Board lights';

  @override
  String get boardLightsLabel => 'LED ring';

  @override
  String get boardLightsDetail =>
      'Needs the board on USB power - the LEDs stay dark on batteries';

  @override
  String get dartFlashesLabel => 'Dart flashes';

  @override
  String get dartFlashesDetail =>
      'The number you hit lights up, a flicker for a miss';

  @override
  String get targetRingLabel => 'Target on the ring';

  @override
  String get targetRingDetail =>
      'The checkout route, your Around the Clock number, the bull';

  @override
  String get celebrationsLabel => 'Celebrations';

  @override
  String get celebrationsDetail =>
      'Game on, ton plus, 180, legs and matches won';

  @override
  String get languageSectionTitle => 'Language';

  @override
  String get languageSystemOption => 'System';

  @override
  String get languageEnglishOption => 'English';

  @override
  String get languageGermanOption => 'German';

  @override
  String get rulesTitle => 'RULES';

  @override
  String get rulesX01Objective =>
      'Race to exactly zero. Each player starts at the chosen score — 301, 501, or 701 — and works it down with three darts a turn.';

  @override
  String get rulesX01InRule =>
      'In rule sets what starts your scoring: Straight — any dart counts right away. Double — darts before your first double score nothing; that double both opens your score and counts. Master — a double or a triple opens it.';

  @override
  String get rulesX01OutRule =>
      'Out rule sets what can finish a leg: Straight — any dart can take you out on exactly zero. Double — only a double finishes. Master — a double or a triple finishes. Overshooting zero, landing on it without a qualifying finish, or leaving exactly 1 under double or master out all bust the turn — your score resets to what it was when the turn began.';

  @override
  String get rulesX01Format =>
      'A match is played over several legs — best of 1, 3, 5, or 7. With two players it\'s first to more than half; with three or four it\'s simply first to that many legs, since a majority isn\'t guaranteed to fall within them.';

  @override
  String get rulesAtcObjective =>
      'Clear 22 stops in order — 1 through 20, then the outer bull, then the bullseye. First to clear them all wins.';

  @override
  String get rulesAtcVariant =>
      'Variant sets what clears a numbered stop (the two bull stops are unaffected): Any part — single, double, or triple all count. Masters — double or triple only. Doubles only — double only.';

  @override
  String get rulesBullingObjective =>
      'First to reach or pass the target score — 21, 31, or 41 — by hitting bulls wins. The outer bull is worth 1 point; the inner bull (bullseye) is worth 2 or 3, set at setup. Everything else scores nothing.';

  @override
  String get rulesBullingValue =>
      'A leg ends the moment a player reaches target, even mid-turn — any darts thrown after that in the same turn don\'t count.';

  @override
  String get rulesTrainingFreePractice =>
      'Free practice — no target or win condition. Just throw; the session tracks your total, best turn, 180 count, and three-dart average.';

  @override
  String get rulesTrainingCheckoutPractice =>
      'Checkout practice — pick a start score and practice finishing it under double-out, the same rule as an X01 leg, with the checkout suggestion shown throughout.';

  @override
  String get rulesX01Title => 'X01 RULES';

  @override
  String get rulesAtcTitle => 'AROUND THE CLOCK RULES';

  @override
  String get rulesBullingTitle => 'BULLING RULES';

  @override
  String get rulesTrainingTitle => 'TRAINING RULES';

  @override
  String get rulesX01Overview => 'Race down to zero and check out on a double';

  @override
  String get rulesAtcOverview => 'Clear every number in order, then both bulls';

  @override
  String get rulesBullingOverview =>
      'First to the target by hitting bulls wins';

  @override
  String get rulesTrainingOverview => 'Free practice or checkout drills, solo';

  @override
  String get atcSetupTitle => 'AROUND THE CLOCK SETUP';

  @override
  String get variantLabel => 'Variant';

  @override
  String get atcVariantAnyPart => 'ANY PART';

  @override
  String get atcVariantMasters => 'MASTERS';

  @override
  String get atcVariantDoublesOnly => 'DOUBLES ONLY';

  @override
  String get bullingSetupTitle => 'BULLING SETUP';

  @override
  String get bullseyeValueSectionLabel => 'Bullseye value';

  @override
  String get bullseyeValueTwo => 'BULLSEYE = 2';

  @override
  String get bullseyeValueThree => 'BULLSEYE = 3';

  @override
  String get targetLabel => 'Target';

  @override
  String get trainingSetupTitle => 'TRAINING';

  @override
  String get drillLabel => 'Drill';

  @override
  String get freePracticeLabel => 'FREE PRACTICE';

  @override
  String get freePracticeTagline => 'throw and see what you hit';

  @override
  String get checkoutPracticeLabel => 'CHECKOUT PRACTICE';

  @override
  String get checkoutPracticeTagline => 'pick a score, practice finishing it';

  @override
  String get startButton => 'START';

  @override
  String get connectBoardTooltip => 'Connect board';

  @override
  String get boardConnectedTooltip => 'Board connected';

  @override
  String get connectingToBoardTooltip => 'Connecting to board…';

  @override
  String get boardDisconnectedTooltip => 'Board disconnected';

  @override
  String boardConnectedNamedTooltip(String name) {
    return 'Connected to $name - tap to disconnect';
  }

  @override
  String get boardRetryingTooltip =>
      'Board lost - reconnecting. Tap to try now';

  @override
  String get bluetoothOffTooltip => 'Bluetooth is off - tap to turn it on';

  @override
  String get bluetoothUnauthorizedTooltip =>
      'Bluetooth permission needed - tap to ask again';

  @override
  String get bluetoothUnsupportedTooltip =>
      'This device has no Bluetooth Low Energy';

  @override
  String get turnOnBluetoothInSettings =>
      'Turn on Bluetooth in the system settings to connect the board';

  @override
  String boardConnectedToast(String name) {
    return 'Board connected: $name';
  }

  @override
  String get boardConnectedToastUnnamed => 'Board connected';

  @override
  String get boardLostToast => 'Board connection lost - reconnecting…';

  @override
  String get bluetoothOffToast =>
      'Bluetooth is off - turn it on to connect the board';

  @override
  String get boardSectionTitle => 'Board';

  @override
  String get autoConnectLabel => 'Connect automatically';

  @override
  String get autoConnectDetail =>
      'When the app starts, and whenever it comes back to the front';

  @override
  String get forgetBoardLabel => 'Forget board';

  @override
  String get forgetBoardDetail =>
      'The next connection searches for a board again';

  @override
  String get ringSingle => 'SINGLE';

  @override
  String get ringDouble => 'DOUBLE';

  @override
  String get ringTreble => 'TREBLE';

  @override
  String get keyBullLabel => 'BULL';

  @override
  String get keyMissLabel => 'MISS';

  @override
  String semanticDoubleKey(String label) {
    return 'double $label';
  }

  @override
  String semanticTrebleKey(String label) {
    return 'treble $label';
  }

  @override
  String playerFallbackName(int id) {
    return 'Player $id';
  }

  @override
  String get leaveLegTitle => 'Leave this leg?';

  @override
  String get leaveLegBody =>
      'Your darts are saved. Resume from the main menu whenever you like.';

  @override
  String get stayButton => 'STAY';

  @override
  String get leaveButton => 'LEAVE';

  @override
  String get hideManualEntryTooltip => 'Hide manual entry';

  @override
  String get enterScoreByHandTooltip => 'Enter a score by hand';

  @override
  String get undoLastDartTooltip => 'Undo last dart';

  @override
  String legsCount(int count) {
    return 'LEGS $count';
  }

  @override
  String get avgDash => 'AVG —';

  @override
  String avgValue(String value) {
    return 'AVG $value';
  }

  @override
  String get bustLabel => 'BUST';

  @override
  String get wrongButton => 'WRONG';

  @override
  String get finishButton => 'FINISH';

  @override
  String get nextPlayerButton => 'NEXT PLAYER';

  @override
  String get orPressBoardButton => 'or press the board button';

  @override
  String get legWonLabel => 'LEG WON';

  @override
  String throwLegNumber(int number) {
    return 'THROW LEG $number';
  }

  @override
  String standingLegsToWinIt(String tally, int left) {
    String _temp0 = intl.Intl.pluralLogic(
      left,
      locale: localeName,
      other: 'LEGS',
      one: 'LEG',
    );
    return '$tally · $left $_temp0 TO WIN IT';
  }

  @override
  String get matchWonLabel => 'MATCH WON';

  @override
  String get earlierLegsCouldNotBeRead => 'THE EARLIER LEGS COULD NOT BE READ';

  @override
  String get rematchButton => 'REMATCH';

  @override
  String get backToSetupButton => 'BACK TO SETUP';

  @override
  String get figureAverage => 'AVERAGE';

  @override
  String get figureFirstNine => 'FIRST NINE';

  @override
  String get figure180s => '180s';

  @override
  String get figureBestOut => 'BEST OUT';

  @override
  String get figureBestLeg => 'BEST LEG';

  @override
  String get checkoutLabel => 'CHECKOUT';

  @override
  String checkoutDartsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count DARTS',
      one: '1 DART',
    );
    return '$_temp0';
  }

  @override
  String get checkoutNextDart => 'next dart';

  @override
  String get checkoutOr => 'or';

  @override
  String semanticCheckoutRoute(int remaining, String route) {
    return 'Checkout $remaining: $route';
  }

  @override
  String scoreArrow(String before, String after) {
    return '$before → $after';
  }

  @override
  String legWonStatsX01(int darts, String average) {
    return '$darts darts · $average average';
  }

  @override
  String get aimLabel => 'AIM';

  @override
  String get remainingLabel => 'REMAINING';

  @override
  String get figureHitRate => 'HIT RATE';

  @override
  String get figureReached => 'REACHED';

  @override
  String get figurePoints => 'POINTS';

  @override
  String dartsCount(int count) {
    return '$count darts';
  }

  @override
  String get playAgainButton => 'PLAY AGAIN';

  @override
  String firstToTarget(int target) {
    return 'FIRST TO $target';
  }

  @override
  String ofTarget(int target) {
    return 'of $target';
  }

  @override
  String get statisticsTitle => 'STATISTICS';

  @override
  String get noPlayersYetHeadline => 'No players yet';

  @override
  String get noPlayersYetDetail =>
      'Add one on the setup screen to start a record.';

  @override
  String get noLegsYetHeadline => 'No legs yet';

  @override
  String get noLegsYetDetail => 'Play a leg and every dart in it lands here.';

  @override
  String get x01Label => 'X01';

  @override
  String get aroundTheClockLabel => 'AROUND THE CLOCK';

  @override
  String get bullingLabel => 'BULLING';

  @override
  String get threeDartAverageLabel => 'Three-dart average';

  @override
  String dartsOverLegs(int darts, int legs) {
    String _temp0 = intl.Intl.pluralLogic(
      legs,
      locale: localeName,
      other: 'legs',
      one: 'leg',
    );
    return '$darts darts over $legs $_temp0';
  }

  @override
  String get scoringSectionTitle => 'Scoring';

  @override
  String get firstNineAverageRow => 'First 9 average';

  @override
  String get bestTurnRow => 'Best turn';

  @override
  String get oneFortyPlusRow => '140+';

  @override
  String get oneHundredPlusRow => '100+';

  @override
  String get sixtyPlusRow => '60+';

  @override
  String get finishingSectionTitle => 'Finishing';

  @override
  String ruleCheckoutRow(String rule) {
    return '$rule checkout';
  }

  @override
  String ruleDartsAtFinishRow(String rule) {
    return '$rule darts at finish';
  }

  @override
  String get bestCheckoutRow => 'Best checkout';

  @override
  String get bestLegRow => 'Best leg';

  @override
  String get legsSectionTitle => 'Legs';

  @override
  String wonRatio(int won, int played) {
    return '$won of $played';
  }

  @override
  String get wonLabel => 'Won';

  @override
  String get winRateLabel => 'Win rate';

  @override
  String get matchesSectionTitle => 'Matches';

  @override
  String get weakSpotsSectionTitle => 'Weak spots';

  @override
  String get hitRateLabel => 'Hit rate';

  @override
  String xOfYDarts(int x, int y) {
    return '$x of $y darts';
  }

  @override
  String get pointsScoredRow => 'Points scored';

  @override
  String get outerBullHitsRow => 'Outer bull hits';

  @override
  String get bullseyeHitsRow => 'Bullseye hits';

  @override
  String get whereDartsLandTitle => 'WHERE THE DARTS LAND';

  @override
  String get noDartsRecorded => 'No darts recorded yet.';

  @override
  String get shadedAgainstBusiest => 'Shaded against the busiest segment.';

  @override
  String checkoutPracticeWithScore(int score) {
    return '$score · CHECKOUT PRACTICE';
  }

  @override
  String get statDarts => 'DARTS';

  @override
  String get statAverage => 'AVERAGE';

  @override
  String get statBestTurn => 'BEST TURN';

  @override
  String checkoutsThisSession(int count) {
    return 'CHECKOUTS THIS SESSION: $count';
  }

  @override
  String get checkedOutLabel => 'CHECKED OUT';

  @override
  String inDartsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count darts',
      one: '$count dart',
    );
    return 'in $_temp0';
  }

  @override
  String get throwAgainButton => 'THROW AGAIN';

  @override
  String get doneButton => 'DONE';
}
