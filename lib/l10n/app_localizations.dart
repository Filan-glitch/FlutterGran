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
  /// **'Start on 301, 501 or 701 and race to exactly zero, three darts a turn.'**
  String get rulesX01Objective;

  /// No description provided for @rulesAtcObjective.
  ///
  /// In en, this message translates to:
  /// **'Hit 1 to 20 in order, then the outer bull, then the bullseye. First all the way round wins.'**
  String get rulesAtcObjective;

  /// No description provided for @rulesBullingObjective.
  ///
  /// In en, this message translates to:
  /// **'Only bulls score. First to reach the target wins.'**
  String get rulesBullingObjective;

  /// No description provided for @rulesTrainingObjective.
  ///
  /// In en, this message translates to:
  /// **'Just you and the board. No opponent, no pressure - pick a drill and throw.'**
  String get rulesTrainingObjective;

  /// No description provided for @rulesFactStart.
  ///
  /// In en, this message translates to:
  /// **'START'**
  String get rulesFactStart;

  /// No description provided for @rulesFactPlayers.
  ///
  /// In en, this message translates to:
  /// **'PLAYERS'**
  String get rulesFactPlayers;

  /// No description provided for @rulesFactPlayer.
  ///
  /// In en, this message translates to:
  /// **'PLAYER'**
  String get rulesFactPlayer;

  /// No description provided for @rulesFactDarts.
  ///
  /// In en, this message translates to:
  /// **'DARTS A TURN'**
  String get rulesFactDarts;

  /// No description provided for @rulesFactStops.
  ///
  /// In en, this message translates to:
  /// **'STOPS'**
  String get rulesFactStops;

  /// No description provided for @rulesFactTarget.
  ///
  /// In en, this message translates to:
  /// **'TARGET'**
  String get rulesFactTarget;

  /// No description provided for @rulesFactDrills.
  ///
  /// In en, this message translates to:
  /// **'DRILLS'**
  String get rulesFactDrills;

  /// No description provided for @rulesSectionIn.
  ///
  /// In en, this message translates to:
  /// **'IN RULE'**
  String get rulesSectionIn;

  /// No description provided for @rulesSectionOut.
  ///
  /// In en, this message translates to:
  /// **'OUT RULE'**
  String get rulesSectionOut;

  /// No description provided for @rulesSectionBust.
  ///
  /// In en, this message translates to:
  /// **'BUST'**
  String get rulesSectionBust;

  /// No description provided for @rulesSectionFormat.
  ///
  /// In en, this message translates to:
  /// **'MATCH FORMAT'**
  String get rulesSectionFormat;

  /// No description provided for @rulesSectionRoute.
  ///
  /// In en, this message translates to:
  /// **'THE ROUTE'**
  String get rulesSectionRoute;

  /// No description provided for @rulesSectionVariant.
  ///
  /// In en, this message translates to:
  /// **'VARIANT'**
  String get rulesSectionVariant;

  /// No description provided for @rulesSectionScoring.
  ///
  /// In en, this message translates to:
  /// **'SCORING'**
  String get rulesSectionScoring;

  /// No description provided for @rulesSectionDrills.
  ///
  /// In en, this message translates to:
  /// **'DRILLS'**
  String get rulesSectionDrills;

  /// No description provided for @rulesSectionExamples.
  ///
  /// In en, this message translates to:
  /// **'EXAMPLES'**
  String get rulesSectionExamples;

  /// No description provided for @rulesLegendIn.
  ///
  /// In en, this message translates to:
  /// **'LIT SEGMENTS OPEN YOUR SCORE'**
  String get rulesLegendIn;

  /// No description provided for @rulesLegendOut.
  ///
  /// In en, this message translates to:
  /// **'LIT SEGMENTS CAN FINISH A LEG'**
  String get rulesLegendOut;

  /// No description provided for @rulesLegendAtc.
  ///
  /// In en, this message translates to:
  /// **'LIT SEGMENTS CLEAR STOP 20'**
  String get rulesLegendAtc;

  /// No description provided for @rulesLegendBulling.
  ///
  /// In en, this message translates to:
  /// **'ONLY THE LIT BULLS SCORE'**
  String get rulesLegendBulling;

  /// No description provided for @rulesLegendCheckout.
  ///
  /// In en, this message translates to:
  /// **'LIT SEGMENTS CAN FINISH'**
  String get rulesLegendCheckout;

  /// No description provided for @rulesInStraight.
  ///
  /// In en, this message translates to:
  /// **'Every dart counts, right from the first throw.'**
  String get rulesInStraight;

  /// No description provided for @rulesInDouble.
  ///
  /// In en, this message translates to:
  /// **'Nothing counts until you hit a double. That double opens your score and counts too.'**
  String get rulesInDouble;

  /// No description provided for @rulesInMaster.
  ///
  /// In en, this message translates to:
  /// **'Nothing counts until you hit a double or a triple. That dart opens your score and counts too.'**
  String get rulesInMaster;

  /// No description provided for @rulesOutStraight.
  ///
  /// In en, this message translates to:
  /// **'Any dart that lands you on exactly zero wins the leg.'**
  String get rulesOutStraight;

  /// No description provided for @rulesOutDouble.
  ///
  /// In en, this message translates to:
  /// **'Only a double - or the bullseye - can take you to zero.'**
  String get rulesOutDouble;

  /// No description provided for @rulesOutMaster.
  ///
  /// In en, this message translates to:
  /// **'A double, a triple or the bullseye can take you to zero.'**
  String get rulesOutMaster;

  /// No description provided for @rulesBustTitle.
  ///
  /// In en, this message translates to:
  /// **'A TURN BUSTS WHEN'**
  String get rulesBustTitle;

  /// No description provided for @rulesBustOvershoot.
  ///
  /// In en, this message translates to:
  /// **'You score more than you have left.'**
  String get rulesBustOvershoot;

  /// No description provided for @rulesBustNoFinish.
  ///
  /// In en, this message translates to:
  /// **'You reach zero, but not with a dart the out rule allows.'**
  String get rulesBustNoFinish;

  /// No description provided for @rulesBustOneLeft.
  ///
  /// In en, this message translates to:
  /// **'You leave exactly 1 under double or master out - no dart can finish that.'**
  String get rulesBustOneLeft;

  /// No description provided for @rulesBustReset.
  ///
  /// In en, this message translates to:
  /// **'The rest of the turn is lost and your score goes back to where the turn started.'**
  String get rulesBustReset;

  /// No description provided for @rulesFormatBestOf.
  ///
  /// In en, this message translates to:
  /// **'BEST OF'**
  String get rulesFormatBestOf;

  /// No description provided for @rulesFormatFirstTo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{First to 1 leg} other{First to {count} legs}}'**
  String rulesFormatFirstTo(int count);

  /// No description provided for @rulesFormatGroup.
  ///
  /// In en, this message translates to:
  /// **'With 3 or 4 players nobody is guaranteed a majority, so the match runs on until someone gets there.'**
  String get rulesFormatGroup;

  /// No description provided for @rulesAtcRouteHint.
  ///
  /// In en, this message translates to:
  /// **'One stop at a time: hit your number to move on to the next one.'**
  String get rulesAtcRouteHint;

  /// No description provided for @rulesAtcAnyPart.
  ///
  /// In en, this message translates to:
  /// **'Single, double or triple - any part of the number counts.'**
  String get rulesAtcAnyPart;

  /// No description provided for @rulesAtcMasters.
  ///
  /// In en, this message translates to:
  /// **'Only the double or the triple of the number counts.'**
  String get rulesAtcMasters;

  /// No description provided for @rulesAtcDoublesOnly.
  ///
  /// In en, this message translates to:
  /// **'Only the double of the number counts.'**
  String get rulesAtcDoublesOnly;

  /// No description provided for @rulesAtcBullsNote.
  ///
  /// In en, this message translates to:
  /// **'The two bull stops always need just that bull, whatever the variant.'**
  String get rulesAtcBullsNote;

  /// No description provided for @rulesBullseyeTwo.
  ///
  /// In en, this message translates to:
  /// **'The bullseye is worth 2. Steady legs, more darts.'**
  String get rulesBullseyeTwo;

  /// No description provided for @rulesBullseyeThree.
  ///
  /// In en, this message translates to:
  /// **'The bullseye is worth 3. One great dart can swing the leg.'**
  String get rulesBullseyeThree;

  /// No description provided for @rulesBullingOuterBull.
  ///
  /// In en, this message translates to:
  /// **'OUTER BULL'**
  String get rulesBullingOuterBull;

  /// No description provided for @rulesBullingBullseye.
  ///
  /// In en, this message translates to:
  /// **'BULLSEYE'**
  String get rulesBullingBullseye;

  /// No description provided for @rulesBullingEverythingElse.
  ///
  /// In en, this message translates to:
  /// **'EVERYTHING ELSE'**
  String get rulesBullingEverythingElse;

  /// No description provided for @rulesBullingInstantTitle.
  ///
  /// In en, this message translates to:
  /// **'INSTANT WIN'**
  String get rulesBullingInstantTitle;

  /// No description provided for @rulesBullingInstant.
  ///
  /// In en, this message translates to:
  /// **'The leg ends the moment you reach the target, even mid-turn. Darts after that don\'t count.'**
  String get rulesBullingInstant;

  /// No description provided for @rulesBullingNoBust.
  ///
  /// In en, this message translates to:
  /// **'Going past the target is fine - there is no bust in bulling.'**
  String get rulesBullingNoBust;

  /// No description provided for @rulesTrainingFreeBody.
  ///
  /// In en, this message translates to:
  /// **'No target and no win condition. Throw and watch your numbers.'**
  String get rulesTrainingFreeBody;

  /// No description provided for @rulesTrainingCheckoutBody.
  ///
  /// In en, this message translates to:
  /// **'Pick a start score and finish it under double out, the same rule as an X01 leg. The checkout route stays on screen the whole way.'**
  String get rulesTrainingCheckoutBody;

  /// No description provided for @rulesStatTotal.
  ///
  /// In en, this message translates to:
  /// **'TOTAL'**
  String get rulesStatTotal;

  /// No description provided for @rulesOutcomeCheckout.
  ///
  /// In en, this message translates to:
  /// **'GAME SHOT'**
  String get rulesOutcomeCheckout;

  /// No description provided for @rulesOutcomeNextStop.
  ///
  /// In en, this message translates to:
  /// **'NEXT STOP'**
  String get rulesOutcomeNextStop;

  /// No description provided for @rulesOutcomeWin.
  ///
  /// In en, this message translates to:
  /// **'LEG WON'**
  String get rulesOutcomeWin;

  /// No description provided for @rulesExampleLeft.
  ///
  /// In en, this message translates to:
  /// **'{remaining} LEFT'**
  String rulesExampleLeft(int remaining);

  /// No description provided for @rulesExampleDoubleOut.
  ///
  /// In en, this message translates to:
  /// **'DOUBLE OUT'**
  String get rulesExampleDoubleOut;

  /// No description provided for @rulesExampleCheckoutNote.
  ///
  /// In en, this message translates to:
  /// **'D20 is a double: straight to zero.'**
  String get rulesExampleCheckoutNote;

  /// No description provided for @rulesExampleNoDoubleNote.
  ///
  /// In en, this message translates to:
  /// **'Zero - but the last dart was a single, so it doesn\'t count.'**
  String get rulesExampleNoDoubleNote;

  /// No description provided for @rulesExampleOvershootNote.
  ///
  /// In en, this message translates to:
  /// **'34 is more than 32. Back to 32 for the next turn.'**
  String get rulesExampleOvershootNote;

  /// No description provided for @rulesExampleAtcOn.
  ///
  /// In en, this message translates to:
  /// **'ON {stop} · {variant}'**
  String rulesExampleAtcOn(String stop, String variant);

  /// No description provided for @rulesExampleAtcNote.
  ///
  /// In en, this message translates to:
  /// **'The single doesn\'t clear 5 under Masters. The triple does.'**
  String get rulesExampleAtcNote;

  /// No description provided for @rulesExampleBulling.
  ///
  /// In en, this message translates to:
  /// **'{score} OF {target}'**
  String rulesExampleBulling(int score, int target);

  /// No description provided for @rulesExampleBullingNote.
  ///
  /// In en, this message translates to:
  /// **'The bullseye takes you past 21 - the third dart is never thrown.'**
  String get rulesExampleBullingNote;

  /// No description provided for @rulesBoardSemantics.
  ///
  /// In en, this message translates to:
  /// **'Dartboard with the segments that count lit up'**
  String get rulesBoardSemantics;

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

  /// No description provided for @checkoutDartsLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 DART} other{{count} DARTS}}'**
  String checkoutDartsLeft(int count);

  /// No description provided for @checkoutNextDart.
  ///
  /// In en, this message translates to:
  /// **'next dart'**
  String get checkoutNextDart;

  /// No description provided for @checkoutOr.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get checkoutOr;

  /// No description provided for @semanticCheckoutRoute.
  ///
  /// In en, this message translates to:
  /// **'Checkout {remaining}: {route}'**
  String semanticCheckoutRoute(int remaining, String route);

  /// No description provided for @scoreArrow.
  ///
  /// In en, this message translates to:
  /// **'{before} → {after}'**
  String scoreArrow(String before, String after);

  /// No description provided for @legWonStatsX01.
  ///
  /// In en, this message translates to:
  /// **'{darts} darts · {average} average'**
  String legWonStatsX01(int darts, String average);

  /// No description provided for @aimLabel.
  ///
  /// In en, this message translates to:
  /// **'AIM'**
  String get aimLabel;

  /// No description provided for @remainingLabel.
  ///
  /// In en, this message translates to:
  /// **'REMAINING'**
  String get remainingLabel;

  /// No description provided for @figureHitRate.
  ///
  /// In en, this message translates to:
  /// **'HIT RATE'**
  String get figureHitRate;

  /// No description provided for @figureReached.
  ///
  /// In en, this message translates to:
  /// **'REACHED'**
  String get figureReached;

  /// No description provided for @figurePoints.
  ///
  /// In en, this message translates to:
  /// **'POINTS'**
  String get figurePoints;

  /// No description provided for @dartsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 dart} other{{count} darts}}'**
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

  /// No description provided for @pickAtLeastTwoPlayers.
  ///
  /// In en, this message translates to:
  /// **'PICK AT LEAST TWO PLAYERS'**
  String get pickAtLeastTwoPlayers;

  /// No description provided for @higherLowerSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'HIGHER / LOWER SETUP'**
  String get higherLowerSetupTitle;

  /// No description provided for @rulesHigherLowerTitle.
  ///
  /// In en, this message translates to:
  /// **'HIGHER / LOWER RULES'**
  String get rulesHigherLowerTitle;

  /// No description provided for @rulesHigherLowerOverview.
  ///
  /// In en, this message translates to:
  /// **'Beat the higher score or duck the lower one, or you\'re out'**
  String get rulesHigherLowerOverview;

  /// No description provided for @rulesHigherLowerObjective.
  ///
  /// In en, this message translates to:
  /// **'Score more than the higher value or less than the lower one, three darts a turn. Last one standing wins.'**
  String get rulesHigherLowerObjective;

  /// No description provided for @rulesSectionTurn.
  ///
  /// In en, this message translates to:
  /// **'THE TURN'**
  String get rulesSectionTurn;

  /// No description provided for @rulesHigherLowerTurnHint.
  ///
  /// In en, this message translates to:
  /// **'Beat higher and your total becomes the new higher value. Beat lower and it becomes the new lower value. Both carry over to the next player.'**
  String get rulesHigherLowerTurnHint;

  /// No description provided for @rulesHigherLowerOutTitle.
  ///
  /// In en, this message translates to:
  /// **'YOU\'RE OUT WHEN'**
  String get rulesHigherLowerOutTitle;

  /// No description provided for @rulesHigherLowerOutBetween.
  ///
  /// In en, this message translates to:
  /// **'Your total is neither more than higher nor less than lower. Hitting either value exactly counts as neither.'**
  String get rulesHigherLowerOutBetween;

  /// No description provided for @rulesHigherLowerOutMiss.
  ///
  /// In en, this message translates to:
  /// **'A dart misses the board. The turn ends right there.'**
  String get rulesHigherLowerOutMiss;

  /// No description provided for @rulesHigherLowerOutButton.
  ///
  /// In en, this message translates to:
  /// **'You end the turn early with the board button. That counts as a miss.'**
  String get rulesHigherLowerOutButton;

  /// No description provided for @rulesHigherLowerOutFooter.
  ///
  /// In en, this message translates to:
  /// **'You sit out the rest of the leg. The last player standing wins it.'**
  String get rulesHigherLowerOutFooter;

  /// No description provided for @rulesHigherLowerTrebleOne.
  ///
  /// In en, this message translates to:
  /// **'Treble 1 counts as 0 - the only way under 3.'**
  String get rulesHigherLowerTrebleOne;

  /// No description provided for @rulesExampleHigherLower.
  ///
  /// In en, this message translates to:
  /// **'HIGHER {higher} · LOWER {lower}'**
  String rulesExampleHigherLower(int higher, int lower);

  /// No description provided for @rulesExampleHigherNote.
  ///
  /// In en, this message translates to:
  /// **'66 is more than 45, so higher is 66 now.'**
  String get rulesExampleHigherNote;

  /// No description provided for @rulesExampleTieNote.
  ///
  /// In en, this message translates to:
  /// **'26 is not less than 26, and not more than 45 either. Out.'**
  String get rulesExampleTieNote;

  /// No description provided for @higherLabel.
  ///
  /// In en, this message translates to:
  /// **'HIGHER'**
  String get higherLabel;

  /// No description provided for @lowerLabel.
  ///
  /// In en, this message translates to:
  /// **'LOWER'**
  String get lowerLabel;

  /// No description provided for @eliminatedLabel.
  ///
  /// In en, this message translates to:
  /// **'OUT'**
  String get eliminatedLabel;

  /// No description provided for @turnTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'TURN'**
  String get turnTotalLabel;

  /// No description provided for @survivedCaption.
  ///
  /// In en, this message translates to:
  /// **'survived'**
  String get survivedCaption;

  /// No description provided for @higherArrow.
  ///
  /// In en, this message translates to:
  /// **'HIGHER {before} → {after}'**
  String higherArrow(int before, int after);

  /// No description provided for @lowerArrow.
  ///
  /// In en, this message translates to:
  /// **'LOWER {before} → {after}'**
  String lowerArrow(int before, int after);

  /// No description provided for @missedOut.
  ///
  /// In en, this message translates to:
  /// **'MISSED · OUT'**
  String get missedOut;

  /// No description provided for @betweenOut.
  ///
  /// In en, this message translates to:
  /// **'NOT OVER {higher}, NOT UNDER {lower} · OUT'**
  String betweenOut(int higher, int lower);

  /// No description provided for @lastStandingLabel.
  ///
  /// In en, this message translates to:
  /// **'LAST ONE STANDING'**
  String get lastStandingLabel;

  /// No description provided for @figureTurns.
  ///
  /// In en, this message translates to:
  /// **'TURNS'**
  String get figureTurns;

  /// No description provided for @higherLowerLabel.
  ///
  /// In en, this message translates to:
  /// **'HIGHER / LOWER'**
  String get higherLowerLabel;

  /// No description provided for @survivalRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Survival rate'**
  String get survivalRateLabel;

  /// No description provided for @xOfYTurns.
  ///
  /// In en, this message translates to:
  /// **'{x} of {y} turns'**
  String xOfYTurns(int x, int y);

  /// No description provided for @higherCallsRow.
  ///
  /// In en, this message translates to:
  /// **'Went higher'**
  String get higherCallsRow;

  /// No description provided for @lowerCallsRow.
  ///
  /// In en, this message translates to:
  /// **'Went lower'**
  String get lowerCallsRow;

  /// No description provided for @longestRunRow.
  ///
  /// In en, this message translates to:
  /// **'Longest run'**
  String get longestRunRow;

  /// No description provided for @turnsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 turn} other{{count} turns}}'**
  String turnsCount(int count);

  /// No description provided for @updatesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get updatesSectionTitle;

  /// No description provided for @updateCurrentVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String updateCurrentVersion(String version);

  /// No description provided for @updateAutoCheckLabel.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get updateAutoCheckLabel;

  /// No description provided for @updateAutoCheckDetail.
  ///
  /// In en, this message translates to:
  /// **'Asks GitHub for a newer release when the app starts'**
  String get updateAutoCheckDetail;

  /// No description provided for @updateCheckNowButton.
  ///
  /// In en, this message translates to:
  /// **'CHECK NOW'**
  String get updateCheckNowButton;

  /// No description provided for @updateCheckingStatus.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get updateCheckingStatus;

  /// No description provided for @updateUpToDateStatus.
  ///
  /// In en, this message translates to:
  /// **'Chalk is up to date'**
  String get updateUpToDateStatus;

  /// No description provided for @updateCheckFailedStatus.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach GitHub'**
  String get updateCheckFailedStatus;

  /// No description provided for @updateAvailableEyebrow.
  ///
  /// In en, this message translates to:
  /// **'UPDATE'**
  String get updateAvailableEyebrow;

  /// No description provided for @updateAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Chalk {version} is available'**
  String updateAvailableTitle(String version);

  /// No description provided for @updateAndroidDetail.
  ///
  /// In en, this message translates to:
  /// **'Downloads and installs it, keeping every game played'**
  String get updateAndroidDetail;

  /// No description provided for @updateWindowsDetail.
  ///
  /// In en, this message translates to:
  /// **'Opens the release page to download it'**
  String get updateWindowsDetail;

  /// No description provided for @updateInstallButton.
  ///
  /// In en, this message translates to:
  /// **'UPDATE'**
  String get updateInstallButton;

  /// No description provided for @updateDownloadButton.
  ///
  /// In en, this message translates to:
  /// **'DOWNLOAD'**
  String get updateDownloadButton;

  /// No description provided for @updateDownloadingStatus.
  ///
  /// In en, this message translates to:
  /// **'Downloading…'**
  String get updateDownloadingStatus;

  /// No description provided for @updateInstallingStatus.
  ///
  /// In en, this message translates to:
  /// **'Finish in the installer Android opened'**
  String get updateInstallingStatus;

  /// No description provided for @updatePermissionStatus.
  ///
  /// In en, this message translates to:
  /// **'Allow Chalk to install apps, then come back'**
  String get updatePermissionStatus;

  /// No description provided for @updateDownloadFailedStatus.
  ///
  /// In en, this message translates to:
  /// **'Download failed'**
  String get updateDownloadFailedStatus;

  /// No description provided for @updateInstallFailedStatus.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t start the update'**
  String get updateInstallFailedStatus;

  /// No description provided for @updateRetryButton.
  ///
  /// In en, this message translates to:
  /// **'TRY AGAIN'**
  String get updateRetryButton;

  /// No description provided for @updateDismissTooltip.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get updateDismissTooltip;
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
