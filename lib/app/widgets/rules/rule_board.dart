import 'package:flutter/material.dart';

import '../../../domain/segment.dart';
import '../../l10n_extensions.dart';
import '../../theme.dart';
import '../board_widget.dart';

/// A dartboard that shows which segments a rule lets count, by lighting them
/// in [Palette.live] - a picture of the rule rather than a sentence about it.
///
/// Look only: no taps, and one semantics label in place of the painted board.
/// [lit] is meant to come straight from the domain predicate the engine
/// itself uses (`X01InRule.opens`, `AtcStop.clears`, ...), so what lights up
/// here is what actually scores in a leg.
///
/// Changing [lit] fades the old set out and the new one in, rather than
/// cutting, so flipping between two options shows what changed.
class RuleBoard extends StatefulWidget {
  const RuleBoard({super.key, required this.lit, this.showNumbers = true});

  final Set<Segment> lit;
  final bool showNumbers;

  @override
  State<RuleBoard> createState() => _RuleBoardState();
}

class _RuleBoardState extends State<RuleBoard>
    with SingleTickerProviderStateMixin {
  /// How far a lit segment goes towards [Palette.live]: all the way would
  /// paint over the bed colours, and the board stops reading as a board.
  static const double _glow = 0.9;

  /// How far the segments a rule does not allow fade into the ground: far
  /// enough that the lit ones read at a glance, not so far the board stops
  /// looking like one.
  static const double _dim = 0.65;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Motion.scale(Motion.slow),
    value: 1,
  );

  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _controller,
    curve: Motion.enter,
  );

  Set<Segment> _from = const {};

  @override
  void didUpdateWidget(RuleBoard old) {
    super.didUpdateWidget(old);
    if (!_sameSet(old.lit, widget.lit)) {
      _from = old.lit;
      _controller.forward(from: 0);
    }
  }

  static bool _sameSet(Set<Segment> a, Set<Segment> b) =>
      a.length == b.length && a.containsAll(b);

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: context.l10n.rulesBoardSemantics,
      child: ExcludeSemantics(
        child: IgnorePointer(
          child: AnimatedBuilder(
            animation: _curve,
            builder: (context, _) {
              final t = _curve.value;
              final heat = <Segment, double>{
                for (final segment in {..._from, ...widget.lit})
                  segment:
                      _glow *
                      ((_from.contains(segment) ? 1 - t : 0) +
                              (widget.lit.contains(segment) ? t : 0))
                          .clamp(0.0, 1.0),
              };
              return BoardWidget(
                heat: heat,
                showNumbers: widget.showNumbers,
                dimUnheated: _dim,
              );
            },
          ),
        ),
      ),
    );
  }
}
