// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get selectGameModeTitle => 'SPIELMODUS WÄHLEN';

  @override
  String get comingSoonLabel => 'DEMNÄCHST';

  @override
  String get moreModesComingLabel => 'WEITERE MODI FOLGEN';

  @override
  String get x01SetupTitle => 'X01 EINRICHTUNG';

  @override
  String get startScoreLabel => 'Startpunktzahl';

  @override
  String get bestOfLabel => 'Best of';

  @override
  String get firstToLabel => 'Erster bis';

  @override
  String get inRuleLabel => 'In';

  @override
  String get outRuleLabel => 'Out';

  @override
  String get playersLabel => 'Spieler';

  @override
  String get tapToAddPlayers => 'Antippen zum Hinzufügen, in Wurfreihenfolge';

  @override
  String seatsOfMax(int seated, int max) {
    return '$seated von $max';
  }

  @override
  String get addPlayerFieldLabel => 'Spieler hinzufügen';

  @override
  String couldNotLoadPlayers(String error) {
    return 'Spieler konnten nicht geladen werden: $error';
  }

  @override
  String get noPlayersYet => 'Noch keine Spieler. Füge oben den ersten hinzu.';

  @override
  String removePlayerTooltip(String name) {
    return '$name entfernen';
  }

  @override
  String get pickAtLeastOnePlayer => 'MINDESTENS EINEN SPIELER WÄHLEN';

  @override
  String get startLeg => 'LEG STARTEN';

  @override
  String startBestOf(int legs) {
    return 'BEST OF $legs STARTEN';
  }

  @override
  String get x01RuleStraight => 'Straight';

  @override
  String get x01RuleDouble => 'Double';

  @override
  String get x01RuleMaster => 'Master';

  @override
  String get rosterTitle => 'SPIELERLISTE';

  @override
  String removedPlayerSnackbar(String name) {
    return '$name entfernt';
  }

  @override
  String get undoLabel => 'RÜCKGÄNGIG';

  @override
  String get playButton => 'SPIELEN';

  @override
  String get trainingMenuLabel => 'Training';

  @override
  String get statisticsMenuLabel => 'Statistik';

  @override
  String get rosterMenuLabel => 'Spielerliste';

  @override
  String get settingsMenuLabel => 'Einstellungen';

  @override
  String get legInProgressLabel => 'LEG LÄUFT';

  @override
  String get resumeLabel => 'FORTSETZEN';

  @override
  String get settingsTitle => 'EINSTELLUNGEN';

  @override
  String get soundSectionTitle => 'Sound';

  @override
  String get cuesAndCommentaryLabel => 'Signale und Kommentar';

  @override
  String get cuesAndCommentaryDetail =>
      'Ein Klick pro Dart, ein Summen bei Bust, eine Fanfare für ein 180er';

  @override
  String get spokenTotalsLabel => 'Gesprochene Ergebnisse';

  @override
  String get spokenTotalsDetail => 'Jede Aufnahme wird laut vorgelesen';

  @override
  String get languageSectionTitle => 'Sprache';

  @override
  String get languageSystemOption => 'System';

  @override
  String get languageEnglishOption => 'Englisch';

  @override
  String get languageGermanOption => 'Deutsch';

  @override
  String get atcSetupTitle => 'AROUND THE CLOCK EINRICHTUNG';

  @override
  String get variantLabel => 'Variante';

  @override
  String get atcVariantAnyPart => 'BELIEBIGES FELD';

  @override
  String get atcVariantMasters => 'MASTERS';

  @override
  String get atcVariantDoublesOnly => 'NUR DOPPEL';

  @override
  String get bullingSetupTitle => 'BULLING EINRICHTUNG';

  @override
  String get bullseyeValueSectionLabel => 'Bullseye-Wert';

  @override
  String get bullseyeValueTwo => 'BULLSEYE = 2';

  @override
  String get bullseyeValueThree => 'BULLSEYE = 3';

  @override
  String get targetLabel => 'Ziel';

  @override
  String get trainingSetupTitle => 'TRAINING';

  @override
  String get drillLabel => 'Übung';

  @override
  String get freePracticeLabel => 'FREIES TRAINING';

  @override
  String get freePracticeTagline => 'werfen und sehen, was du triffst';

  @override
  String get checkoutPracticeLabel => 'CHECKOUT-TRAINING';

  @override
  String get checkoutPracticeTagline =>
      'eine Punktzahl wählen und das Finish üben';

  @override
  String get startButton => 'START';

  @override
  String get connectBoardTooltip => 'Board verbinden';

  @override
  String get boardConnectedTooltip => 'Board verbunden';

  @override
  String get connectingToBoardTooltip => 'Verbindung zum Board…';

  @override
  String get boardDisconnectedTooltip => 'Board getrennt';

  @override
  String get ringSingle => 'EINFACH';

  @override
  String get ringDouble => 'DOPPEL';

  @override
  String get ringTreble => 'TRIPLE';

  @override
  String get keyBullLabel => 'BULL';

  @override
  String get keyMissLabel => 'DANEBEN';

  @override
  String semanticDoubleKey(String label) {
    return 'Doppel $label';
  }

  @override
  String semanticTrebleKey(String label) {
    return 'Triple $label';
  }

  @override
  String playerFallbackName(int id) {
    return 'Spieler $id';
  }

  @override
  String get leaveLegTitle => 'Dieses Leg verlassen?';

  @override
  String get leaveLegBody =>
      'Deine Darts sind gespeichert. Setze jederzeit vom Hauptmenü aus fort.';

  @override
  String get stayButton => 'BLEIBEN';

  @override
  String get leaveButton => 'VERLASSEN';

  @override
  String get hideManualEntryTooltip => 'Manuelle Eingabe ausblenden';

  @override
  String get enterScoreByHandTooltip => 'Punktzahl von Hand eingeben';

  @override
  String get undoLastDartTooltip => 'Letzten Dart rückgängig machen';

  @override
  String legsCount(int count) {
    return 'LEGS $count';
  }

  @override
  String get avgDash => 'SCHNITT —';

  @override
  String avgValue(String value) {
    return 'SCHNITT $value';
  }

  @override
  String get bustLabel => 'BUST';

  @override
  String get wrongButton => 'FALSCH';

  @override
  String get finishButton => 'BEENDEN';

  @override
  String get nextPlayerButton => 'NÄCHSTER SPIELER';

  @override
  String get orPressBoardButton => 'oder den Board-Knopf drücken';

  @override
  String get legWonLabel => 'LEG GEWONNEN';

  @override
  String throwLegNumber(int number) {
    return 'LEG $number WERFEN';
  }

  @override
  String standingLegsToWinIt(String tally, int left) {
    String _temp0 = intl.Intl.pluralLogic(
      left,
      locale: localeName,
      other: 'LEGS',
      one: 'LEG',
    );
    return '$tally · noch $left $_temp0 zum Sieg';
  }

  @override
  String get matchWonLabel => 'MATCH GEWONNEN';

  @override
  String get earlierLegsCouldNotBeRead =>
      'DIE FRÜHEREN LEGS KONNTEN NICHT GELESEN WERDEN';

  @override
  String get rematchButton => 'REVANCHE';

  @override
  String get backToSetupButton => 'ZURÜCK ZUR EINRICHTUNG';

  @override
  String get figureAverage => 'SCHNITT';

  @override
  String get figureFirstNine => 'ERSTE NEUN';

  @override
  String get figure180s => '180er';

  @override
  String get figureBestOut => 'BESTES FINISH';

  @override
  String get figureBestLeg => 'BESTES LEG';

  @override
  String get checkoutLabel => 'CHECKOUT';

  @override
  String scoreArrow(int before, int after) {
    return '$before → $after';
  }

  @override
  String legWonStatsX01(int darts, String average) {
    return '$darts Darts · $average Schnitt';
  }

  @override
  String get throwWhenReady => 'WERFEN, WENN BEREIT';

  @override
  String stopsClearedLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count STATIONEN FREIGESPIELT',
      one: '1 STATION FREIGESPIELT',
      zero: 'NICHTS FREIGESPIELT',
    );
    return '$_temp0';
  }

  @override
  String nowOnStop(String stop) {
    return 'jetzt auf $stop';
  }

  @override
  String dartsCount(int count) {
    return '$count Darts';
  }

  @override
  String get playAgainButton => 'NOCHMAL SPIELEN';

  @override
  String firstToTarget(int target) {
    return 'BIS $target';
  }

  @override
  String ofTarget(int target) {
    return 'von $target';
  }

  @override
  String turnScoredLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count PUNKTE ERZIELT',
      one: '1 PUNKT ERZIELT',
      zero: 'NICHTS GEPUNKTET',
    );
    return '$_temp0';
  }

  @override
  String nowOnScore(int score) {
    return 'jetzt bei $score';
  }

  @override
  String legWonStatsBulling(int points, int darts) {
    return '$points Punkte · $darts Darts';
  }

  @override
  String get statisticsTitle => 'STATISTIK';

  @override
  String get noPlayersYetHeadline => 'Noch keine Spieler';

  @override
  String get noPlayersYetDetail =>
      'Füge auf dem Einrichtungsbildschirm einen hinzu, um eine Statistik zu starten.';

  @override
  String get noLegsYetHeadline => 'Noch keine Legs';

  @override
  String get noLegsYetDetail =>
      'Spiele ein Leg, und jeder Dart darin landet hier.';

  @override
  String get x01Label => 'X01';

  @override
  String get aroundTheClockLabel => 'AROUND THE CLOCK';

  @override
  String get bullingLabel => 'BULLING';

  @override
  String get threeDartAverageLabel => 'Drei-Darts-Schnitt';

  @override
  String dartsOverLegs(int darts, int legs) {
    String _temp0 = intl.Intl.pluralLogic(
      legs,
      locale: localeName,
      other: 'Legs',
      one: 'Leg',
    );
    return '$darts Darts über $legs $_temp0';
  }

  @override
  String get scoringSectionTitle => 'Scoring';

  @override
  String get firstNineAverageRow => 'Schnitt der ersten 9';

  @override
  String get bestTurnRow => 'Beste Aufnahme';

  @override
  String get oneFortyPlusRow => '140+';

  @override
  String get oneHundredPlusRow => '100+';

  @override
  String get sixtyPlusRow => '60+';

  @override
  String get finishingSectionTitle => 'Finish';

  @override
  String ruleCheckoutRow(String rule) {
    return '$rule-Checkout';
  }

  @override
  String ruleDartsAtFinishRow(String rule) {
    return '$rule-Darts beim Finish';
  }

  @override
  String get bestCheckoutRow => 'Bestes Checkout';

  @override
  String get bestLegRow => 'Bestes Leg';

  @override
  String get legsSectionTitle => 'Legs';

  @override
  String wonRatio(int won, int played) {
    return '$won von $played';
  }

  @override
  String get wonLabel => 'Gewonnen';

  @override
  String get winRateLabel => 'Gewinnrate';

  @override
  String get matchesSectionTitle => 'Matches';

  @override
  String get weakSpotsSectionTitle => 'Schwachstellen';

  @override
  String get hitRateLabel => 'Trefferquote';

  @override
  String xOfYDarts(int x, int y) {
    return '$x von $y Darts';
  }

  @override
  String get pointsScoredRow => 'Punkte erzielt';

  @override
  String get outerBullHitsRow => 'Treffer äußerer Bull';

  @override
  String get bullseyeHitsRow => 'Bullseye-Treffer';

  @override
  String get whereDartsLandTitle => 'WO DIE DARTS LANDEN';

  @override
  String get noDartsRecorded => 'Noch keine Darts erfasst.';

  @override
  String get shadedAgainstBusiest =>
      'Eingefärbt relativ zum meistgetroffenen Feld.';

  @override
  String checkoutPracticeWithScore(int score) {
    return '$score · CHECKOUT-TRAINING';
  }

  @override
  String get statDarts => 'DARTS';

  @override
  String get statAverage => 'SCHNITT';

  @override
  String get statBestTurn => 'BESTE AUFNAHME';

  @override
  String checkoutsThisSession(int count) {
    return 'CHECKOUTS DIESE SITZUNG: $count';
  }

  @override
  String get checkedOutLabel => 'AUSGECHECKT';

  @override
  String inDartsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Darts',
      one: '$count Dart',
    );
    return 'in $_temp0';
  }

  @override
  String get throwAgainButton => 'NOCHMAL WERFEN';

  @override
  String get doneButton => 'FERTIG';
}
