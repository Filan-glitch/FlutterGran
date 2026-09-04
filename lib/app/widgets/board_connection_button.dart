import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/board/board_source.dart';
import '../providers.dart';

/// One tap to connect the board, coloured by what it is doing.
///
/// This replaced a whole diagnostics screen after hardware day (2026-09-04)
/// confirmed the connection and protocol both work exactly as documented -
/// there is nothing left to verify, so nothing left to show. A single icon
/// button is the whole interface: tap to connect, tap again to disconnect,
/// and the colour says which.
///
/// White, blue and green are the only colours this button ever needs, chosen
/// against the house palette rather than from it: [Palette] is deliberately
/// all green plus one red (see its doc comment), but a connection light reads
/// by a convention older than this app - blue for Bluetooth, red for off,
/// green for on - and fighting that convention here would only make the icon
/// harder to read at a glance, which is the entire point of it.
class BoardConnectionButton extends ConsumerStatefulWidget {
  const BoardConnectionButton({super.key});

  @override
  ConsumerState<BoardConnectionButton> createState() =>
      _BoardConnectionButtonState();
}

class _BoardConnectionButtonState extends ConsumerState<BoardConnectionButton> {
  /// Whether the button has ever been tapped.
  ///
  /// [BoardConnectionState.disconnected] means both "never tried" and "tried
  /// and failed / dropped", and those have to look different or a player who
  /// has never touched the button would see the same red as one whose board
  /// just fell over. This is the bit that tells them apart.
  bool _attempted = false;

  Future<void> _toggle() async {
    final source = ref.read(boardSourceProvider);
    final state = ref.read(boardConnectionProvider).value ?? source.currentState;

    setState(() => _attempted = true);
    if (state.isConnected) {
      await source.disconnect();
    } else {
      await source.connect();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state =
        ref.watch(boardConnectionProvider).value ??
        ref.read(boardSourceProvider).currentState;

    final Color color;
    final String label;
    if (!_attempted) {
      color = Colors.white;
      label = 'Connect board';
    } else {
      (color, label) = switch (state) {
        BoardConnectionState.connected => (const Color(0xFF3D9C64), 'Board connected'),
        BoardConnectionState.scanning ||
        BoardConnectionState.connecting => (const Color(0xFF3B82F6), 'Connecting to board…'),
        BoardConnectionState.disconnected => (const Color(0xFFBF3B30), 'Board disconnected'),
      };
    }

    return IconButton(
      tooltip: label,
      icon: Icon(Icons.bluetooth, color: color),
      onPressed: _toggle,
    );
  }
}
