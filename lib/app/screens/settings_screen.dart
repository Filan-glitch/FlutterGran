import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../theme.dart';

/// App-wide preferences, away from any one game's setup.
///
/// Sound used to live on the setup screen because that was the only screen
/// there was - now that there is a proper menu shell, a switch that outlives
/// any single leg belongs here instead. More sections join this one as the
/// app grows things worth remembering across sessions.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('SETTINGS')),
      body: SafeArea(
        child: CenteredContent(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.sm, Gap.lg, Gap.lg),
            children: [
              const _Eyebrow('Sound'),
              const SizedBox(height: Gap.sm),
              _SoundToggle(
                label: 'Cues and commentary',
                detail:
                    'A click per dart, a buzz on a bust, a fanfare for a 180',
                value: ref.watch(soundEnabledProvider),
                onChanged: ref.read(soundEnabledProvider.notifier).set,
              ),
              _SoundToggle(
                label: 'Spoken totals',
                detail: 'Each turn read out loud',
                value: ref.watch(speechEnabledProvider),
                // With the master off there is nothing for this one to control,
                // so it greys out rather than pretending. Its own setting is
                // untouched underneath: turning sound back on returns the
                // commentary to however the player last left it.
                enabled: ref.watch(soundEnabledProvider),
                onChanged: ref.read(speechEnabledProvider.notifier).set,
              ),
            ],
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

/// One remembered switch, in the setup screen's idiom rather than Material's.
///
/// This lives on the settings screen, not behind a control on whatever screen
/// happens to be open when you think of it, because a preference that outlives
/// any one leg deserves one fixed address rather than a copy wherever it might
/// be wanted.
class _SoundToggle extends StatelessWidget {
  const _SoundToggle({
    required this.label,
    required this.detail,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final String label;
  final String detail;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final lit = enabled && value;

    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Type.body.copyWith(
                    color: enabled ? Palette.chalk : Palette.chalkDim,
                  ),
                ),
                const SizedBox(height: Gap.xs),
                Text(
                  detail,
                  style: Type.label.copyWith(
                    color: Palette.chalkDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: Gap.md),
          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
            // Live green, because this is state rather than a control.
            activeThumbColor: Palette.ground,
            activeTrackColor: lit ? Palette.live : Palette.chalkDim,
            inactiveThumbColor: Palette.chalkDim,
            inactiveTrackColor: Palette.sunk,
            trackOutlineColor: const WidgetStatePropertyAll(Palette.edge),
          ),
        ],
      ),
    );
  }
}
