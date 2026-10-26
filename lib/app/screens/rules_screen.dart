import 'package:flutter/material.dart';

import '../l10n_extensions.dart';
import '../rules_topic.dart';
import '../theme.dart';
import '../widgets/game_layout.dart' show isHeroDevice;
import '../widgets/mode_glyph.dart';
import '../widgets/rules/rules_body.dart';
import '../widgets/rules/rules_hero.dart' show rulesGlyphTag;
import 'rules_detail_screen.dart';

/// The rules section's front page, reached from the main menu: every mode
/// by its glyph, name and one line, laid out for the device it is on.
///
///  - A phone gets a column of cards; a tap opens that mode's
///    [RulesDetailScreen], its glyph flying up into the page's header.
///  - A tablet gets a row of tall posters, one per mode (two rows when the
///    window is narrower), the same tap and the same flight.
///  - A desktop window big enough for the hero treatment is master-detail:
///    the modes as a rail on the left, the chosen one's [RulesBody] beside
///    it, switching in place - there is room for both, and a desktop reader
///    flips between modes rather than drilling in and backing out.
class RulesScreen extends StatefulWidget {
  const RulesScreen({super.key});

  @override
  State<RulesScreen> createState() => _RulesScreenState();
}

class _RulesScreenState extends State<RulesScreen> {
  /// The desktop pane's topic. Unused on a phone or tablet, where a tap
  /// pushes the topic's own page instead.
  RulesTopic _selected = RulesTopic.x01;

  void _open(RulesTopic topic) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) => RulesDetailScreen(topic: topic),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final hero = isHeroDevice(context);
    final body = switch ((hero, isDesktop)) {
      (true, true) => _masterDetail(),
      (true, false) => _posters(),
      (false, _) => _cards(),
    };

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.rulesTitle)),
      body: SafeArea(child: body),
    );
  }

  Widget _cards() => CenteredContent(
    child: ListView(
      padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.sm, Gap.lg, Gap.lg),
      children: [
        for (final topic in RulesTopic.values)
          StaggeredEntry(
            index: topic.index,
            child: Padding(
              padding: const EdgeInsets.only(bottom: Gap.md),
              child: _TopicCard(topic: topic, onTap: () => _open(topic)),
            ),
          ),
      ],
    ),
  );

  Widget _posters() => LayoutBuilder(
    builder: (context, constraints) {
      final scale = MediaQuery.textScalerOf(context).scale(1);
      final posters = [
        for (final topic in RulesTopic.values)
          StaggeredEntry(
            index: topic.index,
            child: _TopicPoster(topic: topic, onTap: () => _open(topic)),
          ),
      ];
      // Each row is as tall as its tallest poster and, when there is height
      // to spare, as tall as the screen - posters, not a list - but it can
      // still scroll should a long German tagline at 1.5x need it to.
      Widget row(List<Widget> children) => IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const SizedBox(width: Gap.lg),
              Expanded(child: children[i]),
            ],
          ],
        ),
      );

      final allAcross = constraints.maxWidth >= 200 * scale * posters.length;
      // Otherwise two rows, the longer one first.
      final split = (posters.length + 1) ~/ 2;
      return SingleChildScrollView(
        padding: const EdgeInsets.all(Gap.xl),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: allAcross ? constraints.maxHeight - Gap.xl * 2 : 0,
          ),
          child: allAcross
              ? row(posters)
              : Column(
                  children: [
                    row(posters.sublist(0, split)),
                    const SizedBox(height: Gap.lg),
                    row(posters.sublist(split)),
                  ],
                ),
        ),
      );
    },
  );

  Widget _masterDetail() => LayoutBuilder(
    builder: (context, constraints) {
      final rail = (constraints.maxWidth * 0.28).clamp(300.0, 440.0);
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: rail,
            child: ListView(
              padding: const EdgeInsets.all(Gap.lg),
              children: [
                for (final topic in RulesTopic.values)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Gap.sm),
                    child: _TopicCard(
                      topic: topic,
                      selected: topic == _selected,
                      flight: false,
                      onTap: () => setState(() => _selected = topic),
                    ),
                  ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: AnimatedSwitcher(
              duration: Motion.scale(Motion.base),
              switchInCurve: Motion.enter,
              switchOutCurve: Motion.exit,
              child: CenteredContent(
                key: ValueKey(_selected),
                maxWidth: rulesContentWidth(context),
                child: RulesBody(topic: _selected, flight: false),
              ),
            ),
          ),
        ],
      );
    },
  );
}

/// One mode as a card: glyph, name, tagline. A phone's overview row, and
/// with [selected] the desktop rail's entry - lit with the live edge while
/// its rules are the ones in the pane, and with no chevron, since it opens
/// nothing.
class _TopicCard extends StatelessWidget {
  const _TopicCard({
    required this.topic,
    required this.onTap,
    this.selected,
    this.flight = true,
  });

  final RulesTopic topic;
  final VoidCallback onTap;

  /// Null on a phone, where a card is a link rather than a choice.
  final bool? selected;

  /// See [RulesHero.flight].
  final bool flight;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selected = this.selected;
    // Grows with the type, so the desktop's 1.75x names do not dwarf it.
    final glyph = ModeGlyph(
      topic: topic,
      size: 52 * MediaQuery.textScalerOf(context).scale(1),
    );

    return Semantics(
      selected: selected,
      child: AnimatedContainer(
        duration: Motion.scale(Motion.base),
        curve: Motion.enter,
        decoration: BoxDecoration(
          color: selected == false ? Colors.transparent : Palette.raised,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: selected == true ? Palette.live : Palette.edge,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: Key('rules-overview-${topic.name}'),
            borderRadius: BorderRadius.circular(4),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(Gap.md),
              child: Row(
                children: [
                  if (flight)
                    Hero(tag: rulesGlyphTag(topic), child: glyph)
                  else
                    glyph,
                  const SizedBox(width: Gap.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          topic.displayName(l10n),
                          style: Type.title.copyWith(
                            color: selected == false
                                ? Palette.chalkDim
                                : Palette.chalk,
                          ),
                        ),
                        const SizedBox(height: Gap.xs),
                        Text(
                          topic.overview(l10n),
                          style: Type.label.copyWith(color: Palette.chalkDim),
                        ),
                      ],
                    ),
                  ),
                  if (selected == null) ...[
                    const SizedBox(width: Gap.md),
                    const Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: Palette.chalkDim,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One mode as a tablet poster: the glyph set large, the name in scoreboard
/// numerals, the tagline, and the mode's numbers pinned to the bottom.
class _TopicPoster extends StatelessWidget {
  const _TopicPoster({required this.topic, required this.onTap});

  final RulesTopic topic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Material(
      color: Palette.raised,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: Palette.edge),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: Key('rules-overview-${topic.name}'),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Gap.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: rulesGlyphTag(topic),
                child: ModeGlyph(topic: topic, size: 96),
              ),
              const SizedBox(height: Gap.xl),
              Text(
                topic.displayName(l10n),
                style: Type.scoreSmall.copyWith(color: Palette.chalk),
              ),
              const SizedBox(height: Gap.sm),
              Text(
                topic.overview(l10n),
                style: Type.body.copyWith(color: Palette.chalkDim),
              ),
              const Spacer(),
              const SizedBox(height: Gap.xl),
              for (final fact in topic.facts(l10n)) ...[
                Text(
                  fact.figure,
                  style: Type.notation.copyWith(color: Palette.chalk),
                ),
                const SizedBox(height: Gap.xs),
                Text(
                  fact.label,
                  style: Type.eyebrow.copyWith(color: Palette.chalkDim),
                ),
                const SizedBox(height: Gap.md),
              ],
              const Divider(),
              const SizedBox(height: Gap.md),
              Row(
                children: [
                  Text(
                    l10n.rulesMenuLabel.toUpperCase(),
                    style: Type.eyebrow.copyWith(color: Palette.live),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward,
                    size: 20,
                    color: Palette.live,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
