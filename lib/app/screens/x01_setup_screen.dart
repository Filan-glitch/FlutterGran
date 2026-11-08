import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/x01/game_config.dart';
import '../../domain/x01/match_state.dart';
import '../../domain/x01/x01_rules.dart';
import '../l10n_extensions.dart';
import '../labels.dart';
import '../providers.dart';
import '../rules_topic.dart';
import '../theme.dart';
import '../widgets/board_connection_button.dart';
import '../widgets/player_picker.dart';
import '../widgets/rules_button.dart';
import '../widgets/setup_controls.dart';
import 'game_screen.dart';

/// Picks the x01 format and who is playing it, then starts the match.
///
/// Only the format and the roster live here; resuming a leg is on the main
/// menu and the sound toggles are in Settings.
class X01SetupScreen extends ConsumerStatefulWidget {
  const X01SetupScreen({super.key});

  @override
  ConsumerState<X01SetupScreen> createState() => _X01SetupScreenState();
}

class _X01SetupScreenState extends ConsumerState<X01SetupScreen> {
  /// Selected players, in the order they were tapped - which is throwing order.
  List<int> _seats = const [];

  int _startScore = 501;
  X01InRule _inRule = X01InRule.straight;
  X01OutRule _outRule = X01OutRule.double;

  /// Best of this many legs; one is a single leg.
  int _legsToPlay = 1;

  /// Whether the user has tapped a start score or rule. Once set, the
  /// remembered defaults arriving late through `ref.listen` no longer
  /// overwrite the choice.
  bool _userEditedRules = false;

  /// Whether the format can honestly be called a best of.
  ///
  /// A field of one or two is decided by more than half the legs. A bigger one
  /// is not, so it is offered as the target instead. Empty counts as head to
  /// head: the roster starts empty and two is what fills it.
  bool get _headToHead => _seats.length <= 2;

  @override
  void initState() {
    super.initState();
    final defaults = ref.read(x01DefaultsProvider);
    _startScore = defaults.startScore;
    _inRule = defaults.inRule;
    _outRule = defaults.outRule;
  }

  Future<void> _start() async {
    // Every game is a match, a single leg being a best of one. One path
    // through the app beats a special case for the format that happens to be
    // the default.
    await ref
        .read(matchProvider.notifier)
        .start(
          MatchConfig(
            startScore: _startScore,
            playerIds: _seats,
            inRule: _inRule,
            outRule: _outRule,
            legsToPlay: _legsToPlay,
          ),
        );
    unawaited(
      ref.read(x01DefaultsProvider.notifier).update((
        startScore: _startScore,
        inRule: _inRule,
        outRule: _outRule,
      )),
    );
    if (!mounted) return;

    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (context) => const GameScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    // The disk read behind x01DefaultsProvider resolves a frame after
    // initState's synchronous fallback. Apply it if it lands - unless the
    // user already tapped something in that first frame, in which case their
    // tap wins.
    ref.listen<X01Defaults>(x01DefaultsProvider, (_, defaults) {
      if (_userEditedRules) return;
      setState(() {
        _startScore = defaults.startScore;
        _inRule = defaults.inRule;
        _outRule = defaults.outRule;
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.x01SetupTitle),
        actions: const [
          RulesButton(topic: RulesTopic.x01),
          BoardConnectionButton(),
          SizedBox(width: Gap.xs),
        ],
      ),
      body: SafeArea(
        child: CenteredContent(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.sm, Gap.lg, Gap.lg),
            children: [
              // The start score set as a scoreboard number rather than a form
              // field: it is the number everyone is about to count down from.
              SectionLabel(l10n.startScoreLabel),
              const SizedBox(height: Gap.md),
              NumeralChoiceRow<int>(
                key: const Key('start-score-row'),
                values: GameConfig.offeredStartScores,
                selected: _startScore,
                label: (score) => '$score',
                onSelected: (score) => setState(() {
                  _startScore = score;
                  _userEditedRules = true;
                }),
              ),
              const SizedBox(height: Gap.lg),
              // Directly under the start score and styled identically, because
              // the two together are the format: what you count down from, and
              // how many times.
              //
              // Above two players, more than half of the legs is a target
              // nobody need reach - three players can take one each - so the
              // same choice is named for the target it really sets. The
              // stored format does not change with the wording.
              SectionLabel(_headToHead ? l10n.bestOfLabel : l10n.firstToLabel),
              const SizedBox(height: Gap.md),
              NumeralChoiceRow<int>(
                values: offeredLegsToPlay,
                selected: _legsToPlay,
                label: (legs) => '${_headToHead ? legs : legsToWinFor(legs)}',
                onSelected: (legs) => setState(() => _legsToPlay = legs),
              ),
              const SizedBox(height: Gap.lg),
              SectionLabel(l10n.inRuleLabel),
              const SizedBox(height: Gap.md),
              ChoiceRow<X01InRule>(
                key: const Key('in-rule-row'),
                values: X01InRule.values,
                selected: _inRule,
                label: (rule) => x01InRuleLabel(context, rule),
                tileKey: (rule) => Key('in-rule-${rule.name}'),
                onSelected: (rule) => setState(() {
                  _inRule = rule;
                  _userEditedRules = true;
                }),
              ),
              const SizedBox(height: Gap.lg),
              SectionLabel(l10n.outRuleLabel),
              const SizedBox(height: Gap.md),
              ChoiceRow<X01OutRule>(
                key: const Key('out-rule-row'),
                values: X01OutRule.values,
                selected: _outRule,
                label: (rule) => x01OutRuleLabel(context, rule),
                tileKey: (rule) => Key('out-rule-${rule.name}'),
                onSelected: (rule) => setState(() {
                  _outRule = rule;
                  _userEditedRules = true;
                }),
              ),
              const SizedBox(height: Gap.xl),
              PlayerPicker(
                seats: _seats,
                onChanged: (seats) => setState(() => _seats = seats),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: StartBar(
        buttonKey: const Key('start-leg-button'),
        onPressed: _seats.isEmpty ? null : _start,
        label: _seats.isEmpty
            ? l10n.pickAtLeastOnePlayer
            : _legsToPlay == 1
            ? l10n.startLeg
            : l10n.startBestOf(_legsToPlay),
      ),
    );
  }
}
