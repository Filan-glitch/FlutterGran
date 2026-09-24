import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/board/board_source.dart';
import '../l10n_extensions.dart';
import '../providers.dart';
import '../theme.dart';

/// The board connection light, in every screen's app bar.
///
/// Holds no state of its own: everything it shows comes from
/// [boardConnectionProvider], which is right from its first read. That is what
/// lets a screen opened mid-session show the same light as the one before it -
/// the old button kept "has this ever been tapped" per widget, so every new
/// screen started white whatever the board was doing.
///
/// One tap does the obvious thing for the state it is in: connect, cancel,
/// retry now, disconnect, or ask for Bluetooth to be switched on.
class BoardConnectionButton extends ConsumerWidget {
  const BoardConnectionButton({super.key});

  Future<void> _onTap(
    BuildContext context,
    WidgetRef ref,
    BoardConnectionState state,
  ) async {
    final source = ref.read(boardSourceProvider);
    switch (state) {
      case BoardConnectionState.disconnected ||
          BoardConnectionState.unauthorized:
        await source.connect();
      case BoardConnectionState.scanning ||
          BoardConnectionState.connecting ||
          BoardConnectionState.connected:
        await source.disconnect();
      case BoardConnectionState.retrying:
        await source.retryNow();
      case BoardConnectionState.bluetoothOff:
        final messenger = ScaffoldMessenger.maybeOf(context);
        final hint = context.l10n.turnOnBluetoothInSettings;
        if (!await source.turnOnBluetooth()) {
          messenger?.showSnackBar(SnackBar(content: Text(hint)));
        }
      case BoardConnectionState.unsupported:
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(boardConnectionProvider);
    final name = ref.read(boardSourceProvider).boardName;

    final (icon, color, label) = switch (state) {
      BoardConnectionState.disconnected => (
        Icons.bluetooth,
        Palette.chalk,
        l10n.connectBoardTooltip,
      ),
      BoardConnectionState.scanning || BoardConnectionState.connecting => (
        Icons.bluetooth_searching,
        Palette.bluetoothBlue,
        l10n.connectingToBoardTooltip,
      ),
      BoardConnectionState.retrying => (
        Icons.bluetooth_searching,
        Palette.bluetoothAmber,
        l10n.boardRetryingTooltip,
      ),
      BoardConnectionState.connected => (
        Icons.bluetooth_connected,
        Palette.trebleBed,
        name == null
            ? l10n.boardConnectedTooltip
            : l10n.boardConnectedNamedTooltip(name),
      ),
      BoardConnectionState.bluetoothOff => (
        Icons.bluetooth_disabled,
        Palette.doubleBed,
        l10n.bluetoothOffTooltip,
      ),
      BoardConnectionState.unauthorized => (
        Icons.bluetooth_disabled,
        Palette.doubleBed,
        l10n.bluetoothUnauthorizedTooltip,
      ),
      BoardConnectionState.unsupported => (
        Icons.bluetooth_disabled,
        Palette.chalkDim,
        l10n.bluetoothUnsupportedTooltip,
      ),
    };

    // Crossfades the glyph rather than swapping it outright, and pulses while
    // something is still being decided - looking, connecting, or waiting to
    // try again - so waiting looks like something is happening rather than
    // the icon having quietly changed its mind.
    Widget glyph = AnimatedSwitcher(
      duration: Motion.scale(Motion.base),
      child: Icon(icon, key: ValueKey((icon, color)), color: color),
    );
    if (state.isWorking) glyph = Pulse(child: glyph);
    if (state == BoardConnectionState.retrying) {
      glyph = Pulse(min: 0.35, child: glyph);
    }

    return IconButton(
      tooltip: label,
      icon: glyph,
      onPressed: state == BoardConnectionState.unsupported
          ? null
          : () => unawaited(_onTap(context, ref, state)),
    );
  }
}
