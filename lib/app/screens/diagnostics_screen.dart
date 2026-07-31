import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/board/board_source.dart';
import '../../domain/board_event.dart';
import '../../domain/segment.dart';
import '../providers.dart';
import '../widgets/board_widget.dart';

/// Hardware bring-up: watch what the board actually sends, and correct the
/// segment table where it disagrees.
///
/// The shipped table is derived from the GRANBOARD 3s and has never been
/// verified against a 132. This screen is how that gets settled - and a wrong
/// mapping shows up here as a plainly wrong label rather than as a
/// plausible-looking wrong score in the middle of a leg.
class DiagnosticsScreen extends ConsumerStatefulWidget {
  const DiagnosticsScreen({super.key});

  @override
  ConsumerState<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends ConsumerState<DiagnosticsScreen> {
  static const int _historyLength = 25;

  final List<ObservedFrame> _history = [];
  StreamSubscription<ObservedFrame>? _subscription;

  @override
  void initState() {
    super.initState();
    // Deferred: reading providers during initState would run before the first
    // build has established the dependency.
    WidgetsBinding.instance.addPostFrameCallback((_) => _listen());
  }

  void _listen() {
    _subscription = ref.read(boardReaderProvider).frames.listen((frame) {
      if (!mounted) return;
      setState(() {
        _history.insert(0, frame);
        if (_history.length > _historyLength) _history.removeLast();
      });
    });
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  Future<void> _record(ObservedFrame frame, Segment actual) async {
    final shipped = frame.event is DartHit
        ? (frame.event as DartHit).segment
        : null;

    await ref
        .read(gameRepositoryProvider)
        .recordCalibration(
          body: frame.body,
          segment: actual,
          corrected: actual != shipped,
        );
  }

  Future<void> _correct(ObservedFrame frame) async {
    final actual = await showDialog<Segment>(
      context: context,
      builder: (context) => _SegmentPickerDialog(body: frame.body),
    );
    if (actual == null) return;
    await _record(frame, actual);
  }

  @override
  Widget build(BuildContext context) {
    // Keeps calibration corrections flowing into the live decoder.
    ref.watch(calibrationSyncProvider);

    final mode = ref.watch(boardModeProvider);
    final connection = ref.watch(boardConnectionProvider).value;
    final coverage = ref.watch(calibrationCoverageProvider);
    final source = ref.watch(boardSourceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Board diagnostics'),
        actions: [
          IconButton(
            tooltip: 'Clear calibration',
            icon: const Icon(Icons.restart_alt),
            onPressed: () async =>
                ref.read(gameRepositoryProvider).clearAllCalibrations(),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<BoardMode>(
              segments: [
                for (final option in BoardMode.values)
                  ButtonSegment(value: option, label: Text(option.label)),
              ],
              selected: {mode},
              onSelectionChanged: (selection) async {
                await ref.read(boardSourceProvider).disconnect();
                ref.read(boardModeProvider.notifier).set(selection.first);
                // The source is rebuilt by the mode change; resubscribe to it.
                await _subscription?.cancel();
                _listen();
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Chip(
                  label: Text(
                    (connection ?? source.currentState).name,
                  ),
                  avatar: Icon(
                    (connection ?? source.currentState).isConnected
                        ? Icons.bluetooth_connected
                        : Icons.bluetooth_disabled,
                    size: 18,
                  ),
                ),
                const Spacer(),
                FilledButton.tonal(
                  onPressed: source.connect,
                  child: const Text('Connect'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: source.disconnect,
                  child: const Text('Disconnect'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _CoverageSummary(coverage: coverage),
            const SizedBox(height: 20),
            Text('Frames', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Throw at a segment, then confirm the label or correct it.',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 8),
            if (_history.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('Nothing received yet.'),
              )
            else
              for (final frame in _history)
                _FrameRow(
                  frame: frame,
                  confirmed: frame.event is DartHit &&
                      coverage.contains((frame.event as DartHit).segment),
                  onConfirm: frame.event is DartHit
                      ? () => _record(frame, (frame.event as DartHit).segment)
                      : null,
                  onCorrect: () => _correct(frame),
                ),
          ],
        ),
      ),
    );
  }
}

class _CoverageSummary extends StatelessWidget {
  const _CoverageSummary({required this.coverage});

  final Set<Segment> coverage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = Segment.all.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Coverage', style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          '${coverage.length} of $total segments verified',
          style: theme.textTheme.labelSmall,
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: coverage.length / total),
        const SizedBox(height: 12),
        // One cell per scoring area, so it is obvious what has not been thrown
        // at yet. Order follows the board, not the segment list.
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            for (final segment in _boardOrder)
              Container(
                width: 46,
                padding: const EdgeInsets.symmetric(vertical: 3),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: coverage.contains(segment)
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceContainerHighest,
                ),
                child: Text(
                  segment.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: coverage.contains(segment)
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.outline,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  static final List<Segment> _boardOrder = [
    for (final number in boardWedgeOrder)
      for (final ring in const [
        Ring.innerSingle,
        Ring.triple,
        Ring.outerSingle,
        Ring.doubleRing,
      ])
        Segment(number, ring),
    Segment.outerBull,
    Segment.innerBull,
  ];
}

class _FrameRow extends StatelessWidget {
  const _FrameRow({
    required this.frame,
    required this.confirmed,
    required this.onConfirm,
    required this.onCorrect,
  });

  final ObservedFrame frame;
  final bool confirmed;
  final VoidCallback? onConfirm;
  final VoidCallback onCorrect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final (label, colour) = switch (frame.event) {
      DartHit(:final segment) => (segment.label, null),
      ButtonPress() => ('button', null),
      BoardMiss() => ('miss', null),
      UnknownFrame() => ('UNKNOWN', theme.colorScheme.error),
    };

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: SizedBox(
        width: 64,
        child: Text(
          frame.body,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontFamily: 'monospace',
          ),
        ),
      ),
      title: Text(
        label,
        style: theme.textTheme.titleMedium?.copyWith(color: colour),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (confirmed)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.check, size: 18),
            ),
          if (onConfirm != null)
            TextButton(onPressed: onConfirm, child: const Text('Right')),
          TextButton(onPressed: onCorrect, child: const Text('Wrong')),
        ],
      ),
    );
  }
}

/// Picks the segment a frame code really means.
class _SegmentPickerDialog extends StatelessWidget {
  const _SegmentPickerDialog({required this.body});

  final String body;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('What does "$body" really mean?'),
      content: SizedBox(
        width: 320,
        height: 320,
        child: BoardWidget(
          onSegmentTapped: (segment) => Navigator.of(context).pop(segment),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
