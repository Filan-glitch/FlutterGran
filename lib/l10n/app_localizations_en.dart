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
      'Start on 301, 501 or 701 and race to exactly zero, three darts a turn.';

  @override
  String get rulesAtcObjective =>
      'Hit 1 to 20 in order, then the outer bull, then the bullseye. First all the way round wins.';

  @override
  String get rulesBullingObjective =>
      'Only bulls score. First to reach the target wins.';

  @override
  String get rulesTrainingObjective =>
      'Just you and the board. No opponent, no pressure - pick a drill and throw.';

  @override
  String get rulesFactStart => 'START';

  @override
  String get rulesFactPlayers => 'PLAYERS';

  @override
  String get rulesFactPlayer => 'PLAYER';

  @override
  String get rulesFactDarts => 'DARTS A TURN';

  @override
  String get rulesFactStops => 'STOPS';

  @override
  String get rulesFactTarget => 'TARGET';

  @override
  String get rulesFactDrills => 'DRILLS';

  @override
  String get rulesSectionIn => 'IN RULE';

  @override
  String get rulesSectionOut => 'OUT RULE';

  @override
  String get rulesSectionBust => 'BUST';

  @override
  String get rulesSectionFormat => 'MATCH FORMAT';

  @override
  String get rulesSectionRoute => 'THE ROUTE';

  @override
  String get rulesSectionVariant => 'VARIANT';

  @override
  String get rulesSectionScoring => 'SCORING';

  @override
  String get rulesSectionDrills => 'DRILLS';

  @override
  String get rulesSectionExamples => 'EXAMPLES';

  @override
  String get rulesLegendIn => 'LIT SEGMENTS OPEN YOUR SCORE';

  @override
  String get rulesLegendOut => 'LIT SEGMENTS CAN FINISH A LEG';

  @override
  String get rulesLegendAtc => 'LIT SEGMENTS CLEAR STOP 20';

  @override
  String get rulesLegendBulling => 'ONLY THE LIT BULLS SCORE';

  @override
  String get rulesLegendCheckout => 'LIT SEGMENTS CAN FINISH';

  @override
  String get rulesInStraight =>
      'Every dart counts, right from the first throw.';

  @override
  String get rulesInDouble =>
      'Nothing counts until you hit a double. That double opens your score and counts too.';

  @override
  String get rulesInMaster =>
      'Nothing counts until you hit a double or a triple. That dart opens your score and counts too.';

  @override
  String get rulesOutStraight =>
      'Any dart that lands you on exactly zero wins the leg.';

  @override
  String get rulesOutDouble =>
      'Only a double - or the bullseye - can take you to zero.';

  @override
  String get rulesOutMaster =>
      'A double, a triple or the bullseye can take you to zero.';

  @override
  String get rulesBustTitle => 'A TURN BUSTS WHEN';

  @override
  String get rulesBustOvershoot => 'You score more than you have left.';

  @override
  String get rulesBustNoFinish =>
      'You reach zero, but not with a dart the out rule allows.';

  @override
  String get rulesBustOneLeft =>
      'You leave exactly 1 under double or master out - no dart can finish that.';

  @override
  String get rulesBustReset =>
      'The rest of the turn is lost and your score goes back to where the turn started.';

  @override
  String get rulesFormatBestOf => 'BEST OF';

  @override
  String rulesFormatFirstTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'First to $count legs',
      one: 'First to 1 leg',
    );
    return '$_temp0';
  }

  @override
  String get rulesFormatGroup =>
      'With 3 or 4 players nobody is guaranteed a majority, so the match runs on until someone gets there.';

  @override
  String get rulesAtcRouteHint =>
      'One stop at a time: hit your number to move on to the next one.';

  @override
  String get rulesAtcAnyPart =>
      'Single, double or triple - any part of the number counts.';

  @override
  String get rulesAtcMasters =>
      'Only the double or the triple of the number counts.';

  @override
  String get rulesAtcDoublesOnly => 'Only the double of the number counts.';

  @override
  String get rulesAtcBullsNote =>
      'The two bull stops always need just that bull, whatever the variant.';

  @override
  String get rulesBullseyeTwo =>
      'The bullseye is worth 2. Steady legs, more darts.';

  @override
  String get rulesBullseyeThree =>
      'The bullseye is worth 3. One great dart can swing the leg.';

  @override
  String get rulesBullingOuterBull => 'OUTER BULL';

  @override
  String get rulesBullingBullseye => 'BULLSEYE';

  @override
  String get rulesBullingEverythingElse => 'EVERYTHING ELSE';

  @override
  String get rulesBullingInstantTitle => 'INSTANT WIN';

  @override
  String get rulesBullingInstant =>
      'The leg ends the moment you reach the target, even mid-turn. Darts after that don\'t count.';

  @override
  String get rulesBullingNoBust =>
      'Going past the target is fine - there is no bust in bulling.';

  @override
  String get rulesTrainingFreeBody =>
      'No target and no win condition. Throw and watch your numbers.';

  @override
  String get rulesTrainingCheckoutBody =>
      'Pick a start score and finish it under double out, the same rule as an X01 leg. The checkout route stays on screen the whole way.';

  @override
  String get rulesStatTotal => 'TOTAL';

  @override
  String get rulesOutcomeCheckout => 'GAME SHOT';

  @override
  String get rulesOutcomeNextStop => 'NEXT STOP';

  @override
  String get rulesOutcomeWin => 'LEG WON';

  @override
  String rulesExampleLeft(int remaining) {
    return '$remaining LEFT';
  }

  @override
  String get rulesExampleDoubleOut => 'DOUBLE OUT';

  @override
  String get rulesExampleCheckoutNote => 'D20 is a double: straight to zero.';

  @override
  String get rulesExampleNoDoubleNote =>
      'Zero - but the last dart was a single, so it doesn\'t count.';

  @override
  String get rulesExampleOvershootNote =>
      '34 is more than 32. Back to 32 for the next turn.';

  @override
  String rulesExampleAtcOn(String stop, String variant) {
    return 'ON $stop · $variant';
  }

  @override
  String get rulesExampleAtcNote =>
      'The single doesn\'t clear 5 under Masters. The triple does.';

  @override
  String rulesExampleBulling(int score, int target) {
    return '$score OF $target';
  }

  @override
  String get rulesExampleBullingNote =>
      'The bullseye takes you past 21 - the third dart is never thrown.';

  @override
  String get rulesBoardSemantics =>
      'Dartboard with the segments that count lit up';

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
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count darts',
      one: '1 dart',
    );
    return '$_temp0';
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

  @override
  String get updatesSectionTitle => 'Updates';

  @override
  String updateCurrentVersion(String version) {
    return 'Version $version';
  }

  @override
  String get updateAutoCheckLabel => 'Check for updates';

  @override
  String get updateAutoCheckDetail =>
      'Asks GitHub for a newer release when the app starts';

  @override
  String get updateCheckNowButton => 'CHECK NOW';

  @override
  String get updateCheckingStatus => 'Checking…';

  @override
  String get updateUpToDateStatus => 'Chalk is up to date';

  @override
  String get updateCheckFailedStatus => 'Couldn\'t reach GitHub';

  @override
  String get updateAvailableEyebrow => 'UPDATE';

  @override
  String updateAvailableTitle(String version) {
    return 'Chalk $version is available';
  }

  @override
  String get updateAndroidDetail =>
      'Downloads and installs it, keeping every game played';

  @override
  String get updateWindowsDetail => 'Opens the release page to download it';

  @override
  String get updateInstallButton => 'UPDATE';

  @override
  String get updateDownloadButton => 'DOWNLOAD';

  @override
  String get updateDownloadingStatus => 'Downloading…';

  @override
  String get updateInstallingStatus => 'Finish in the installer Android opened';

  @override
  String get updatePermissionStatus =>
      'Allow Chalk to install apps, then come back';

  @override
  String get updateDownloadFailedStatus => 'Download failed';

  @override
  String get updateInstallFailedStatus => 'Couldn\'t start the update';

  @override
  String get updateRetryButton => 'TRY AGAIN';

  @override
  String get updateDismissTooltip => 'Dismiss';
}
