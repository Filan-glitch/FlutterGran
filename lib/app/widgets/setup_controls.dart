import 'package:flutter/material.dart';

import '../theme.dart';
import 'selectable_tile.dart';

/// Small tracked capitals naming the section under it, with an optional quiet
/// note on the right - "2 of 4" beside PLAYERS.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing});

  final String text;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final label = Text(
      text.toUpperCase(),
      style: Type.eyebrow.copyWith(color: Palette.chalkDim),
    );
    final trailing = this.trailing;
    if (trailing == null) return label;

    return Row(
      children: [
        label,
        const SizedBox(width: Gap.md),
        Expanded(
          child: Text(
            trailing,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Type.label.copyWith(color: Palette.chalkDim),
          ),
        ),
      ],
    );
  }
}

/// A row of numbers to pick one from, each set as a scoreboard numeral rather
/// than a form control: a start score, a best-of, a target. They are the
/// numbers everyone is about to play to, so they look like it.
class NumeralChoiceRow<T> extends StatelessWidget {
  const NumeralChoiceRow({
    super.key,
    required this.values,
    required this.selected,
    required this.label,
    required this.onSelected,
  });

  final List<T> values;
  final T selected;

  /// The numeral shown for a value.
  final String Function(T value) label;

  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < values.length; i++) ...[
          if (i > 0) const SizedBox(width: Gap.sm),
          Expanded(
            child: _Numeral(
              label: label(values[i]),
              selected: values[i] == selected,
              onTap: () => onSelected(values[i]),
            ),
          ),
        ],
      ],
    );
  }
}

class _Numeral extends StatelessWidget {
  const _Numeral({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
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
                label,
                style: Type.scoreSmall.copyWith(
                  color: selected ? Palette.ground : Palette.chalkDim,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A row of named options to pick one from - a rule, a variant, a language -
/// as equal-width [SelectableTile]s, so a row of three always reads as three
/// even when one name is longer than the others.
class ChoiceRow<T> extends StatelessWidget {
  const ChoiceRow({
    super.key,
    required this.values,
    required this.selected,
    required this.label,
    required this.onSelected,
    this.tileKey,
  });

  final List<T> values;
  final T selected;
  final String Function(T value) label;
  final ValueChanged<T> onSelected;

  /// A key per tile, for a test to tap one by.
  final Key Function(T value)? tileKey;

  @override
  Widget build(BuildContext context) {
    // Stretched to the tallest tile, so a name that wraps onto a second line
    // does not leave its neighbours short.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < values.length; i++) ...[
            if (i > 0) const SizedBox(width: Gap.sm),
            Expanded(
              child: SelectableTile(
                key: tileKey?.call(values[i]),
                label: label(values[i]),
                selected: values[i] == selected,
                onTap: () => onSelected(values[i]),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The one button a setup screen ends in, pinned under the form and as wide
/// as it.
class StartBar extends StatelessWidget {
  const StartBar({
    super.key,
    required this.label,
    required this.onPressed,
    this.buttonKey,
  });

  final String label;

  /// Null while there is not enough set up to start.
  final VoidCallback? onPressed;

  final Key? buttonKey;

  @override
  Widget build(BuildContext context) {
    return CenteredContent(
      child: Padding(
        key: const Key('start-button-padding'),
        padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.lg),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            key: buttonKey,
            onPressed: onPressed,
            child: Text(label),
          ),
        ),
      ),
    );
  }
}
