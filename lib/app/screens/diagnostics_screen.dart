import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/board/board_source.dart';
import '../../domain/board_event.dart';
import '../../domain/segment.dart';
import '../providers.dart';
import '../theme.dart';
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
        title: const Text('BOARD DIAGNOSTICS'),
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
        child: CenteredContent(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SegmentedButton<BoardMode>(
                segments: [
                  for (final option in BoardMode.values)
                    ButtonSegment(
                      value: option,
                      label: Text(option.label.toUpperCase()),
                    ),
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
                  _ConnectionPill(state: connection ?? source.currentState),
                  const Spacer(),
                  FilledButton(
                    onPressed: source.connect,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Gap.lg,
                        vertical: Gap.md,
                      ),
                    ),
                    child: const Text('CONNECT'),
                  ),
                  const SizedBox(width: Gap.sm),
                  OutlinedButton(
                    onPressed: source.disconnect,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Gap.lg,
                        vertical: Gap.md,
                      ),
                    ),
                    child: const Text('DISCONNECT'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _CoverageSummary(coverage: coverage),
              const SizedBox(height: 20),
              Text(
                'FRAMES',
                style: Type.eyebrow.copyWith(color: Palette.chalkDim),
              ),
              const SizedBox(height: Gap.xs),
              Text(
                'Throw at a segment, then confirm the label or correct it.',
                style: Type.label.copyWith(color: Palette.chalkDim),
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
                    confirmed:
                        frame.event is DartHit &&
                        coverage.contains((frame.event as DartHit).segment),
                    onConfirm: frame.event is DartHit
                        ? () => _record(frame, (frame.event as DartHit).segment)
                        : null,
                    onCorrect: () => _correct(frame),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Connection state as a bluetooth glyph, a word, and a colour.
///
/// The glyph says what this is about at a glance; the word carries the state,
/// because "scanning" and "connecting" are indistinguishable as icons and
/// telling them apart is the whole point during bring-up.
class _ConnectionPill extends StatelessWidget {
  const _ConnectionPill({required this.state});

  final BoardConnectionState state;

  @override
  Widget build(BuildContext context) {
    final colour = switch (state) {
      BoardConnectionState.connected => Palette.trebleBed,
      BoardConnectionState.scanning ||
      BoardConnectionState.connecting => Palette.live,
      BoardConnectionState.disconnected => Palette.chalkDim,
    };

    final glyph = switch (state) {
      BoardConnectionState.connected => Icons.bluetooth_connected,
      BoardConnectionState.scanning => Icons.bluetooth_searching,
      BoardConnectionState.connecting => Icons.bluetooth_searching,
      BoardConnectionState.disconnected => Icons.bluetooth_disabled,
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(glyph, size: 18, color: colour),
        const SizedBox(width: Gap.sm),
        Text(
          state.name.toUpperCase(),
          style: Type.eyebrow.copyWith(color: colour),
        ),
      ],
    );
  }
}

class _CoverageSummary extends StatelessWidget {
  const _CoverageSummary({required this.coverage});

  final Set<Segment> coverage;

  @override
  Widget build(BuildContext context) {
    final total = Segment.all.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('COVERAGE', style: Type.eyebrow.copyWith(color: Palette.chalkDim)),
        const SizedBox(height: Gap.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '${coverage.length}',
              style: Type.scoreSmall.copyWith(
                color: coverage.length == total
                    ? Palette.trebleBed
                    : Palette.chalk,
              ),
            ),
            const SizedBox(width: Gap.xs),
            Text(
              'of $total segments verified',
              style: Type.label.copyWith(color: Palette.chalkDim),
            ),
          ],
        ),
        const SizedBox(height: Gap.sm),
        LinearProgressIndicator(value: coverage.length / total),
        const SizedBox(height: Gap.md),
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
                      ? Palette.trebleBed
                      : Palette.sunk,
                  border: Border.all(color: Palette.edge),
                ),
                child: Text(
                  segment.label,
                  style: Type.eyebrow.copyWith(
                    letterSpacing: 0.4,
                    color: coverage.contains(segment)
                        ? Palette.chalk
                        : Palette.chalkDim,
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
    final (label, colour) = switch (frame.event) {
      DartHit(:final segment) => (segment.label, Palette.chalk),
      ButtonPress() => ('BUTTON', Palette.chalkDim),
      BoardMiss() => ('MISS', Palette.chalkDim),
      UnknownFrame() => ('UNKNOWN', Palette.doubleBed),
    };

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: SizedBox(
        width: 64,
        child: Text(frame.body, style: Type.data.copyWith(color: Palette.live)),
      ),
      title: Text(label, style: Type.notation.copyWith(color: colour)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (confirmed)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.check, size: 18),
            ),
          if (onConfirm != null)
            TextButton(onPressed: onConfirm, child: const Text('RIGHT')),
          TextButton(onPressed: onCorrect, child: const Text('WRONG')),
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
