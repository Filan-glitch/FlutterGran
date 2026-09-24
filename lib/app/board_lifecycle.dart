import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/board/board_source.dart';
import '../l10n/app_localizations.dart';
import 'providers.dart';

/// The app's one [ScaffoldMessenger], so connection news can reach whichever
/// screen is showing without any of them asking for it.
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// Connection news worth a toast.
enum BoardToast { connected, lost, bluetoothOff }

/// What, if anything, the move from [previous] to [next] should announce.
///
/// Transitions only: a state that merely repeats says nothing, and the
/// in-between states - scanning, connecting - are the button's to show.
BoardToast? boardToastFor(
  BoardConnectionState? previous,
  BoardConnectionState next,
) {
  if (previous == next) return null;
  if (next.isConnected) return BoardToast.connected;
  if (previous == BoardConnectionState.connected &&
      next == BoardConnectionState.retrying) {
    return BoardToast.lost;
  }
  if (next == BoardConnectionState.bluetoothOff) return BoardToast.bluetoothOff;
  return null;
}

/// Keeps the board connected without anyone having to ask.
///
/// - At launch, connects if [autoConnectProvider] is on - once its stored
///   value has loaded, so a player who turned it off is never connected by
///   the default.
/// - Coming back to the foreground, retries at once if a board is wanted and
///   missing, instead of waiting out a backoff that grew while the app was
///   away. Not after a refused permission: the permission dialog itself
///   pauses and resumes the app, and retrying on that resume would ask again
///   in a loop.
/// - Announces connects, drops and Bluetooth going off in a toast.
///
/// A manual disconnect stops wanting the board, which is what keeps both the
/// resume retry and the source's own backoff out of it until the next tap or
/// launch. The app root keeps this alive by watching it.
final boardLifecycleProvider = Provider<void>((ref) {
  final source = ref.watch(boardSourceProvider);

  var disposed = false;
  ref.onDispose(() => disposed = true);

  Future<void> start() async {
    final autoConnect = ref.read(autoConnectProvider.notifier);
    await autoConnect.ready;
    if (disposed || !ref.read(autoConnectProvider)) return;
    if (!source.wantsConnection) await source.connect();
  }

  unawaited(start());

  final lifecycle = AppLifecycleListener(
    onResume: () {
      final state = source.currentState;
      if (!source.wantsConnection ||
          state.isConnected ||
          state.isWorking ||
          state == BoardConnectionState.unauthorized) {
        return;
      }
      unawaited(source.retryNow());
    },
  );
  ref.onDispose(lifecycle.dispose);

  ref.listen(boardConnectionProvider, (previous, next) {
    final toast = boardToastFor(previous, next);
    if (toast != null) _show(toast, source.boardName);
  });
});

void _show(BoardToast toast, String? boardName) {
  final messenger = scaffoldMessengerKey.currentState;
  final context = scaffoldMessengerKey.currentContext;
  if (messenger == null || context == null) return;
  final l10n = AppLocalizations.of(context);
  if (l10n == null) return;

  final text = switch (toast) {
    BoardToast.connected => boardName == null
        ? l10n.boardConnectedToastUnnamed
        : l10n.boardConnectedToast(boardName),
    BoardToast.lost => l10n.boardLostToast,
    BoardToast.bluetoothOff => l10n.bluetoothOffToast,
  };
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(text), duration: const Duration(seconds: 2)),
    );
}
