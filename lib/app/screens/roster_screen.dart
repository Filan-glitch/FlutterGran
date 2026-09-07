import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart';
import '../providers.dart';
import '../theme.dart';

/// Add, rename, and remove players - the roster shared by every game mode.
///
/// Player management used to live inside the x01 setup screen, but a roster
/// is not a property of a mode: the same people play whatever is selected
/// next, so it gets its own screen with no mode concept anywhere in it.
class RosterScreen extends ConsumerStatefulWidget {
  const RosterScreen({super.key});

  @override
  ConsumerState<RosterScreen> createState() => _RosterScreenState();
}

class _RosterScreenState extends ConsumerState<RosterScreen> {
  final TextEditingController _newPlayer = TextEditingController();

  /// Ids hidden from the rendered list while their delete is still
  /// undoable.
  ///
  /// Nothing is written to the database when a hold-to-delete fires - the id
  /// just leaves the list the roster is built from. That is what makes undo
  /// free: reversing it is deleting the id from this set, not restoring a row
  /// that was never removed.
  final Set<int> _pendingDeleteIds = {};

  @override
  void dispose() {
    _newPlayer.dispose();
    super.dispose();
  }

  Future<void> _addPlayer() async {
    final name = _newPlayer.text.trim();
    if (name.isEmpty) return;

    await ref.read(gameRepositoryProvider).addPlayer(name);
    _newPlayer.clear();
  }

  Future<void> _rename(Player player, String newName) =>
      ref.read(gameRepositoryProvider).renamePlayer(player.id, newName);

  /// Starts the undo window for deleting [player].
  ///
  /// The player disappears from the list the moment this is called - held
  /// long enough to fire a long press, holding a dart, is already enough
  /// intent to act on optimistically. The real, cascading delete is deferred
  /// to the snackbar's own close callback, which is the one place that can
  /// tell "timed out" and "UNDO was tapped" apart.
  void _startDelete(Player player) {
    setState(() => _pendingDeleteIds.add(player.id));

    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            content: Text('Removed ${player.name}'),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () {
                if (!mounted) return;
                setState(() => _pendingDeleteIds.remove(player.id));
              },
            ),
          ),
        )
        .closed
        .then((reason) {
          // UNDO already put the player back and left nothing to commit.
          if (reason == SnackBarClosedReason.action) return;
          // Already resolved - by UNDO racing this callback, or by a second
          // call somehow landing for the same id. Either way there is
          // nothing left to delete for real.
          if (!_pendingDeleteIds.remove(player.id)) return;
          if (!mounted) return;
          ref.read(gameRepositoryProvider).removePlayer(player.id);
        });
  }

  List<Player> _visible(List<Player> players) => [
    for (final player in players)
      if (!_pendingDeleteIds.contains(player.id)) player,
  ];

  @override
  Widget build(BuildContext context) {
    final players = ref.watch(playersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('ROSTER')),
      body: SafeArea(
        child: CenteredContent(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.lg, Gap.lg, Gap.lg),
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newPlayer,
                      style: Type.body.copyWith(color: Palette.chalk),
                      cursorColor: Palette.live,
                      decoration: const InputDecoration(
                        labelText: 'Add a player',
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _addPlayer(),
                    ),
                  ),
                  const SizedBox(width: Gap.sm),
                  SizedBox(
                    height: 46,
                    width: 46,
                    child: FilledButton(
                      onPressed: _addPlayer,
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: const Icon(Icons.add, size: 22),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Gap.lg),
              switch (players) {
                AsyncError(:final error) => Text(
                  'Could not load players: $error',
                  style: Type.body.copyWith(color: Palette.doubleBed),
                ),
                AsyncData(:final value) when _visible(value).isEmpty =>
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: Gap.xl),
                    child: Text(
                      'No players yet. Add the first one above.',
                      style: Type.body.copyWith(color: Palette.chalkDim),
                    ),
                  ),
                AsyncData(:final value) => Column(
                  children: [
                    for (final player in _visible(value))
                      _PlayerTile(
                        key: ValueKey(player.id),
                        player: player,
                        onRename: (name) => _rename(player, name),
                        onDelete: () => _startDelete(player),
                      ),
                  ],
                ),
                // Deliberately blank rather than a spinner: this is a local
                // query that resolves in a frame, and a flash of spinner is
                // worse than nothing.
                _ => const SizedBox.shrink(),
              },
            ],
          ),
        ),
      ),
    );
  }
}

/// One row of the roster: a name that becomes a text field when tapped, and
/// a delete affordance that only acts on a hold.
class _PlayerTile extends StatefulWidget {
  const _PlayerTile({
    required super.key,
    required this.player,
    required this.onRename,
    required this.onDelete,
  });

  final Player player;

  /// Called with the trimmed, non-empty, actually-changed new name. The tile
  /// itself is the guard against a blank or no-op commit - the caller never
  /// sees one.
  final ValueChanged<String> onRename;
  final VoidCallback onDelete;

  @override
  State<_PlayerTile> createState() => _PlayerTileState();
}

class _PlayerTileState extends State<_PlayerTile> {
  bool _editing = false;
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.player.name);
    _focusNode = FocusNode()..addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant _PlayerTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A rename lands back here as new provider data a moment after it is
    // sent. Only picked up while not editing, so a keystroke in progress is
    // never clobbered by the very commit it caused.
    if (!_editing && widget.player.name != oldWidget.player.name) {
      _controller.text = widget.player.name;
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) _commit();
  }

  void _startEditing() {
    _controller.text = widget.player.name;
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _controller.text.length,
    );
    setState(() => _editing = true);
    _focusNode.requestFocus();
  }

  void _commit() {
    if (!_editing) return;
    final trimmed = _controller.text.trim();
    setState(() => _editing = false);

    // Renaming to blank is rejected client-side rather than sent to the
    // repository: `Players.name` has a minimum length at the database level,
    // and a blank commit would throw there instead of just being a no-op.
    if (trimmed.isEmpty || trimmed == widget.player.name) {
      _controller.text = widget.player.name;
      return;
    }
    widget.onRename(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.sm),
      child: Material(
        color: Palette.raised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: Palette.edge),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Gap.md,
            vertical: Gap.xs,
          ),
          child: Row(
            children: [
              Expanded(
                child: _editing
                    ? TextField(
                        key: Key('rename-field-${widget.player.id}'),
                        controller: _controller,
                        focusNode: _focusNode,
                        autofocus: true,
                        style: Type.body.copyWith(color: Palette.chalk),
                        cursorColor: Palette.live,
                        decoration: const InputDecoration(isDense: true),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) {
                          _commit();
                          _focusNode.unfocus();
                        },
                        onTapOutside: (_) => _focusNode.unfocus(),
                      )
                    : InkWell(
                        key: Key('player-name-${widget.player.id}'),
                        onTap: _startEditing,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: Gap.md,
                          ),
                          child: Text(
                            widget.player.name,
                            style: Type.body.copyWith(color: Palette.chalk),
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: Gap.sm),
              Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  key: Key('delete-player-${widget.player.id}'),
                  // A single tap does nothing destructive on purpose - the
                  // whole point of hold-to-delete is that a tap alone can
                  // never remove anyone.
                  onTap: () {},
                  onLongPress: widget.onDelete,
                  child: const Padding(
                    padding: EdgeInsets.all(Gap.sm),
                    child: Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: Palette.chalkDim,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
