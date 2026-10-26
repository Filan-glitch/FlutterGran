import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n_extensions.dart';
import '../theme.dart';
import '../update/update_controller.dart';

/// Offers the newer release, and follows it through download and install.
///
/// Nothing at all while there is no release on offer - the check's own
/// states (checking, up to date, unreachable) are the settings screen's to
/// show, never the main menu's. The same card sits on both, so taking an
/// update reads the same wherever it is started from.
class UpdateCard extends ConsumerWidget {
  const UpdateCard({super.key, this.onDismiss, this.compact = false});

  /// Adds a close button.
  final VoidCallback? onDismiss;

  /// One row, for the main menu, which is laid out to fit a phone without
  /// scrolling and has no room for the full card above PLAY. It leaves out
  /// the line saying what the button does, keeping only news: progress, a
  /// permission to grant, a failure.
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(updateProvider);
    final release = state.release;
    if (release == null) return const SizedBox.shrink();

    final windows = defaultTargetPlatform == TargetPlatform.windows;
    final (status, action, news) = switch (state) {
      UpdateDownloading() => (l10n.updateDownloadingStatus, null, true),
      UpdateDownloaded(needsPermission: true) => (
        l10n.updatePermissionStatus,
        l10n.updateInstallButton,
        true,
      ),
      UpdateDownloaded() => (
        l10n.updateInstallingStatus,
        l10n.updateInstallButton,
        true,
      ),
      UpdateFailed(failure: UpdateFailure.download) => (
        l10n.updateDownloadFailedStatus,
        l10n.updateRetryButton,
        true,
      ),
      UpdateFailed() => (
        l10n.updateInstallFailedStatus,
        l10n.updateRetryButton,
        true,
      ),
      _ => (
        windows ? l10n.updateWindowsDetail : l10n.updateAndroidDetail,
        windows ? l10n.updateDownloadButton : l10n.updateInstallButton,
        false,
      ),
    };
    final failed = state is UpdateFailed;

    final eyebrow = Text(
      l10n.updateAvailableEyebrow,
      style: Type.eyebrow.copyWith(color: Palette.live),
    );
    final title = Text(
      l10n.updateAvailableTitle('${release.version}'),
      style: Type.body.copyWith(color: Palette.chalk),
    );
    final statusLine = Text(
      status,
      style: Type.label.copyWith(
        color: failed ? Palette.doubleBed : Palette.chalkDim,
        fontSize: 12,
      ),
    );
    final progress = switch (state) {
      UpdateDownloading(:final progress) => ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: LinearProgressIndicator(
          value: progress,
          minHeight: 4,
          color: Palette.live,
          backgroundColor: Palette.sunk,
        ),
      ),
      _ => null,
    };
    final button = action == null
        ? null
        : FilledButton(
            key: const Key('update-card-action'),
            onPressed: () => ref.read(updateProvider.notifier).apply(),
            child: Text(action),
          );
    final dismiss = onDismiss == null
        ? null
        : SizedBox.square(
            dimension: 24,
            child: IconButton(
              key: const Key('update-card-dismiss'),
              padding: EdgeInsets.zero,
              iconSize: 18,
              tooltip: l10n.updateDismissTooltip,
              onPressed: onDismiss,
              icon: const Icon(Icons.close, color: Palette.chalkDim),
            ),
          );

    final content = compact
        ? Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    eyebrow,
                    const SizedBox(height: Gap.xs),
                    title,
                    if (news) statusLine,
                  ],
                ),
              ),
              const SizedBox(width: Gap.md),
              if (progress != null)
                SizedBox(width: 64, child: progress)
              else
                ?button,
              if (dismiss != null) ...[const SizedBox(width: Gap.sm), dismiss],
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [eyebrow, const Spacer(), ?dismiss]),
              const SizedBox(height: Gap.sm),
              title,
              const SizedBox(height: Gap.xs),
              statusLine,
              const SizedBox(height: Gap.md),
              if (progress != null)
                progress
              else if (button != null)
                Align(alignment: Alignment.centerRight, child: button),
            ],
          );

    return Material(
      key: const Key('update-card'),
      color: Palette.raised,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: Palette.live),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(padding: const EdgeInsets.all(Gap.md), child: content),
    );
  }
}
