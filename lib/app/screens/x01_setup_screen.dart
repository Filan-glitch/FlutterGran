import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../../domain/x01/game_config.dart';
import '../../domain/x01/match_state.dart';
import '../../domain/x01/x01_rules.dart';
import '../../l10n/app_localizations.dart';
import '../l10n_extensions.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/board_connection_button.dart';
import '../widgets/selectable_tile.dart';
import 'game_screen.dart';

/// How each in/out rule reads on the setup chip and the stats screen's
/// checkout rows - the localized counterpart to [X01InRuleChecks.label],
/// which domain code (and tests) still use internally. Mirrors
/// `atc_setup_screen.dart`'s `atcVariantLabel`.
///
/// [X01InRule] and [X01OutRule] are separate enums (an in-rule and an
/// out-rule are independent choices) but share the same three member names,
/// so one name-keyed lookup serves both instead of two identical switches.
String _x01RuleLabel(BuildContext context, Enum rule) {
  final l10n = context.l10n;
  return switch (rule.name) {
    'straight' => l10n.x01RuleStraight,
    'double' => l10n.x01RuleDouble,
    'master' => l10n.x01RuleMaster,
    _ => throw ArgumentError('unknown rule: ${rule.name}'),
  };
}

String x01InRuleLabel(BuildContext context, X01InRule rule) =>
    _x01RuleLabel(context, rule);

/// The out-rule counterpart to [x01InRuleLabel].
String x01OutRuleLabel(BuildContext context, X01OutRule rule) =>
    _x01RuleLabel(context, rule);

/// Picks the x01 format and who is playing it, then starts a persisted leg.
///
/// Reached from Select Game Mode, so app branding, resuming an in-progress
/// leg, and the sound toggles all live elsewhere now (Main Menu and the
/// Settings screen respectively) - this screen is only the format and the
/// roster for the leg about to start.
class X01SetupScreen extends ConsumerStatefulWidget {
  const X01SetupScreen({super.key});

  @override
  ConsumerState<X01SetupScreen> createState() => _X01SetupScreenState();
}

class _X01SetupScreenState extends ConsumerState<X01SetupScreen> {
  final TextEditingController _newPlayer = TextEditingController();

  /// Selected players, in the order they were tapped - which is throwing order.
  final List<int> _seats = [];

  int _startScore = 501;
  X01InRule _inRule = X01InRule.straight;
  X01OutRule _outRule = X01OutRule.double;

  /// Best of this many legs. One is a single leg, exactly as the app has always
  /// played it.
  int _legsToPlay = 1;

  /// Whether the start score/rules have been seeded from the remembered
  /// defaults yet. Guards against a `ref.listen` firing after the initial
  /// synchronous fallback but overwriting something the user has already
  /// tapped in that first frame.
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

  @override
  void dispose() {
    _newPlayer.dispose();
    super.dispose();
  }

  Future<void> _addPlayer() async {
    final name = _newPlayer.text.trim();
    if (name.isEmpty) return;

    final player = await ref.read(gameRepositoryProvider).addPlayer(name);
    _newPlayer.clear();
    if (_seats.length < GameConfig.maxPlayers) {
      setState(() => _seats.add(player.id));
    }
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
    final players = ref.watch(playersProvider);

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
              _Eyebrow(l10n.startScoreLabel),
              const SizedBox(height: Gap.md),
              Row(
                key: const Key('start-score-row'),
                children: [
                  for (final score in GameConfig.offeredStartScores) ...[
                    if (score != GameConfig.offeredStartScores.first)
                      const SizedBox(width: Gap.sm),
                    Expanded(
                      child: _ScoreChoice(
                        score: score,
                        selected: score == _startScore,
                        onTap: () => setState(() {
                          _startScore = score;
                          _userEditedRules = true;
                        }),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: Gap.lg),
              // Directly under the start score and styled identically, because
              // the two together are the format: what you count down from, and
              // how many times.
              //
              // Above two players, more than half of the legs is a target nobody
              // need reach - three players can take one each - so the same choice
              // is named for the target it really sets. The stored format does
              // not change with the wording.
              _Eyebrow(_headToHead ? l10n.bestOfLabel : l10n.firstToLabel),
              const SizedBox(height: Gap.md),
              Row(
                children: [
                  for (final legs in offeredLegsToPlay) ...[
                    if (legs != offeredLegsToPlay.first)
                      const SizedBox(width: Gap.sm),
                    Expanded(
                      child: _ScoreChoice(
                        score: _headToHead ? legs : legsToWinFor(legs),
                        selected: legs == _legsToPlay,
                        onTap: () => setState(() => _legsToPlay = legs),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: Gap.lg),
              _Eyebrow(l10n.inRuleLabel),
              const SizedBox(height: Gap.md),
              Row(
                key: const Key('in-rule-row'),
                children: [
                  for (final rule in X01InRule.values) ...[
                    if (rule != X01InRule.values.first)
                      const SizedBox(width: Gap.sm),
                    Expanded(
                      child: SelectableTile(
                        key: Key('in-rule-${rule.name}'),
                        label: x01InRuleLabel(context, rule),
                        selected: rule == _inRule,
                        onTap: () => setState(() {
                          _inRule = rule;
                          _userEditedRules = true;
                        }),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: Gap.lg),
              _Eyebrow(l10n.outRuleLabel),
              const SizedBox(height: Gap.md),
              Row(
                key: const Key('out-rule-row'),
                children: [
                  for (final rule in X01OutRule.values) ...[
                    if (rule != X01OutRule.values.first)
                      const SizedBox(width: Gap.sm),
                    Expanded(
                      child: SelectableTile(
                        key: Key('out-rule-${rule.name}'),
                        label: x01OutRuleLabel(context, rule),
                        selected: rule == _outRule,
                        onTap: () => setState(() {
                          _outRule = rule;
                          _userEditedRules = true;
                        }),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: Gap.xl),
              Row(
                children: [
                  _Eyebrow(l10n.playersLabel),
                  const SizedBox(width: Gap.md),
                  Expanded(
                    child: Text(
                      _seats.isEmpty
                          ? l10n.tapToAddPlayers
                          : l10n.seatsOfMax(
                              _seats.length,
                              GameConfig.maxPlayers,
                            ),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Type.label.copyWith(color: Palette.chalkDim),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Gap.md),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newPlayer,
                      style: Type.body.copyWith(color: Palette.chalk),
                      cursorColor: Palette.live,
                      decoration: InputDecoration(
                        labelText: l10n.addPlayerFieldLabel,
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _addPlayer(),
                    ),
                  ),
                  const SizedBox(width: Gap.sm),
                  SizedBox(
                    height: 46,
                    width: 46,
                    child: FilledButton(
                      onPressed: _addPlayer,
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: const Icon(Icons.add, size: 22),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Gap.md),
              switch (players) {
                AsyncError(:final error) => Text(
                  l10n.couldNotLoadPlayers('$error'),
                  style: Type.body.copyWith(color: Palette.doubleBed),
                ),
                AsyncData(:final value) when value.isEmpty => Padding(
                  padding: const EdgeInsets.symmetric(vertical: Gap.xl),
                  child: Text(
                    l10n.noPlayersYet,
                    style: Type.body.copyWith(color: Palette.chalkDim),
                  ),
                ),
                AsyncData(:final value) => Column(
                  children: [for (final player in value) _tile(player, l10n)],
                ),
                // Deliberately blank rather than a spinner: this is a local
                // query that resolves in a frame, and a flash of spinner is
                // worse than nothing.
                _ => const SizedBox.shrink(),
              },
            ],
          ),
        ),
      ),
      bottomNavigationBar: CenteredContent(
        child: Padding(
          key: const Key('start-button-padding'),
          padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.lg),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              key: const Key('start-leg-button'),
              onPressed: _seats.isEmpty ? null : _start,
              child: Text(
                _seats.isEmpty
                    ? l10n.pickAtLeastOnePlayer
                    : _legsToPlay == 1
                    ? l10n.startLeg
                    : l10n.startBestOf(_legsToPlay),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tile(Player player, AppLocalizations l10n) {
    final seat = _seats.indexOf(player.id);
    final selected = seat >= 0;
    final full = _seats.length >= GameConfig.maxPlayers;

    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.sm),
      child: Material(
        color: selected ? Palette.raised : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: selected ? Palette.live : Palette.edge),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: selected
              ? () => setState(() => _seats.remove(player.id))
              : full
              ? null
              : () => setState(() => _seats.add(player.id)),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Gap.md,
              vertical: Gap.md,
            ),
            child: Row(
              children: [
                // The seat number is the throwing order, so it only appears
                // once a player actually has one.
                SizedBox(
                  width: 26,
                  child: Text(
                    selected ? '${seat + 1}' : '',
                    style: Type.notation.copyWith(color: Palette.live),
                  ),
                ),
                Expanded(
                  child: Text(
                    player.name,
                    style: Type.body.copyWith(
                      color: selected ? Palette.chalk : Palette.chalkDim,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  tooltip: l10n.removePlayerTooltip(player.name),
                  onPressed: () async {
                    setState(() => _seats.remove(player.id));
                    await ref
                        .read(gameRepositoryProvider)
                        .removePlayer(player.id);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: Type.eyebrow.copyWith(color: Palette.chalkDim),
  );
}

/// One number in a row of them, set as a scoreboard numeral rather than a form
/// control. Used for both halves of the format: the start score and the best-of.
class _ScoreChoice extends StatelessWidget {
  const _ScoreChoice({
    required this.score,
    required this.selected,
    required this.onTap,
  });

  final int score;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Palette.chalk : Palette.raised,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: selected ? Palette.chalk : Palette.edge),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Gap.md),
          child: Center(
            child: Text(
              '$score',
              style: Type.scoreSmall.copyWith(
                color: selected ? Palette.ground : Palette.chalkDim,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
