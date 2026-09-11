import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../domain/atc/atc_stop.dart';
import '../../domain/game_mode.dart';
import '../../domain/segment.dart';
import '../../domain/stats/mode_stats.dart';
import '../../domain/x01/x01_rules.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/board_widget.dart';

/// A player's record across every leg they have played.
class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  int? _playerId;

  @override
  Widget build(BuildContext context) {
    final players = ref.watch(playersProvider).value ?? const <Player>[];
    final selected = _playerId ?? (players.isEmpty ? null : players.first.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('STATISTICS'),
        actions: [
          if (players.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: Gap.md),
              child: DropdownButton<int>(
                value: selected,
                underline: const SizedBox.shrink(),
                dropdownColor: Palette.raised,
                iconEnabledColor: Palette.chalkDim,
                style: Type.body.copyWith(color: Palette.chalk),
                items: [
                  for (final player in players)
                    DropdownMenuItem(
                      value: player.id,
                      child: Text(player.name),
                    ),
                ],
                onChanged: (id) => setState(() => _playerId = id),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: selected == null
            ? _Empty(
                headline: 'No players yet',
                detail: 'Add one on the setup screen to start a record.',
              )
            : _Body(playerId: selected),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.playerId});

  final int playerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsByMode = ref.watch(playerStatsProvider(playerId));
    // Read as absent keys rather than assumed present, which is the honest
    // contract of a map keyed by mode - what keeps this code unchanged when
    // a mode legitimately has zero data for this player.
    final x01 = statsByMode[GameMode.x01] as X01Stats?;
    final atc = statsByMode[GameMode.aroundTheClock] as AtcStats?;
    final bulling = statsByMode[GameMode.bulling] as BullingStats?;
    final counts =
        ref.watch(segmentCountsProvider(playerId)).value ??
        const <Segment, int>{};

    final hasX01 = x01 != null && x01.legsPlayed > 0;
    final hasAtc = atc != null && atc.legsPlayed > 0;
    final hasBulling = bulling != null && bulling.legsPlayed > 0;

    if (!hasX01 && !hasAtc && !hasBulling) {
      return _Empty(
        headline: 'No legs yet',
        detail: 'Play a leg and every dart in it lands here.',
      );
    }

    return CenteredContent(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.sm, Gap.lg, Gap.xxl),
        children: [
          if (hasX01) ...[
            // A mode label above its section, so a second mode's section reads
            // as a distinct record rather than more rows appended to this one.
            const _Eyebrow('X01'),
            const SizedBox(height: Gap.sm),
            // The three-dart average is the number a darts player quotes when
            // asked how they play, so it is the headline and everything else
            // is supporting evidence.
            _Headline(
              value: x01.average == null
                  ? '—'
                  : x01.average!.toStringAsFixed(2),
              label: 'Three-dart average',
              detail:
                  '${x01.dartsThrown} darts over ${x01.legsPlayed} '
                  '${x01.legsPlayed == 1 ? 'leg' : 'legs'}',
            ),
            const SizedBox(height: Gap.xl),
            _Section(
              title: 'Scoring',
              rows: [
                _Row('First 9 average', _decimal(x01.firstNineAverage)),
                _Row('Best turn', '${x01.bestTurn}'),
                _Row(
                  '180s',
                  '${x01.turnsOf180}',
                  milestone: x01.turnsOf180 > 0,
                ),
                _Row('140+', '${x01.turnsOf140Plus}'),
                _Row('100+', '${x01.turnsOf100Plus}'),
                _Row('60+', '${x01.turnsOf60Plus}'),
              ],
            ),
            _Section(
              title: 'Finishing',
              rows: [
                // One row pair per out-rule the player has actually played a
                // leg under, rather than one aggregate figure mixing
                // single/double/master-out legs together - "on a finish"
                // means something different under each rule.
                for (final rule in X01OutRule.values)
                  if (x01.checkoutsByRule[rule] case final checkout?) ...[
                    _Row(
                      '${rule.label} checkout',
                      _percent(x01.checkoutRateFor(rule)),
                    ),
                    _Row(
                      '${rule.label} darts at finish',
                      '${checkout.finishesHit}/${checkout.dartsAtFinish}',
                    ),
                  ],
                _Row(
                  'Best checkout',
                  _optional(x01.bestCheckout),
                  milestone: x01.bestCheckout != null,
                ),
                _Row(
                  'Best leg',
                  _optional(x01.fewestDartsToWin, suffix: ' darts'),
                ),
              ],
            ),
            _Section(
              title: 'Legs',
              rows: [
                _Row('Won', '${x01.legsWon} of ${x01.legsPlayed}'),
                _Row('Win rate', _percent(x01.winRate)),
              ],
            ),
            // Its own section, under the legs rather than mixed into them: a
            // leg and a match are different things to have won, and the
            // figures above have always meant legs.
            if (x01.matchesPlayed > 0)
              _Section(
                title: 'Matches',
                rows: [
                  _Row('Won', '${x01.matchesWon} of ${x01.matchesPlayed}'),
                  _Row('Win rate', _percent(x01.matchWinRate)),
                ],
              ),
          ],
          if (hasAtc) ...[
            if (hasX01) const SizedBox(height: Gap.xl),
            const _Eyebrow('AROUND THE CLOCK'),
            const SizedBox(height: Gap.sm),
            _Headline(
              value: _percent(atc.hitRate),
              label: 'Hit rate',
              detail: '${atc.qualifyingDarts} of ${atc.dartsThrown} darts',
            ),
            const SizedBox(height: Gap.xl),
            _Section(
              title: 'Legs',
              rows: [
                _Row('Won', '${atc.legsWon} of ${atc.legsPlayed}'),
                _Row('Win rate', _percent(atc.winRate)),
                _Row(
                  'Best leg',
                  _optional(atc.fewestDartsToWin, suffix: ' darts'),
                ),
              ],
            ),
            if (_weakestStops(atc.perStop) case final weak when weak.isNotEmpty)
              _Section(
                title: 'Weak spots',
                rows: [
                  for (final entry in weak)
                    _Row(
                      entry.key.label,
                      '${entry.value.hits}/${entry.value.attempts}',
                    ),
                ],
              ),
          ],
          if (hasBulling) ...[
            if (hasX01 || hasAtc) const SizedBox(height: Gap.xl),
            const _Eyebrow('BULLING'),
            const SizedBox(height: Gap.sm),
            _Headline(
              value: _percent(bulling.hitRate),
              label: 'Hit rate',
              detail: '${bulling.scoringDarts} of ${bulling.dartsThrown} darts',
            ),
            const SizedBox(height: Gap.xl),
            _Section(
              title: 'Legs',
              rows: [
                _Row('Won', '${bulling.legsWon} of ${bulling.legsPlayed}'),
                _Row('Win rate', _percent(bulling.winRate)),
                _Row(
                  'Best leg',
                  _optional(bulling.fewestDartsToWin, suffix: ' darts'),
                ),
              ],
            ),
            _Section(
              title: 'Scoring',
              rows: [
                _Row('Points scored', '${bulling.pointsScored}'),
                _Row('Outer bull hits', '${bulling.outerBullHits}'),
                _Row('Bullseye hits', '${bulling.innerBullHits}'),
              ],
            ),
          ],
          const SizedBox(height: Gap.lg),
          Text(
            'WHERE THE DARTS LAND',
            style: Type.eyebrow.copyWith(color: Palette.chalkDim),
          ),
          const SizedBox(height: Gap.xs),
          Text(
            counts.isEmpty
                ? 'No darts recorded yet.'
                : 'Shaded against the busiest segment.',
            style: Type.label.copyWith(color: Palette.chalkDim),
          ),
          const SizedBox(height: Gap.md),
          AspectRatio(
            aspectRatio: 1,
            child: BoardWidget(heat: _normalise(counts), showNumbers: false),
          ),
        ],
      ),
    );
  }

  /// Scales hit counts to 0..1 against the busiest segment, so the board reads
  /// as relative accuracy rather than raw volume.
  Map<Segment, double> _normalise(Map<Segment, int> counts) {
    if (counts.isEmpty) return const {};
    final busiest = counts.values.reduce((a, b) => a > b ? a : b);
    if (busiest == 0) return const {};
    return {
      for (final entry in counts.entries) entry.key: entry.value / busiest,
    };
  }

  /// The stops with the worst hit rate, capped to a handful and only
  /// counting ones actually attempted - a stop nobody has reached yet has
  /// nothing to say about how well it is thrown at.
  List<MapEntry<AtcStop, ({int attempts, int hits})>> _weakestStops(
    Map<AtcStop, ({int attempts, int hits})> perStop,
  ) {
    final attempted =
        perStop.entries.where((e) => e.value.attempts > 0).toList()..sort(
          (a, b) => (a.value.hits / a.value.attempts).compareTo(
            b.value.hits / b.value.attempts,
          ),
        );
    return attempted.take(5).toList();
  }

  static String _decimal(double? value) =>
      value == null ? '—' : value.toStringAsFixed(2);

  static String _percent(double? value) =>
      value == null ? '—' : '${(value * 100).toStringAsFixed(0)}%';

  static String _optional(int? value, {String suffix = ''}) =>
      value == null ? '—' : '$value$suffix';
}

/// A small tracked-caps label marking which mode's section follows, matching
/// the idiom used for field labels on the setup screen
/// (`x01_setup_screen.dart`'s `_Eyebrow`).
class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: Type.eyebrow.copyWith(color: Palette.chalkDim),
  );
}

class _Headline extends StatelessWidget {
  const _Headline({
    required this.value,
    required this.label,
    required this.detail,
  });

  final String value;
  final String label;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return _FadeIn(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Type.eyebrow.copyWith(color: Palette.live),
          ),
          const SizedBox(height: Gap.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: Type.score.copyWith(color: Palette.chalk),
            ),
          ),
          const SizedBox(height: Gap.sm),
          Text(detail, style: Type.label.copyWith(color: Palette.chalkDim)),
        ],
      ),
    );
  }
}

/// Rows rather than tiles: these are label-and-number pairs, and a row of them
/// under one heading is easier to scan down than a grid of boxes.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.rows});

  final String title;
  final List<_Row> rows;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.xl),
      child: _FadeIn(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: Type.eyebrow.copyWith(color: Palette.chalkDim),
            ),
            const SizedBox(height: Gap.sm),
            const Divider(),
            for (final row in rows) row,
          ],
        ),
      ),
    );
  }
}

/// A plain fade+rise on first build, for a record that otherwise appears
/// fully formed the moment its player is selected.
class _FadeIn extends StatelessWidget {
  const _FadeIn({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Motion.scale(Motion.base),
      curve: Motion.enter,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * 8),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.milestone = false});

  final String label;
  final String value;

  /// Marks a figure worth a second look - a 180, a personal-best checkout -
  /// rather than just another number in the record. Presentation only: it
  /// reads no differently to `computeX01Stats`, just a touch louder here.
  final bool milestone;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Palette.edge)),
      ),
      padding: const EdgeInsets.symmetric(vertical: Gap.md),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Type.body.copyWith(color: Palette.chalkDim),
            ),
          ),
          if (milestone) ...[
            const Icon(Icons.bolt, size: 15, color: Palette.live),
            const SizedBox(width: Gap.xs),
          ],
          Text(
            value,
            style: Type.notation.copyWith(
              color: milestone ? Palette.live : Palette.chalk,
            ),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.headline, required this.detail});

  final String headline;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Gap.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(headline, style: Type.title.copyWith(color: Palette.chalk)),
            const SizedBox(height: Gap.sm),
            Text(
              detail,
              textAlign: TextAlign.center,
              style: Type.body.copyWith(color: Palette.chalkDim),
            ),
          ],
        ),
      ),
    );
  }
}
