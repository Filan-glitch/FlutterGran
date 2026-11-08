/// [AddPlayerField], the name field and add button the roster and player picker
/// add players with.
///
/// {@category App}
library;

import 'package:flutter/material.dart';

import '../l10n_extensions.dart';
import '../theme.dart';

/// A name field with an add button beside it, for adding a player to the
/// roster. Submitting the field and pressing the button both call [onAdd];
/// reading and clearing [controller] is the caller's job.
class AddPlayerField extends StatelessWidget {
  const AddPlayerField({
    super.key,
    required this.controller,
    required this.onAdd,
  });

  final TextEditingController controller;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            style: Type.body.copyWith(color: Palette.chalk),
            cursorColor: Palette.live,
            decoration: InputDecoration(labelText: l10n.addPlayerFieldLabel),
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onAdd(),
          ),
        ),
        const SizedBox(width: Gap.sm),
        SizedBox(
          height: 46,
          width: 46,
          child: FilledButton(
            onPressed: onAdd,
            style: FilledButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: Icon(
              Icons.add,
              size: 22,
              semanticLabel: l10n.addPlayerFieldLabel,
            ),
          ),
        ),
      ],
    );
  }
}
