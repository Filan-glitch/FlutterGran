import 'package:flutter/material.dart';

import '../../../domain/atc/atc_stop.dart';
import '../../../domain/atc/atc_variant.dart';
import '../../../domain/bulling/bulling_variant.dart';
import '../../../domain/segment.dart';
import '../../../domain/x01/match_state.dart';
import '../../../domain/x01/x01_rules.dart';
import '../../../l10n/app_localizations.dart';
import '../../l10n_extensions.dart';
import '../../rules_topic.dart';
import '../../screens/atc_setup_screen.dart' show atcVariantLabel;
import '../../screens/bulling_setup_screen.dart' show bullseyeValueLabel;
import '../../screens/x01_setup_screen.dart'
    show x01InRuleLabel, x01OutRuleLabel;
import '../../theme.dart';
import '../setup_controls.dart';
import 'rule_board.dart';
import 'rule_callout.dart';
import 'rule_explorer.dart';
import 'rules_hero.dart';
import 'worked_example.dart';

/// Width, in unscaled logical pixels, from which a rules page sets things
/// side by side - two examples, a callout beside its example, the hero at
/// full size. Multiplied by the text scale, like [RuleExplorer]'s own.
const double _wideWidth = 560;

/// The rules for one [topic], as a scrolling page: a [RulesHero], then one
/// section per rule, each one shown rather than told - a [RuleExplorer] for
/// every rule with settings, a [RuleCallout] for what ends a turn, and a
/// [WorkedExample] wherever a turn played out says it faster.
///
/// The same page on every device; only its own width decides how much sits
/// side by side, so it reads the same in a phone's screen, a tablet's wider
/// column and the desktop's pane beside the topic rail.
class RulesBody extends StatelessWidget {
  const RulesBody({super.key, required this.topic, this.flight = true});

  final RulesTopic topic;

  /// See [RulesHero.flight].
  final bool flight;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scale = MediaQuery.textScalerOf(context).scale(1);

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= _wideWidth * scale;
        final sections = <Widget>[
          RulesHero(topic: topic, wide: wide, flight: flight),
          ...switch (topic) {
            RulesTopic.x01 => _x01(context, l10n, wide),
            RulesTopic.aroundTheClock => _aroundTheClock(context, l10n),
            RulesTopic.bulling => _bulling(context, l10n),
            RulesTopic.training => _training(l10n, wide),
          },
        ];

        return ListView(
          padding: EdgeInsets.fromLTRB(
            Gap.lg,
            wide ? Gap.xl : Gap.lg,
            Gap.lg,
            Gap.xxl,
          ),
          children: [
            for (var i = 0; i < sections.length; i++) ...[
              if (i > 0) SizedBox(height: wide ? Gap.xxl + Gap.lg : Gap.xxl),
              StaggeredEntry(index: i, child: sections[i]),
            ],
          ],
        );
      },
    );
  }

  List<Widget> _x01(BuildContext context, AppLocalizations l10n, bool wide) {
    final doubleOut = l10n.rulesExampleDoubleOut;
    return [
      _Section(
        title: l10n.rulesSectionIn,
        child: RuleExplorer<X01InRule>(
          id: 'in',
          values: X01InRule.values,
          initial: X01InRule.double,
          label: (rule) => x01InRuleLabel(context, rule),
          explanation: (rule) => switch (rule) {
            X01InRule.straight => l10n.rulesInStraight,
            X01InRule.double => l10n.rulesInDouble,
            X01InRule.master => l10n.rulesInMaster,
          },
          lit: (rule) => Segment.all.where(rule.opens).toSet(),
          legend: l10n.rulesLegendIn,
        ),
      ),
      _Section(
        title: l10n.rulesSectionOut,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RuleExplorer<X01OutRule>(
              id: 'out',
              values: X01OutRule.values,
              initial: X01OutRule.double,
              label: (rule) => x01OutRuleLabel(context, rule),
              explanation: (rule) => switch (rule) {
                X01OutRule.straight => l10n.rulesOutStraight,
                X01OutRule.double => l10n.rulesOutDouble,
                X01OutRule.master => l10n.rulesOutMaster,
              },
              lit: (rule) => Segment.all.where(rule.checksOut).toSet(),
              legend: l10n.rulesLegendOut,
            ),
            const SizedBox(height: Gap.xl),
            _Pair(
              wide: wide,
              first: WorkedExample(
                caption: '${l10n.rulesExampleLeft(40)} · $doubleOut',
                start: '40',
                darts: const [
                  (
                    segment: Segment(20, Ring.doubleRing),
                    after: '0',
                    counts: true,
                  ),
                ],
                outcome: ExampleOutcome.good,
                outcomeLabel: l10n.rulesOutcomeCheckout,
                note: l10n.rulesExampleCheckoutNote,
              ),
              second: WorkedExample(
                caption: '${l10n.rulesExampleLeft(40)} · $doubleOut',
                start: '40',
                darts: const [
                  (
                    segment: Segment(20, Ring.outerSingle),
                    after: '20',
                    counts: true,
                  ),
                  (
                    segment: Segment(20, Ring.outerSingle),
                    after: '0',
                    counts: false,
                  ),
                ],
                outcome: ExampleOutcome.bust,
                outcomeLabel: l10n.bustLabel,
                note: l10n.rulesExampleNoDoubleNote,
              ),
            ),
          ],
        ),
      ),
      _Section(
        title: l10n.rulesSectionBust,
        child: _Pair(
          wide: wide,
          first: RuleCallout(
            tone: CalloutTone.bust,
            title: l10n.rulesBustTitle,
            points: [
              l10n.rulesBustOvershoot,
              l10n.rulesBustNoFinish,
              l10n.rulesBustOneLeft,
            ],
            footer: l10n.rulesBustReset,
          ),
          second: WorkedExample(
            caption: '${l10n.rulesExampleLeft(32)} · $doubleOut',
            start: '32',
            darts: const [
              (
                segment: Segment(20, Ring.outerSingle),
                after: '12',
                counts: true,
              ),
              (
                segment: Segment(14, Ring.innerSingle),
                after: '−2',
                counts: false,
              ),
            ],
            outcome: ExampleOutcome.bust,
            outcomeLabel: l10n.bustLabel,
            note: l10n.rulesExampleOvershootNote,
          ),
        ),
      ),
      _Section(title: l10n.rulesSectionFormat, child: const _MatchFormat()),
    ];
  }

  List<Widget> _aroundTheClock(BuildContext context, AppLocalizations l10n) {
    final twenty = AtcStop.track.firstWhere((stop) => stop.number == 20);
    return [
      _Section(
        title: l10n.rulesSectionRoute,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _AtcRoute(key: Key('rules-atc-route')),
            const SizedBox(height: Gap.md),
            Text(
              l10n.rulesAtcRouteHint,
              style: Type.body.copyWith(color: Palette.chalkDim),
            ),
          ],
        ),
      ),
      _Section(
        title: l10n.rulesSectionVariant,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RuleExplorer<AtcVariant>(
              id: 'atc',
              values: AtcVariant.values,
              initial: AtcVariant.masters,
              label: (variant) => atcVariantLabel(context, variant),
              explanation: (variant) => switch (variant) {
                AtcVariant.anyPart => l10n.rulesAtcAnyPart,
                AtcVariant.masters => l10n.rulesAtcMasters,
                AtcVariant.doublesOnly => l10n.rulesAtcDoublesOnly,
              },
              lit: (variant) => Segment.all
                  .where((segment) => twenty.clears(segment, variant))
                  .toSet(),
              legend: l10n.rulesLegendAtc,
            ),
            const SizedBox(height: Gap.lg),
            _Note(l10n.rulesAtcBullsNote),
          ],
        ),
      ),
      _Section(
        title: l10n.rulesSectionExamples,
        child: WorkedExample(
          caption: l10n.rulesExampleAtcOn(
            '5',
            atcVariantLabel(context, AtcVariant.masters),
          ),
          start: '5',
          darts: const [
            (segment: Segment(5, Ring.innerSingle), after: '5', counts: false),
            (segment: Segment(5, Ring.triple), after: '6', counts: true),
          ],
          outcome: ExampleOutcome.good,
          outcomeLabel: l10n.rulesOutcomeNextStop,
          note: l10n.rulesExampleAtcNote,
        ),
      ),
    ];
  }

  List<Widget> _bulling(BuildContext context, AppLocalizations l10n) => [
    _Section(
      title: l10n.rulesSectionScoring,
      child: RuleExplorer<BullseyeValue>(
        id: 'bullseye',
        values: BullseyeValue.values,
        initial: BullseyeValue.three,
        label: (value) => bullseyeValueLabel(context, value),
        explanation: (value) => switch (value) {
          BullseyeValue.two => l10n.rulesBullseyeTwo,
          BullseyeValue.three => l10n.rulesBullseyeThree,
        },
        lit: (_) => {Segment.outerBull, Segment.innerBull},
        legend: l10n.rulesLegendBulling,
        detail: (value) => _PointsTable(bullseye: value),
      ),
    ),
    RuleCallout(
      tone: CalloutTone.note,
      title: l10n.rulesBullingInstantTitle,
      points: [l10n.rulesBullingInstant, l10n.rulesBullingNoBust],
    ),
    _Section(
      title: l10n.rulesSectionExamples,
      child: WorkedExample(
        caption:
            '${l10n.rulesExampleBulling(19, 21)} · '
            '${bullseyeValueLabel(context, BullseyeValue.three)}',
        start: '19',
        darts: const [
          (segment: Segment.outerBull, after: '20', counts: true),
          (segment: Segment.innerBull, after: '23', counts: true),
        ],
        outcome: ExampleOutcome.good,
        outcomeLabel: l10n.rulesOutcomeWin,
        note: l10n.rulesExampleBullingNote,
      ),
    ),
  ];

  List<Widget> _training(AppLocalizations l10n, bool wide) => [
    _Section(
      title: l10n.rulesSectionDrills,
      child: _Pair(
        wide: wide,
        first: _DrillCard(
          key: const Key('rules-drill-freePractice'),
          title: l10n.freePracticeLabel,
          body: l10n.rulesTrainingFreeBody,
          child: Wrap(
            spacing: Gap.sm,
            runSpacing: Gap.sm,
            children: [
              for (final stat in [
                l10n.rulesStatTotal,
                l10n.statBestTurn,
                l10n.statAverage,
                l10n.figure180s,
              ])
                _StatChip(stat),
            ],
          ),
        ),
        second: _DrillCard(
          key: const Key('rules-drill-checkoutPractice'),
          title: l10n.checkoutPracticeLabel,
          body: l10n.rulesTrainingCheckoutBody,
          child: Column(
            children: [
              SizedBox.square(
                dimension: 180,
                child: RuleBoard(
                  lit: Segment.all.where(X01OutRule.double.checksOut).toSet(),
                  showNumbers: false,
                ),
              ),
              const SizedBox(height: Gap.sm),
              Text(
                l10n.rulesLegendCheckout,
                textAlign: TextAlign.center,
                style: Type.eyebrow.copyWith(color: Palette.live),
              ),
            ],
          ),
        ),
      ),
    ),
  ];
}

/// A titled stretch of a rules page: the name in small capitals running into
/// a hairline, the chalkboard's ruled line, then whatever the section shows.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(title, style: Type.eyebrow.copyWith(color: Palette.chalkDim)),
            const SizedBox(width: Gap.md),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: Gap.lg),
        child,
      ],
    );
  }
}

/// Two things side by side when there is room, one above the other when not.
class _Pair extends StatelessWidget {
  const _Pair({required this.wide, required this.first, required this.second});

  final bool wide;
  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) {
    if (!wide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          first,
          const SizedBox(height: Gap.md),
          second,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: first),
        const SizedBox(width: Gap.lg),
        Expanded(child: second),
      ],
    );
  }
}

/// An aside - a rule's one exception - quieter than a [RuleCallout].
class _Note extends StatelessWidget {
  const _Note(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 1),
          child: Icon(Icons.info_outline, size: 16, color: Palette.chalkDim),
        ),
        const SizedBox(width: Gap.sm),
        Expanded(
          child: Text(
            text,
            style: Type.label.copyWith(color: Palette.chalkDim),
          ),
        ),
      ],
    );
  }
}

/// Best of 1, 3, 5 or 7, picked on the same numerals the setup screen uses,
/// with a pip per leg so "first to 3" is something to count rather than
/// work out.
class _MatchFormat extends StatefulWidget {
  const _MatchFormat();

  @override
  State<_MatchFormat> createState() => _MatchFormatState();
}

class _MatchFormatState extends State<_MatchFormat> {
  int _legs = 5;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final toWin = legsToWinFor(_legs);
    final duration = Motion.scale(Motion.base);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.rulesFormatBestOf,
          style: Type.eyebrow.copyWith(color: Palette.chalkDim),
        ),
        const SizedBox(height: Gap.sm),
        NumeralChoiceRow<int>(
          key: const Key('rules-format-legs'),
          values: offeredLegsToPlay,
          selected: _legs,
          label: (legs) => '$legs',
          onSelected: (legs) => setState(() => _legs = legs),
        ),
        const SizedBox(height: Gap.lg),
        Wrap(
          spacing: Gap.sm,
          runSpacing: Gap.sm,
          children: [
            for (var leg = 0; leg < offeredLegsToPlay.last; leg++)
              AnimatedContainer(
                duration: duration,
                curve: Motion.enter,
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: leg < toWin ? Palette.live : Colors.transparent,
                  border: Border.all(
                    color: leg < toWin
                        ? Palette.live
                        : leg < _legs
                        ? Palette.chalkDim
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: Gap.md),
        Text(
          l10n.rulesFormatFirstTo(toWin),
          key: const Key('rules-format-first-to'),
          style: Type.title.copyWith(color: Palette.chalk),
        ),
        const SizedBox(height: Gap.sm),
        Text(
          l10n.rulesFormatGroup,
          style: Type.label.copyWith(color: Palette.chalkDim),
        ),
      ],
    );
  }
}

/// All 22 Around the Clock stops in throwing order, lighting up one after
/// another the first time the page shows - the route, walked once.
///
/// One sweep and done, never a loop: the order is the point, and a page
/// that never settles is one a test can never settle either.
class _AtcRoute extends StatelessWidget {
  const _AtcRoute({super.key});

  @override
  Widget build(BuildContext context) {
    final stops = AtcStop.track;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: stops.length.toDouble()),
      duration: Motion.scale(Motion.stagger * stops.length * 1.5),
      builder: (context, reached, _) => Wrap(
        spacing: Gap.xs,
        runSpacing: Gap.xs,
        children: [
          for (var i = 0; i < stops.length; i++)
            _StopChip(label: stops[i].label, reached: reached > i),
        ],
      ),
    );
  }
}

class _StopChip extends StatelessWidget {
  const _StopChip({required this.label, required this.reached});

  final String label;
  final bool reached;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Motion.scale(Motion.fast),
      constraints: const BoxConstraints(minWidth: 38),
      padding: const EdgeInsets.symmetric(horizontal: Gap.sm, vertical: Gap.sm),
      decoration: BoxDecoration(
        color: reached ? Palette.raised : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: reached ? Palette.live : Palette.edge),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: Type.notation.copyWith(
          fontSize: 16,
          color: reached ? Palette.chalk : Palette.chalkDim,
        ),
      ),
    );
  }
}

/// What each part of the board is worth in Bulling, the bullseye's figure
/// following the value picked above it.
class _PointsTable extends StatelessWidget {
  const _PointsTable({required this.bullseye});

  final BullseyeValue bullseye;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final rows = [
      (Segment.outerBull.label, l10n.rulesBullingOuterBull, 1),
      (Segment.innerBull.label, l10n.rulesBullingBullseye, bullseye.points),
      ('—', l10n.rulesBullingEverythingElse, 0),
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Palette.edge),
      ),
      child: Column(
        children: [
          for (final (notation, name, points) in rows) ...[
            if (notation != rows.first.$1) const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Gap.md,
                vertical: Gap.sm,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 44,
                    child: Text(
                      notation,
                      style: Type.notation.copyWith(color: Palette.chalkDim),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      name,
                      style: Type.eyebrow.copyWith(color: Palette.chalk),
                    ),
                  ),
                  AnimatedFigure(
                    key: Key('rules-points-$notation'),
                    value: points,
                    style: Type.scoreSmall.copyWith(
                      color: points > 0 ? Palette.live : Palette.chalkDim,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DrillCard extends StatelessWidget {
  const _DrillCard({
    super.key,
    required this.title,
    required this.body,
    required this.child,
  });

  final String title;
  final String body;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Gap.lg),
      decoration: BoxDecoration(
        color: Palette.raised,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Palette.edge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Type.title.copyWith(color: Palette.chalk)),
          const SizedBox(height: Gap.sm),
          Text(body, style: Type.body.copyWith(color: Palette.chalkDim)),
          const SizedBox(height: Gap.lg),
          child,
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Gap.md, vertical: Gap.sm),
      decoration: BoxDecoration(
        color: Palette.sunk,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Palette.edge),
      ),
      child: Text(label, style: Type.eyebrow.copyWith(color: Palette.live)),
    );
  }
}
