import 'dart:math';

import 'package:flutter/material.dart';

import '../../../domain/segment.dart';
import '../../theme.dart';
import '../setup_controls.dart';
import 'rule_board.dart';

/// Width, in unscaled logical pixels, from which a [RuleExplorer] puts its
/// board beside the options instead of under them. Multiplied by the text
/// scale where it is used: a tablet's 1.5x labels need the extra room just as
/// much as a phone's would.
const double _sideBySideWidth = 560;

/// One rule with a few settings - an out rule, an Around the Clock variant -
/// taught by letting the reader flip between them and watch a [RuleBoard]
/// light up what each one allows.
///
/// Narrow, it is the setup screens' own [ChoiceRow] over the board, with the
/// chosen option's explanation under it. Wide, the board sits on the left and
/// every option is a tile on the right with its explanation always showing,
/// selected the same way a setup tile is - filled with chalk.
///
/// Keys: `rule-explorer-<id>` on the whole thing, `rule-option-<id>-<name>`
/// on each option's tile, for a test to tap.
class RuleExplorer<T extends Enum> extends StatefulWidget {
  const RuleExplorer({
    super.key,
    required this.id,
    required this.values,
    required this.initial,
    required this.label,
    required this.explanation,
    required this.lit,
    required this.legend,
    this.detail,
  });

  final String id;
  final List<T> values;
  final T initial;
  final String Function(T value) label;
  final String Function(T value) explanation;

  /// The segments that count under a value.
  final Set<Segment> Function(T value) lit;

  /// What lit means here, in small capitals under the board.
  final String legend;

  /// Anything else that changes with the value - Bulling's points table.
  final Widget Function(T value)? detail;

  @override
  State<RuleExplorer<T>> createState() => _RuleExplorerState<T>();
}

class _RuleExplorerState<T extends Enum> extends State<RuleExplorer<T>> {
  late T _selected = widget.initial;

  void _select(T value) => setState(() => _selected = value);

  Key _optionKey(T value) => Key('rule-option-${widget.id}-${value.name}');

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1);

    return LayoutBuilder(
      key: Key('rule-explorer-${widget.id}'),
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return width >= _sideBySideWidth * scale
            ? _sideBySide(width)
            : _stacked(width);
      },
    );
  }

  Widget _board(double side) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox.square(
        dimension: side,
        child: RuleBoard(lit: widget.lit(_selected)),
      ),
      const SizedBox(height: Gap.sm),
      Text(
        widget.legend,
        textAlign: TextAlign.center,
        style: Type.eyebrow.copyWith(color: Palette.live),
      ),
    ],
  );

  Widget _stacked(double width) {
    final detail = widget.detail;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ChoiceRow<T>(
          values: widget.values,
          selected: _selected,
          label: widget.label,
          tileKey: _optionKey,
          onSelected: _select,
        ),
        const SizedBox(height: Gap.lg),
        Center(child: _board(min(width, 280))),
        const SizedBox(height: Gap.md),
        AnimatedSwitcher(
          duration: Motion.scale(Motion.base),
          switchInCurve: Motion.enter,
          switchOutCurve: Motion.exit,
          child: Text(
            widget.explanation(_selected),
            key: ValueKey(_selected),
            textAlign: TextAlign.center,
            style: Type.body.copyWith(color: Palette.chalk),
          ),
        ),
        if (detail != null) ...[
          const SizedBox(height: Gap.lg),
          detail(_selected),
        ],
      ],
    );
  }

  Widget _sideBySide(double width) {
    final detail = widget.detail;
    return Row(
      children: [
        _board(min(width * 0.4, 420)),
        const SizedBox(width: Gap.xl),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final value in widget.values) ...[
                if (value != widget.values.first)
                  const SizedBox(height: Gap.sm),
                _OptionTile(
                  key: _optionKey(value),
                  label: widget.label(value),
                  explanation: widget.explanation(value),
                  selected: value == _selected,
                  onTap: () => _select(value),
                ),
              ],
              if (detail != null) ...[
                const SizedBox(height: Gap.lg),
                detail(_selected),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// One option on a wide [RuleExplorer]: its name and what it does, filled
/// with chalk while it is the one lit on the board.
class _OptionTile extends StatelessWidget {
  const _OptionTile({
    super.key,
    required this.label,
    required this.explanation,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String explanation;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final duration = Motion.scale(Motion.base);
    return Semantics(
      selected: selected,
      button: true,
      child: AnimatedContainer(
        duration: duration,
        curve: Motion.enter,
        decoration: BoxDecoration(
          color: selected ? Palette.chalk : Palette.raised,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: selected ? Palette.chalk : Palette.edge),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Gap.lg,
                vertical: Gap.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: Type.eyebrow.copyWith(
                      fontSize: 12,
                      color: selected ? Palette.ground : Palette.chalk,
                    ),
                  ),
                  const SizedBox(height: Gap.xs),
                  Text(
                    explanation,
                    style: Type.body.copyWith(
                      color: selected ? Palette.ground : Palette.chalkDim,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
