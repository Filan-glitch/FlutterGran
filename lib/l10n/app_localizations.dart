import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @selectGameModeTitle.
  ///
  /// In en, this message translates to:
  /// **'SELECT GAME MODE'**
  String get selectGameModeTitle;

  /// No description provided for @comingSoonLabel.
  ///
  /// In en, this message translates to:
  /// **'COMING SOON'**
  String get comingSoonLabel;

  /// No description provided for @moreModesComingLabel.
  ///
  /// In en, this message translates to:
  /// **'MORE MODES COMING'**
  String get moreModesComingLabel;

  /// No description provided for @x01SetupTitle.
  ///
  /// In en, this message translates to:
  /// **'X01 SETUP'**
  String get x01SetupTitle;

  /// No description provided for @startScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Start score'**
  String get startScoreLabel;

  /// No description provided for @bestOfLabel.
  ///
  /// In en, this message translates to:
  /// **'Best of'**
  String get bestOfLabel;

  /// No description provided for @firstToLabel.
  ///
  /// In en, this message translates to:
  /// **'First to'**
  String get firstToLabel;

  /// No description provided for @inRuleLabel.
  ///
  /// In en, this message translates to:
  /// **'In'**
  String get inRuleLabel;

  /// No description provided for @outRuleLabel.
  ///
  /// In en, this message translates to:
  /// **'Out'**
  String get outRuleLabel;

  /// No description provided for @playersLabel.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get playersLabel;

  /// No description provided for @tapToAddPlayers.
  ///
  /// In en, this message translates to:
  /// **'tap to add, in throwing order'**
  String get tapToAddPlayers;

  /// No description provided for @seatsOfMax.
  ///
  /// In en, this message translates to:
  /// **'{seated} of {max}'**
  String seatsOfMax(int seated, int max);

  /// No description provided for @addPlayerFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Add a player'**
  String get addPlayerFieldLabel;

  /// No description provided for @couldNotLoadPlayers.
  ///
  /// In en, this message translates to:
  /// **'Could not load players: {error}'**
  String couldNotLoadPlayers(String error);

  /// No description provided for @noPlayersYet.
  ///
  /// In en, this message translates to:
  /// **'No players yet. Add the first one above.'**
  String get noPlayersYet;

  /// No description provided for @removePlayerTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}'**
  String removePlayerTooltip(String name);

  /// No description provided for @pickAtLeastOnePlayer.
  ///
  /// In en, this message translates to:
  /// **'PICK AT LEAST ONE PLAYER'**
  String get pickAtLeastOnePlayer;

  /// No description provided for @startLeg.
  ///
  /// In en, this message translates to:
  /// **'START LEG'**
  String get startLeg;

  /// No description provided for @startBestOf.
  ///
  /// In en, this message translates to:
  /// **'START BEST OF {legs}'**
  String startBestOf(int legs);

  /// No description provided for @x01RuleStraight.
  ///
  /// In en, this message translates to:
  /// **'Straight'**
  String get x01RuleStraight;

  /// No description provided for @x01RuleDouble.
  ///
  /// In en, this message translates to:
  /// **'Double'**
  String get x01RuleDouble;

  /// No description provided for @x01RuleMaster.
  ///
  /// In en, this message translates to:
  /// **'Master'**
  String get x01RuleMaster;

  /// No description provided for @rosterTitle.
  ///
  /// In en, this message translates to:
  /// **'ROSTER'**
  String get rosterTitle;

  /// No description provided for @removedPlayerSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Removed {name}'**
  String removedPlayerSnackbar(String name);

  /// No description provided for @undoLabel.
  ///
  /// In en, this message translates to:
  /// **'UNDO'**
  String get undoLabel;

  /// No description provided for @playButton.
  ///
  /// In en, this message translates to:
  /// **'PLAY'**
  String get playButton;

  /// No description provided for @trainingMenuLabel.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get trainingMenuLabel;

  /// No description provided for @rulesMenuLabel.
  ///
  /// In en, this message translates to:
  /// **'Rules'**
  String get rulesMenuLabel;

  /// No description provided for @statisticsMenuLabel.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statisticsMenuLabel;

  /// No description provided for @rosterMenuLabel.
  ///
  /// In en, this message translates to:
  /// **'Roster'**
  String get rosterMenuLabel;

  /// No description provided for @settingsMenuLabel.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsMenuLabel;

  /// No description provided for @legInProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'LEG IN PROGRESS'**
  String get legInProgressLabel;

  /// No description provided for @resumeLabel.
  ///
  /// In en, this message translates to:
  /// **'RESUME'**
  String get resumeLabel;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get settingsTitle;

  /// No description provided for @soundSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get soundSectionTitle;

  /// No description provided for @cuesAndCommentaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Cues and commentary'**
  String get cuesAndCommentaryLabel;

  /// No description provided for @cuesAndCommentaryDetail.
  ///
  /// In en, this message translates to:
  /// **'A click per dart, a buzz on a bust, a fanfare for a 180'**
  String get cuesAndCommentaryDetail;

  /// No description provided for @spokenTotalsLabel.
  ///
  /// In en, this message translates to:
  /// **'Spoken totals'**
  String get spokenTotalsLabel;

  /// No description provided for @spokenTotalsDetail.
  ///
  /// In en, this message translates to:
  /// **'Each turn read out loud'**
  String get spokenTotalsDetail;

  /// No description provided for @boardLightsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Board lights'**
  String get boardLightsSectionTitle;

  /// No description provided for @boardLightsLabel.
  ///
  /// In en, this message translates to:
  /// **'LED ring'**
  String get boardLightsLabel;

  /// No description provided for @boardLightsDetail.
  ///
  /// In en, this message translates to:
  /// **'Needs the board on USB power - the LEDs stay dark on batteries'**
  String get boardLightsDetail;

  /// No description provided for @dartFlashesLabel.
  ///
  /// In en, this message translates to:
  /// **'Dart flashes'**
  String get dartFlashesLabel;

  /// No description provided for @dartFlashesDetail.
  ///
  /// In en, this message translates to:
  /// **'The number you hit lights up, a flicker for a miss'**
  String get dartFlashesDetail;

  /// No description provided for @targetRingLabel.
  ///
  /// In en, this message translates to:
  /// **'Target on the ring'**
  String get targetRingLabel;

  /// No description provided for @targetRingDetail.
  ///
  /// In en, this message translates to:
  /// **'The checkout route, your Around the Clock number, the bull'**
  String get targetRingDetail;

  /// No description provided for @celebrationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Celebrations'**
  String get celebrationsLabel;

  /// No description provided for @celebrationsDetail.
  ///
  /// In en, this message translates to:
  /// **'Game on, ton plus, 180, legs and matches won'**
  String get celebrationsDetail;

  /// No description provided for @languageSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSectionTitle;

  /// No description provided for @languageSystemOption.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystemOption;

  /// No description provided for @languageEnglishOption.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglishOption;

  /// No description provided for @languageGermanOption.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get languageGermanOption;

  /// No description provided for @rulesTitle.
  ///
  /// In en, this message translates to:
  /// **'RULES'**
  String get rulesTitle;

  /// No description provided for @rulesX01Objective.
  ///
  /// In en, this message translates to:
  /// **'Race to exactly zero. Each player starts at the chosen score — 301, 501, or 701 — and works it down with three darts a turn.'**
  String get rulesX01Objective;

  /// No description provided for @rulesX01InRule.
  ///
  /// In en, this message translates to:
  /// **'In rule sets what starts your scoring: Straight — any dart counts right away. Double — darts before your first double score nothing; that double both opens your score and counts. Master — a double or a triple opens it.'**
  String get rulesX01InRule;

  /// No description provided for @rulesX01OutRule.
  ///
  /// In en, this message translates to:
  /// **'Out rule sets what can finish a leg: Straight — any dart can take you out on exactly zero. Double — only a double finishes. Master — a double or a triple finishes. Overshooting zero, landing on it without a qualifying finish, or leaving exactly 1 under double or master out all bust the turn — your score resets to what it was when the turn began.'**
  String get rulesX01OutRule;

  /// No description provided for @rulesX01Format.
  ///
  /// In en, this message translates to:
  /// **'A match is played over several legs — best of 1, 3, 5, or 7. With two players it\'s first to more than half; with three or four it\'s simply first to that many legs, since a majority isn\'t guaranteed to fall within them.'**
  String get rulesX01Format;

  /// No description provided for @rulesAtcObjective.
  ///
  /// In en, this message translates to:
  /// **'Clear 22 stops in order — 1 through 20, then the outer bull, then the bullseye. First to clear them all wins.'**
  String get rulesAtcObjective;

  /// No description provided for @rulesAtcVariant.
  ///
  /// In en, this message translates to:
  /// **'Variant sets what clears a numbered stop (the two bull stops are unaffected): Any part — single, double, or triple all count. Masters — double or triple only. Doubles only — double only.'**
  String get rulesAtcVariant;

  /// No description provided for @rulesBullingObjective.
  ///
  /// In en, this message translates to:
  /// **'First to reach or pass the target score — 21, 31, or 41 — by hitting bulls wins. The outer bull is worth 1 point; the inner bull (bullseye) is worth 2 or 3, set at setup. Everything else scores nothing.'**
  String get rulesBullingObjective;

  /// No description provided for @rulesBullingValue.
  ///
  /// In en, this message translates to:
  /// **'A leg ends the moment a player reaches target, even mid-turn — any darts thrown after that in the same turn don\'t count.'**
  String get rulesBullingValue;

  /// No description provided for @rulesTrainingFreePractice.
  ///
  /// In en, this message translates to:
  /// **'Free practice — no target or win condition. Just throw; the session tracks your total, best turn, 180 count, and three-dart average.'**
  String get rulesTrainingFreePractice;

  /// No description provided for @rulesTrainingCheckoutPractice.
  ///
  /// In en, this message translates to:
  /// **'Checkout practice — pick a start score and practice finishing it under double-out, the same rule as an X01 leg, with the checkout suggestion shown throughout.'**
  String get rulesTrainingCheckoutPractice;

  /// No description provided for @rulesX01Title.
  ///
  /// In en, this message translates to:
  /// **'X01 RULES'**
  String get rulesX01Title;

  /// No description provided for @rulesAtcTitle.
  ///
  /// In en, this message translates to:
  /// **'AROUND THE CLOCK RULES'**
  String get rulesAtcTitle;

  /// No description provided for @rulesBullingTitle.
  ///
  /// In en, this message translates to:
  /// **'BULLING RULES'**
  String get rulesBullingTitle;

  /// No description provided for @rulesTrainingTitle.
  ///
  /// In en, this message translates to:
  /// **'TRAINING RULES'**
  String get rulesTrainingTitle;

  /// No description provided for @rulesX01Overview.
  ///
  /// In en, this message translates to:
  /// **'Race down to zero and check out on a double'**
  String get rulesX01Overview;

  /// No description provided for @rulesAtcOverview.
  ///
  /// In en, this message translates to:
  /// **'Clear every number in order, then both bulls'**
  String get rulesAtcOverview;

  /// No description provided for @rulesBullingOverview.
  ///
  /// In en, this message translates to:
  /// **'First to the target by hitting bulls wins'**
  String get rulesBullingOverview;

  /// No description provided for @rulesTrainingOverview.
  ///
  /// In en, this message translates to:
  /// **'Free practice or checkout drills, solo'**
  String get rulesTrainingOverview;

  /// No description provided for @atcSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'AROUND THE CLOCK SETUP'**
  String get atcSetupTitle;

  /// No description provided for @variantLabel.
  ///
  /// In en, this message translates to:
  /// **'Variant'**
  String get variantLabel;

  /// No description provided for @atcVariantAnyPart.
  ///
  /// In en, this message translates to:
  /// **'ANY PART'**
  String get atcVariantAnyPart;

  /// No description provided for @atcVariantMasters.
  ///
  /// In en, this message translates to:
  /// **'MASTERS'**
  String get atcVariantMasters;

  /// No description provided for @atcVariantDoublesOnly.
  ///
  /// In en, this message translates to:
  /// **'DOUBLES ONLY'**
  String get atcVariantDoublesOnly;

  /// No description provided for @bullingSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'BULLING SETUP'**
  String get bullingSetupTitle;

  /// No description provided for @bullseyeValueSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Bullseye value'**
  String get bullseyeValueSectionLabel;

  /// No description provided for @bullseyeValueTwo.
  ///
  /// In en, this message translates to:
  /// **'BULLSEYE = 2'**
  String get bullseyeValueTwo;

  /// No description provided for @bullseyeValueThree.
  ///
  /// In en, this message translates to:
  /// **'BULLSEYE = 3'**
  String get bullseyeValueThree;

  /// No description provided for @targetLabel.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get targetLabel;

  /// No description provided for @trainingSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'TRAINING'**
  String get trainingSetupTitle;

  /// No description provided for @drillLabel.
  ///
  /// In en, this message translates to:
  /// **'Drill'**
  String get drillLabel;

  /// No description provided for @freePracticeLabel.
  ///
  /// In en, this message translates to:
  /// **'FREE PRACTICE'**
  String get freePracticeLabel;

  /// No description provided for @freePracticeTagline.
  ///
  /// In en, this message translates to:
  /// **'throw and see what you hit'**
  String get freePracticeTagline;

  /// No description provided for @checkoutPracticeLabel.
  ///
  /// In en, this message translates to:
  /// **'CHECKOUT PRACTICE'**
  String get checkoutPracticeLabel;

  /// No description provided for @checkoutPracticeTagline.
  ///
  /// In en, this message translates to:
  /// **'pick a score, practice finishing it'**
  String get checkoutPracticeTagline;

  /// No description provided for @startButton.
  ///
  /// In en, this message translates to:
  /// **'START'**
  String get startButton;

  /// No description provided for @connectBoardTooltip.
  ///
  /// In en, this message translates to:
  /// **'Connect board'**
  String get connectBoardTooltip;

  /// No description provided for @boardConnectedTooltip.
  ///
  /// In en, this message translates to:
  /// **'Board connected'**
  String get boardConnectedTooltip;

  /// No description provided for @connectingToBoardTooltip.
  ///
  /// In en, this message translates to:
  /// **'Connecting to board…'**
  String get connectingToBoardTooltip;

  /// No description provided for @boardDisconnectedTooltip.
  ///
  /// In en, this message translates to:
  /// **'Board disconnected'**
  String get boardDisconnectedTooltip;

  /// No description provided for @boardConnectedNamedTooltip.
  ///
  /// In en, this message translates to:
  /// **'Connected to {name} - tap to disconnect'**
  String boardConnectedNamedTooltip(String name);

  /// No description provided for @boardRetryingTooltip.
  ///
  /// In en, this message translates to:
  /// **'Board lost - reconnecting. Tap to try now'**
  String get boardRetryingTooltip;

  /// No description provided for @bluetoothOffTooltip.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth is off - tap to turn it on'**
  String get bluetoothOffTooltip;

  /// No description provided for @bluetoothUnauthorizedTooltip.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth permission needed - tap to ask again'**
  String get bluetoothUnauthorizedTooltip;

  /// No description provided for @bluetoothUnsupportedTooltip.
  ///
  /// In en, this message translates to:
  /// **'This device has no Bluetooth Low Energy'**
  String get bluetoothUnsupportedTooltip;

  /// No description provided for @turnOnBluetoothInSettings.
  ///
  /// In en, this message translates to:
  /// **'Turn on Bluetooth in the system settings to connect the board'**
  String get turnOnBluetoothInSettings;

  /// No description provided for @boardConnectedToast.
  ///
  /// In en, this message translates to:
  /// **'Board connected: {name}'**
  String boardConnectedToast(String name);

  /// No description provided for @boardConnectedToastUnnamed.
  ///
  /// In en, this message translates to:
  /// **'Board connected'**
  String get boardConnectedToastUnnamed;

  /// No description provided for @boardLostToast.
  ///
  /// In en, this message translates to:
  /// **'Board connection lost - reconnecting…'**
  String get boardLostToast;

  /// No description provided for @bluetoothOffToast.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth is off - turn it on to connect the board'**
  String get bluetoothOffToast;

  /// No description provided for @boardSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Board'**
  String get boardSectionTitle;

  /// No description provided for @autoConnectLabel.
  ///
  /// In en, this message translates to:
  /// **'Connect automatically'**
  String get autoConnectLabel;

  /// No description provided for @autoConnectDetail.
  ///
  /// In en, this message translates to:
  /// **'When the app starts, and whenever it comes back to the front'**
  String get autoConnectDetail;

  /// No description provided for @forgetBoardLabel.
  ///
  /// In en, this message translates to:
  /// **'Forget board'**
  String get forgetBoardLabel;

  /// No description provided for @forgetBoardDetail.
  ///
  /// In en, this message translates to:
  /// **'The next connection searches for a board again'**
  String get forgetBoardDetail;

  /// No description provided for @ringSingle.
  ///
  /// In en, this message translates to:
  /// **'SINGLE'**
  String get ringSingle;

  /// No description provided for @ringDouble.
  ///
  /// In en, this message translates to:
  /// **'DOUBLE'**
  String get ringDouble;

  /// No description provided for @ringTreble.
  ///
  /// In en, this message translates to:
  /// **'TREBLE'**
  String get ringTreble;

  /// No description provided for @keyBullLabel.
  ///
  /// In en, this message translates to:
  /// **'BULL'**
  String get keyBullLabel;

  /// No description provided for @keyMissLabel.
  ///
  /// In en, this message translates to:
  /// **'MISS'**
  String get keyMissLabel;

  /// No description provided for @semanticDoubleKey.
  ///
  /// In en, this message translates to:
  /// **'double {label}'**
  String semanticDoubleKey(String label);

  /// No description provided for @semanticTrebleKey.
  ///
  /// In en, this message translates to:
  /// **'treble {label}'**
  String semanticTrebleKey(String label);

  /// No description provided for @playerFallbackName.
  ///
  /// In en, this message translates to:
  /// **'Player {id}'**
  String playerFallbackName(int id);

  /// No description provided for @leaveLegTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave this leg?'**
  String get leaveLegTitle;

  /// No description provided for @leaveLegBody.
  ///
  /// In en, this message translates to:
  /// **'Your darts are saved. Resume from the main menu whenever you like.'**
  String get leaveLegBody;

  /// No description provided for @stayButton.
  ///
  /// In en, this message translates to:
  /// **'STAY'**
  String get stayButton;

  /// No description provided for @leaveButton.
  ///
  /// In en, this message translates to:
  /// **'LEAVE'**
  String get leaveButton;

  /// No description provided for @hideManualEntryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Hide manual entry'**
  String get hideManualEntryTooltip;

  /// No description provided for @enterScoreByHandTooltip.
  ///
  /// In en, this message translates to:
  /// **'Enter a score by hand'**
  String get enterScoreByHandTooltip;

  /// No description provided for @undoLastDartTooltip.
  ///
  /// In en, this message translates to:
  /// **'Undo last dart'**
  String get undoLastDartTooltip;

  /// No description provided for @legsCount.
  ///
  /// In en, this message translates to:
  /// **'LEGS {count}'**
  String legsCount(int count);

  /// No description provided for @avgDash.
  ///
  /// In en, this message translates to:
  /// **'AVG —'**
  String get avgDash;

  /// No description provided for @avgValue.
  ///
  /// In en, this message translates to:
  /// **'AVG {value}'**
  String avgValue(String value);

  /// No description provided for @bustLabel.
  ///
  /// In en, this message translates to:
  /// **'BUST'**
  String get bustLabel;

  /// No description provided for @wrongButton.
  ///
  /// In en, this message translates to:
  /// **'WRONG'**
  String get wrongButton;

  /// No description provided for @finishButton.
  ///
  /// In en, this message translates to:
  /// **'FINISH'**
  String get finishButton;

  /// No description provided for @nextPlayerButton.
  ///
  /// In en, this message translates to:
  /// **'NEXT PLAYER'**
  String get nextPlayerButton;

  /// No description provided for @orPressBoardButton.
  ///
  /// In en, this message translates to:
  /// **'or press the board button'**
  String get orPressBoardButton;

  /// No description provided for @legWonLabel.
  ///
  /// In en, this message translates to:
  /// **'LEG WON'**
  String get legWonLabel;

  /// No description provided for @throwLegNumber.
  ///
  /// In en, this message translates to:
  /// **'THROW LEG {number}'**
  String throwLegNumber(int number);

  /// No description provided for @standingLegsToWinIt.
  ///
  /// In en, this message translates to:
  /// **'{tally} · {left} {left, plural, =1{LEG} other{LEGS}} TO WIN IT'**
  String standingLegsToWinIt(String tally, int left);

  /// No description provided for @matchWonLabel.
  ///
  /// In en, this message translates to:
  /// **'MATCH WON'**
  String get matchWonLabel;

  /// No description provided for @earlierLegsCouldNotBeRead.
  ///
  /// In en, this message translates to:
  /// **'THE EARLIER LEGS COULD NOT BE READ'**
  String get earlierLegsCouldNotBeRead;

  /// No description provided for @rematchButton.
  ///
  /// In en, this message translates to:
  /// **'REMATCH'**
  String get rematchButton;

  /// No description provided for @backToSetupButton.
  ///
  /// In en, this message translates to:
  /// **'BACK TO SETUP'**
  String get backToSetupButton;

  /// No description provided for @figureAverage.
  ///
  /// In en, this message translates to:
  /// **'AVERAGE'**
  String get figureAverage;

  /// No description provided for @figureFirstNine.
  ///
  /// In en, this message translates to:
  /// **'FIRST NINE'**
  String get figureFirstNine;

  /// No description provided for @figure180s.
  ///
  /// In en, this message translates to:
  /// **'180s'**
  String get figure180s;

  /// No description provided for @figureBestOut.
  ///
  /// In en, this message translates to:
  /// **'BEST OUT'**
  String get figureBestOut;

  /// No description provided for @figureBestLeg.
  ///
  /// In en, this message translates to:
  /// **'BEST LEG'**
  String get figureBestLeg;

  /// No description provided for @checkoutLabel.
  ///
  /// In en, this message translates to:
  /// **'CHECKOUT'**
  String get checkoutLabel;

  /// No description provided for @scoreArrow.
  ///
  /// In en, this message translates to:
  /// **'{before} → {after}'**
  String scoreArrow(int before, int after);

  /// No description provided for @legWonStatsX01.
  ///
  /// In en, this message translates to:
  /// **'{darts} darts · {average} average'**
  String legWonStatsX01(int darts, String average);

  /// No description provided for @throwWhenReady.
  ///
  /// In en, this message translates to:
  /// **'THROW WHEN READY'**
  String get throwWhenReady;

  /// No description provided for @stopsClearedLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{NOTHING CLEARED} =1{1 STOP CLEARED} other{{count} STOPS CLEARED}}'**
  String stopsClearedLabel(int count);

  /// No description provided for @nowOnStop.
  ///
  /// In en, this message translates to:
  /// **'now on {stop}'**
  String nowOnStop(String stop);

  /// No description provided for @dartsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} darts'**
  String dartsCount(int count);

  /// No description provided for @playAgainButton.
  ///
  /// In en, this message translates to:
  /// **'PLAY AGAIN'**
  String get playAgainButton;

  /// No description provided for @firstToTarget.
  ///
  /// In en, this message translates to:
  /// **'FIRST TO {target}'**
  String firstToTarget(int target);

  /// No description provided for @ofTarget.
  ///
  /// In en, this message translates to:
  /// **'of {target}'**
  String ofTarget(int target);

  /// No description provided for @turnScoredLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{NOTHING SCORED} =1{1 POINT SCORED} other{{count} POINTS SCORED}}'**
  String turnScoredLabel(int count);

  /// No description provided for @nowOnScore.
  ///
  /// In en, this message translates to:
  /// **'now on {score}'**
  String nowOnScore(int score);

  /// No description provided for @legWonStatsBulling.
  ///
  /// In en, this message translates to:
  /// **'{points} points · {darts} darts'**
  String legWonStatsBulling(int points, int darts);

  /// No description provided for @statisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'STATISTICS'**
  String get statisticsTitle;

  /// No description provided for @noPlayersYetHeadline.
  ///
  /// In en, this message translates to:
  /// **'No players yet'**
  String get noPlayersYetHeadline;

  /// No description provided for @noPlayersYetDetail.
  ///
  /// In en, this message translates to:
  /// **'Add one on the setup screen to start a record.'**
  String get noPlayersYetDetail;

  /// No description provided for @noLegsYetHeadline.
  ///
  /// In en, this message translates to:
  /// **'No legs yet'**
  String get noLegsYetHeadline;

  /// No description provided for @noLegsYetDetail.
  ///
  /// In en, this message translates to:
  /// **'Play a leg and every dart in it lands here.'**
  String get noLegsYetDetail;

  /// No description provided for @x01Label.
  ///
  /// In en, this message translates to:
  /// **'X01'**
  String get x01Label;

  /// No description provided for @aroundTheClockLabel.
  ///
  /// In en, this message translates to:
  /// **'AROUND THE CLOCK'**
  String get aroundTheClockLabel;

  /// No description provided for @bullingLabel.
  ///
  /// In en, this message translates to:
  /// **'BULLING'**
  String get bullingLabel;

  /// No description provided for @threeDartAverageLabel.
  ///
  /// In en, this message translates to:
  /// **'Three-dart average'**
  String get threeDartAverageLabel;

  /// No description provided for @dartsOverLegs.
  ///
  /// In en, this message translates to:
  /// **'{darts} darts over {legs} {legs, plural, one{leg} other{legs}}'**
  String dartsOverLegs(int darts, int legs);

  /// No description provided for @scoringSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Scoring'**
  String get scoringSectionTitle;

  /// No description provided for @firstNineAverageRow.
  ///
  /// In en, this message translates to:
  /// **'First 9 average'**
  String get firstNineAverageRow;

  /// No description provided for @bestTurnRow.
  ///
  /// In en, this message translates to:
  /// **'Best turn'**
  String get bestTurnRow;

  /// No description provided for @oneFortyPlusRow.
  ///
  /// In en, this message translates to:
  /// **'140+'**
  String get oneFortyPlusRow;

  /// No description provided for @oneHundredPlusRow.
  ///
  /// In en, this message translates to:
  /// **'100+'**
  String get oneHundredPlusRow;

  /// No description provided for @sixtyPlusRow.
  ///
  /// In en, this message translates to:
  /// **'60+'**
  String get sixtyPlusRow;

  /// No description provided for @finishingSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Finishing'**
  String get finishingSectionTitle;

  /// No description provided for @ruleCheckoutRow.
  ///
  /// In en, this message translates to:
  /// **'{rule} checkout'**
  String ruleCheckoutRow(String rule);

  /// No description provided for @ruleDartsAtFinishRow.
  ///
  /// In en, this message translates to:
  /// **'{rule} darts at finish'**
  String ruleDartsAtFinishRow(String rule);

  /// No description provided for @bestCheckoutRow.
  ///
  /// In en, this message translates to:
  /// **'Best checkout'**
  String get bestCheckoutRow;

  /// No description provided for @bestLegRow.
  ///
  /// In en, this message translates to:
  /// **'Best leg'**
  String get bestLegRow;

  /// No description provided for @legsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Legs'**
  String get legsSectionTitle;

  /// No description provided for @wonRatio.
  ///
  /// In en, this message translates to:
  /// **'{won} of {played}'**
  String wonRatio(int won, int played);

  /// No description provided for @wonLabel.
  ///
  /// In en, this message translates to:
  /// **'Won'**
  String get wonLabel;

  /// No description provided for @winRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Win rate'**
  String get winRateLabel;

  /// No description provided for @matchesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get matchesSectionTitle;

  /// No description provided for @weakSpotsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Weak spots'**
  String get weakSpotsSectionTitle;

  /// No description provided for @hitRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Hit rate'**
  String get hitRateLabel;

  /// No description provided for @xOfYDarts.
  ///
  /// In en, this message translates to:
  /// **'{x} of {y} darts'**
  String xOfYDarts(int x, int y);

  /// No description provided for @pointsScoredRow.
  ///
  /// In en, this message translates to:
  /// **'Points scored'**
  String get pointsScoredRow;

  /// No description provided for @outerBullHitsRow.
  ///
  /// In en, this message translates to:
  /// **'Outer bull hits'**
  String get outerBullHitsRow;

  /// No description provided for @bullseyeHitsRow.
  ///
  /// In en, this message translates to:
  /// **'Bullseye hits'**
  String get bullseyeHitsRow;

  /// No description provided for @whereDartsLandTitle.
  ///
  /// In en, this message translates to:
  /// **'WHERE THE DARTS LAND'**
  String get whereDartsLandTitle;

  /// No description provided for @noDartsRecorded.
  ///
  /// In en, this message translates to:
  /// **'No darts recorded yet.'**
  String get noDartsRecorded;

  /// No description provided for @shadedAgainstBusiest.
  ///
  /// In en, this message translates to:
  /// **'Shaded against the busiest segment.'**
  String get shadedAgainstBusiest;

  /// No description provided for @checkoutPracticeWithScore.
  ///
  /// In en, this message translates to:
  /// **'{score} · CHECKOUT PRACTICE'**
  String checkoutPracticeWithScore(int score);

  /// No description provided for @statDarts.
  ///
  /// In en, this message translates to:
  /// **'DARTS'**
  String get statDarts;

  /// No description provided for @statAverage.
  ///
  /// In en, this message translates to:
  /// **'AVERAGE'**
  String get statAverage;

  /// No description provided for @statBestTurn.
  ///
  /// In en, this message translates to:
  /// **'BEST TURN'**
  String get statBestTurn;

  /// No description provided for @checkoutsThisSession.
  ///
  /// In en, this message translates to:
  /// **'CHECKOUTS THIS SESSION: {count}'**
  String checkoutsThisSession(int count);

  /// No description provided for @checkedOutLabel.
  ///
  /// In en, this message translates to:
  /// **'CHECKED OUT'**
  String get checkedOutLabel;

  /// No description provided for @inDartsCount.
  ///
  /// In en, this message translates to:
  /// **'in {count, plural, one{{count} dart} other{{count} darts}}'**
  String inDartsCount(int count);

  /// No description provided for @throwAgainButton.
  ///
  /// In en, this message translates to:
  /// **'THROW AGAIN'**
  String get throwAgainButton;

  /// No description provided for @doneButton.
  ///
  /// In en, this message translates to:
  /// **'DONE'**
  String get doneButton;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
