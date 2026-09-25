import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n_extensions.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/setup_controls.dart';

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
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: SafeArea(
        child: CenteredContent(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.sm, Gap.lg, Gap.lg),
            children: [
              SectionLabel(l10n.soundSectionTitle),
              const SizedBox(height: Gap.sm),
              _SoundToggle(
                label: l10n.cuesAndCommentaryLabel,
                detail: l10n.cuesAndCommentaryDetail,
                value: ref.watch(soundEnabledProvider),
                onChanged: ref.read(soundEnabledProvider.notifier).set,
              ),
              _SoundToggle(
                label: l10n.spokenTotalsLabel,
                detail: l10n.spokenTotalsDetail,
                value: ref.watch(speechEnabledProvider),
                // With the master off there is nothing for this one to control,
                // so it greys out rather than pretending. Its own setting is
                // untouched underneath: turning sound back on returns the
                // commentary to however the player last left it.
                enabled: ref.watch(soundEnabledProvider),
                onChanged: ref.read(speechEnabledProvider.notifier).set,
              ),
              const SizedBox(height: Gap.lg),
              SectionLabel(l10n.boardLightsSectionTitle),
              const SizedBox(height: Gap.sm),
              _SoundToggle(
                label: l10n.boardLightsLabel,
                detail: l10n.boardLightsDetail,
                value: ref.watch(ledEnabledProvider),
                onChanged: ref.read(ledEnabledProvider.notifier).set,
              ),
              // Greyed under the master, the same way spoken totals are.
              for (final (label, detail, provider) in [
                (
                  l10n.dartFlashesLabel,
                  l10n.dartFlashesDetail,
                  ledDartFlashesProvider,
                ),
                (
                  l10n.targetRingLabel,
                  l10n.targetRingDetail,
                  ledTargetRingProvider,
                ),
                (
                  l10n.celebrationsLabel,
                  l10n.celebrationsDetail,
                  ledCelebrationsProvider,
                ),
              ])
                _SoundToggle(
                  label: label,
                  detail: detail,
                  value: ref.watch(provider),
                  enabled: ref.watch(ledEnabledProvider),
                  onChanged: ref.read(provider.notifier).set,
                ),
              const SizedBox(height: Gap.lg),
              SectionLabel(l10n.languageSectionTitle),
              const SizedBox(height: Gap.sm),
              _LanguageChoice(
                value: ref.watch(localeProvider),
                onChanged: ref.read(localeProvider.notifier).set,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// System / English / German, in the setup screens' [ChoiceRow] rather than a
/// stock `DropdownButton` or `RadioListTile`.
class _LanguageChoice extends StatelessWidget {
  const _LanguageChoice({required this.value, required this.onChanged});

  /// Null means "follow the system locale".
  final Locale? value;
  final ValueChanged<Locale?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final options = <Locale?, String>{
      null: l10n.languageSystemOption,
      const Locale('en'): l10n.languageEnglishOption,
      const Locale('de'): l10n.languageGermanOption,
    };

    return ChoiceRow<Locale?>(
      values: options.keys.toList(),
      selected: value,
      label: (locale) => options[locale]!,
      onSelected: onChanged,
    );
  }
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
