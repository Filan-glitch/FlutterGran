import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: SafeArea(
        child: CenteredContent(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.sm, Gap.lg, Gap.lg),
            children: [
              _Eyebrow(l10n.soundSectionTitle),
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
              _Eyebrow(l10n.languageSectionTitle),
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

/// System / English / German, in the setup screens' segmented-tile idiom
/// (`x01_setup_screen.dart`'s `_RuleChoice`) rather than a stock
/// `DropdownButton` or `RadioListTile`.
class _LanguageChoice extends StatelessWidget {
  const _LanguageChoice({required this.value, required this.onChanged});

  /// Null means "follow the system locale".
  final Locale? value;
  final ValueChanged<Locale?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final options = <Locale?, String>{
      null: l10n.languageSystemOption,
      const Locale('en'): l10n.languageEnglishOption,
      const Locale('de'): l10n.languageGermanOption,
    };

    return Row(
      children: [
        for (final entry in options.entries) ...[
          if (entry.key != options.keys.first) const SizedBox(width: Gap.sm),
          Expanded(
            child: _Tile(
              label: entry.value,
              selected: entry.key == value,
              onTap: () => onChanged(entry.key),
            ),
          ),
        ],
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
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
