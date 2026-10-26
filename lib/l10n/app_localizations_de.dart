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
  String get rulesMenuLabel => 'Regeln';

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
  String get boardLightsSectionTitle => 'Board-Beleuchtung';

  @override
  String get boardLightsLabel => 'LED-Ring';

  @override
  String get boardLightsDetail =>
      'Braucht USB-Strom - mit Batterien bleiben die LEDs dunkel';

  @override
  String get dartFlashesLabel => 'Treffer-Blitze';

  @override
  String get dartFlashesDetail =>
      'Die getroffene Zahl leuchtet auf, ein Flackern bei einem Fehlwurf';

  @override
  String get targetRingLabel => 'Ziel auf dem Ring';

  @override
  String get targetRingDetail =>
      'Der Checkout-Weg, deine Around-the-Clock-Zahl, das Bull';

  @override
  String get celebrationsLabel => 'Jubel';

  @override
  String get celebrationsDetail =>
      'Game on, Ton plus, 180, gewonnene Legs und Matches';

  @override
  String get languageSectionTitle => 'Sprache';

  @override
  String get languageSystemOption => 'System';

  @override
  String get languageEnglishOption => 'Englisch';

  @override
  String get languageGermanOption => 'Deutsch';

  @override
  String get rulesTitle => 'REGELN';

  @override
  String get rulesX01Objective =>
      'Start bei 301, 501 oder 701 – und dann exakt auf null, drei Darts pro Aufnahme.';

  @override
  String get rulesAtcObjective =>
      'Triff 1 bis 20 der Reihe nach, dann den äußeren Bull, dann das Bullseye. Wer zuerst einmal herum ist, gewinnt.';

  @override
  String get rulesBullingObjective =>
      'Nur Bulls zählen. Wer zuerst das Ziel erreicht, gewinnt.';

  @override
  String get rulesTrainingObjective =>
      'Nur du und die Scheibe. Kein Gegner, kein Druck – Übung wählen und werfen.';

  @override
  String get rulesFactStart => 'START';

  @override
  String get rulesFactPlayers => 'SPIELER';

  @override
  String get rulesFactPlayer => 'SPIELER';

  @override
  String get rulesFactDarts => 'DARTS PRO AUFNAHME';

  @override
  String get rulesFactStops => 'STATIONEN';

  @override
  String get rulesFactTarget => 'ZIEL';

  @override
  String get rulesFactDrills => 'ÜBUNGEN';

  @override
  String get rulesSectionIn => 'IN-REGEL';

  @override
  String get rulesSectionOut => 'OUT-REGEL';

  @override
  String get rulesSectionBust => 'BUST';

  @override
  String get rulesSectionFormat => 'MATCH-FORMAT';

  @override
  String get rulesSectionRoute => 'DIE STRECKE';

  @override
  String get rulesSectionVariant => 'VARIANTE';

  @override
  String get rulesSectionScoring => 'PUNKTE';

  @override
  String get rulesSectionDrills => 'ÜBUNGEN';

  @override
  String get rulesSectionExamples => 'BEISPIELE';

  @override
  String get rulesLegendIn => 'LEUCHTENDE FELDER ERÖFFNEN';

  @override
  String get rulesLegendOut => 'LEUCHTENDE FELDER BEENDEN EIN LEG';

  @override
  String get rulesLegendAtc => 'LEUCHTENDE FELDER SPIELEN DIE 20 FREI';

  @override
  String get rulesLegendBulling => 'NUR DIE LEUCHTENDEN BULLS ZÄHLEN';

  @override
  String get rulesLegendCheckout => 'LEUCHTENDE FELDER BEENDEN';

  @override
  String get rulesInStraight => 'Jeder Dart zählt, schon ab dem ersten Wurf.';

  @override
  String get rulesInDouble =>
      'Nichts zählt, bis du ein Doppel triffst. Dieses Doppel eröffnet deine Punktzahl und zählt mit.';

  @override
  String get rulesInMaster =>
      'Nichts zählt, bis du ein Doppel oder Triple triffst. Dieser Dart eröffnet deine Punktzahl und zählt mit.';

  @override
  String get rulesOutStraight =>
      'Jeder Dart, der dich exakt auf null bringt, gewinnt das Leg.';

  @override
  String get rulesOutDouble =>
      'Nur ein Doppel – oder das Bullseye – bringt dich auf null.';

  @override
  String get rulesOutMaster =>
      'Ein Doppel, ein Triple oder das Bullseye bringt dich auf null.';

  @override
  String get rulesBustTitle => 'EINE AUFNAHME IST BUST, WENN';

  @override
  String get rulesBustOvershoot => 'du mehr wirfst, als du noch übrig hast.';

  @override
  String get rulesBustNoFinish =>
      'du null erreichst, aber nicht mit einem Dart, den die Out-Regel erlaubt.';

  @override
  String get rulesBustOneLeft =>
      'bei Double- oder Master-out genau 1 übrig bleibt – das kann kein Dart beenden.';

  @override
  String get rulesBustReset =>
      'Der Rest der Aufnahme verfällt, und deine Punktzahl springt auf den Stand vor der Aufnahme zurück.';

  @override
  String get rulesFormatBestOf => 'BEST OF';

  @override
  String rulesFormatFirstTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Wer zuerst $count Legs holt',
      one: 'Wer zuerst 1 Leg holt',
    );
    return '$_temp0';
  }

  @override
  String get rulesFormatGroup =>
      'Bei 3 oder 4 Spielern ist keine Mehrheit garantiert – das Match läuft weiter, bis jemand so weit ist.';

  @override
  String get rulesAtcRouteHint =>
      'Eine Station nach der anderen: Triff deine Zahl, um zur nächsten weiterzuziehen.';

  @override
  String get rulesAtcAnyPart =>
      'Einfach, Doppel oder Triple – jedes Feld der Zahl zählt.';

  @override
  String get rulesAtcMasters => 'Nur Doppel oder Triple der Zahl zählen.';

  @override
  String get rulesAtcDoublesOnly => 'Nur das Doppel der Zahl zählt.';

  @override
  String get rulesAtcBullsNote =>
      'Die beiden Bull-Stationen brauchen immer genau diesen Bull, egal welche Variante.';

  @override
  String get rulesBullseyeTwo =>
      'Das Bullseye zählt 2. Ruhige Legs, mehr Darts.';

  @override
  String get rulesBullseyeThree =>
      'Das Bullseye zählt 3. Ein starker Dart kann das Leg drehen.';

  @override
  String get rulesBullingOuterBull => 'ÄUSSERER BULL';

  @override
  String get rulesBullingBullseye => 'BULLSEYE';

  @override
  String get rulesBullingEverythingElse => 'ALLES ANDERE';

  @override
  String get rulesBullingInstantTitle => 'SOFORT GEWONNEN';

  @override
  String get rulesBullingInstant =>
      'Das Leg endet in dem Moment, in dem du das Ziel erreichst – auch mitten in der Aufnahme. Darts danach zählen nicht.';

  @override
  String get rulesBullingNoBust =>
      'Über das Ziel hinaus ist kein Problem – beim Bulling gibt es keinen Bust.';

  @override
  String get rulesTrainingFreeBody =>
      'Kein Ziel und keine Gewinnbedingung. Werfen und die eigenen Zahlen im Blick behalten.';

  @override
  String get rulesTrainingCheckoutBody =>
      'Startpunktzahl wählen und unter Double-out beenden, nach derselben Regel wie ein X01-Leg. Der Checkout-Weg bleibt die ganze Zeit sichtbar.';

  @override
  String get rulesStatTotal => 'GESAMT';

  @override
  String get rulesOutcomeCheckout => 'GAME SHOT';

  @override
  String get rulesOutcomeNextStop => 'NÄCHSTE STATION';

  @override
  String get rulesOutcomeWin => 'LEG GEWONNEN';

  @override
  String rulesExampleLeft(int remaining) {
    return 'NOCH $remaining';
  }

  @override
  String get rulesExampleDoubleOut => 'DOUBLE-OUT';

  @override
  String get rulesExampleCheckoutNote => 'D20 ist ein Doppel: direkt auf null.';

  @override
  String get rulesExampleNoDoubleNote =>
      'Null – aber der letzte Dart war ein Einfach, also zählt es nicht.';

  @override
  String get rulesExampleOvershootNote =>
      '34 ist mehr als 32. Zurück auf 32 für die nächste Aufnahme.';

  @override
  String rulesExampleAtcOn(String stop, String variant) {
    return 'AUF $stop · $variant';
  }

  @override
  String get rulesExampleAtcNote =>
      'Bei Masters spielt das Einfach die 5 nicht frei. Das Triple schon.';

  @override
  String rulesExampleBulling(int score, int target) {
    return '$score VON $target';
  }

  @override
  String get rulesExampleBullingNote =>
      'Das Bullseye bringt dich über 21 – der dritte Dart wird nie geworfen.';

  @override
  String get rulesBoardSemantics =>
      'Dartscheibe, auf der die zählenden Felder leuchten';

  @override
  String get rulesX01Title => 'X01 REGELN';

  @override
  String get rulesAtcTitle => 'AROUND THE CLOCK REGELN';

  @override
  String get rulesBullingTitle => 'BULLING REGELN';

  @override
  String get rulesTrainingTitle => 'TRAINING REGELN';

  @override
  String get rulesX01Overview =>
      'Auf null herunterspielen und mit einem Doppel beenden';

  @override
  String get rulesAtcOverview =>
      'Jede Zahl der Reihe nach freispielen, dann beide Bulls';

  @override
  String get rulesBullingOverview =>
      'Wer zuerst das Ziel per Bulls erreicht, gewinnt';

  @override
  String get rulesTrainingOverview =>
      'Freies Training oder Checkout-Übungen, solo';

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
  String boardConnectedNamedTooltip(String name) {
    return 'Verbunden mit $name - tippen zum Trennen';
  }

  @override
  String get boardRetryingTooltip =>
      'Board verloren - verbinde neu. Tippen, um es jetzt zu versuchen';

  @override
  String get bluetoothOffTooltip =>
      'Bluetooth ist aus - tippen zum Einschalten';

  @override
  String get bluetoothUnauthorizedTooltip =>
      'Bluetooth-Berechtigung nötig - tippen, um erneut zu fragen';

  @override
  String get bluetoothUnsupportedTooltip =>
      'Dieses Gerät hat kein Bluetooth Low Energy';

  @override
  String get turnOnBluetoothInSettings =>
      'Schalte Bluetooth in den Systemeinstellungen ein, um das Board zu verbinden';

  @override
  String boardConnectedToast(String name) {
    return 'Board verbunden: $name';
  }

  @override
  String get boardConnectedToastUnnamed => 'Board verbunden';

  @override
  String get boardLostToast => 'Board-Verbindung verloren - verbinde neu…';

  @override
  String get bluetoothOffToast =>
      'Bluetooth ist aus - schalte es ein, um das Board zu verbinden';

  @override
  String get boardSectionTitle => 'Board';

  @override
  String get autoConnectLabel => 'Automatisch verbinden';

  @override
  String get autoConnectDetail =>
      'Beim App-Start und immer, wenn die App wieder in den Vordergrund kommt';

  @override
  String get forgetBoardLabel => 'Board vergessen';

  @override
  String get forgetBoardDetail =>
      'Die nächste Verbindung sucht wieder nach einem Board';

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
  String get checkoutNextDart => 'nächster Dart';

  @override
  String get checkoutOr => 'oder';

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
    return '$darts Darts · $average Schnitt';
  }

  @override
  String get aimLabel => 'ZIEL';

  @override
  String get remainingLabel => 'REST';

  @override
  String get figureHitRate => 'TREFFERQUOTE';

  @override
  String get figureReached => 'ERREICHT';

  @override
  String get figurePoints => 'PUNKTE';

  @override
  String dartsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Darts',
      one: '1 Dart',
    );
    return '$_temp0';
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

  @override
  String get updatesSectionTitle => 'Updates';

  @override
  String updateCurrentVersion(String version) {
    return 'Version $version';
  }

  @override
  String get updateAutoCheckLabel => 'Nach Updates suchen';

  @override
  String get updateAutoCheckDetail =>
      'Fragt beim Start auf GitHub nach einer neueren Version';

  @override
  String get updateCheckNowButton => 'JETZT PRÜFEN';

  @override
  String get updateCheckingStatus => 'Suche…';

  @override
  String get updateUpToDateStatus => 'Chalk ist aktuell';

  @override
  String get updateCheckFailedStatus => 'GitHub nicht erreichbar';

  @override
  String get updateAvailableEyebrow => 'UPDATE';

  @override
  String updateAvailableTitle(String version) {
    return 'Chalk $version ist verfügbar';
  }

  @override
  String get updateAndroidDetail =>
      'Lädt es herunter und installiert es – alle Spiele bleiben erhalten';

  @override
  String get updateWindowsDetail =>
      'Öffnet die Release-Seite zum Herunterladen';

  @override
  String get updateInstallButton => 'AKTUALISIEREN';

  @override
  String get updateDownloadButton => 'HERUNTERLADEN';

  @override
  String get updateDownloadingStatus => 'Wird heruntergeladen…';

  @override
  String get updateInstallingStatus =>
      'Im geöffneten Android-Installer abschließen';

  @override
  String get updatePermissionStatus =>
      'Erlaube Chalk, Apps zu installieren, und komm dann zurück';

  @override
  String get updateDownloadFailedStatus => 'Download fehlgeschlagen';

  @override
  String get updateInstallFailedStatus =>
      'Update konnte nicht gestartet werden';

  @override
  String get updateRetryButton => 'ERNEUT VERSUCHEN';

  @override
  String get updateDismissTooltip => 'Ausblenden';
}
