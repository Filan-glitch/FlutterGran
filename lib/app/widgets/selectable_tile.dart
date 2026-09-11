import 'package:flutter/material.dart';

import '../theme.dart';

/// One choice in a row of mutually-exclusive options - an x01 in/out rule, a
/// language - rendered as an uppercase label centered in a tile that fills
/// solid when selected. Used wherever a setup or settings screen offers a
/// small, fixed set of choices as equal-width tiles rather than a dropdown.
class SelectableTile extends StatelessWidget {
  const SelectableTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
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
              label.toUpperCase(),
              style: Type.label.copyWith(
                color: selected ? Palette.ground : Palette.chalkDim,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
