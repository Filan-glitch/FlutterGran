import 'package:flutter/material.dart';

import '../theme.dart';

/// One seat on the scoreboard, in whatever terms its game keeps score.
///
/// Every mode fills the same slots - a name, one figure big enough to read
/// from the oche, a line under it - so every mode reads the same way at
/// throwing distance, whatever the figure happens to mean: a remaining score,
/// the stop still needed, points towards a target.
class SeatView {
  const SeatView({
    required this.name,
    this.count,
    this.label,
    this.caption,
    this.heroCaption,
    this.tally,
    this.tallyLit = false,
    this.progress,
    this.ticks,
    required this.live,
    required this.won,
  }) : assert(
         (count == null) != (label == null),
         'a seat shows a count or a label, not both',
       );

  final String name;

  /// A figure that counts between values as it changes - a score.
  final int? count;

  /// A figure that is not a number to count through - a stop like `BULL`,
  /// an average - and crossfades instead.
  final String? label;

  /// The quiet line under the figure.
  final String? caption;

  /// [caption] on a hero card, which has the room to say more. Falls back to
  /// [caption].
  final String? heroCaption;

  /// A standing that is not this leg's live state - legs won, checkouts
  /// made - so it never takes [Palette.live].
  final String? tally;

  /// Whether [tally] has anything in it yet worth drawing in chalk rather
  /// than receding.
  final bool tallyLit;

  /// How far along the race to the finish this seat is, 0 to 1, for games
  /// whose figure alone does not say it. Null draws no rail.
  final double? progress;

  /// Draws the rail as this many separate steps rather than one fill - a
  /// track of stops, not a quantity.
  final int? ticks;

  /// At the oche right now.
  final bool live;
  final bool won;

  bool get lit => live || won;

  /// The colour a lit seat's accents take: pale for the thrower, the treble
  /// bed's green for a winner.
  Color get accent => won ? Palette.trebleBed : Palette.live;
}

/// Players side by side, split by a hairline, as on a chalk scoreboard.
///
/// Only the player at the oche is lit: their column carries the pale rule and
/// chalk-white numerals, everyone else recedes. At throwing distance that is
/// the fastest way to answer "whose turn, and what do they need".
class Scoreboard extends StatelessWidget {
  const Scoreboard({
    super.key,
    required this.seats,
    required this.hero,
    this.expand = false,
  });

  final List<SeatView> seats;

  /// Whether the device earns the per-seat card treatment. See [heroLayout].
  final bool hero;

  /// Whether this is the only thing sharing the screen with the aim panel -
  /// a real board scoring for itself, nothing keyed in by hand to stack a
  /// keypad's height against. Every seat gets a card as tall as the height
  /// that would otherwise sit empty under it, instead of one sized to its own
  /// content and stranded above blank space.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    if (hero) {
      final row = Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < seats.length; i++) ...[
            if (i > 0) const SizedBox(width: Gap.md),
            Expanded(child: _HeroSeatCard(seat: seats[i])),
          ],
        ],
      );

      return Padding(
        key: const Key('hero-scoreboard'),
        padding: const EdgeInsets.symmetric(
          horizontal: Gap.md,
          vertical: Gap.md,
        ),
        // `IntrinsicHeight` sizes the row to what the cards need on their
        // own, which is exactly wrong when there is height on offer and
        // nothing else asking for it: without it, a card in a `Row` this
        // tall stretches to fill whatever its `Expanded` parent gives it.
        child: expand ? row : IntrinsicHeight(child: row),
      );
    }

    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < seats.length; i++) ...[
          if (i > 0) const VerticalDivider(width: 1),
          Expanded(child: _SeatColumn(seat: seats[i])),
        ],
      ],
    );

    return Padding(
      padding: const EdgeInsets.only(top: Gap.sm, bottom: Gap.lg),
      child: expand ? row : IntrinsicHeight(child: row),
    );
  }
}

/// The seat's figure, filled out to whatever box it is given.
class _Figure extends StatelessWidget {
  const _Figure({required this.seat, required this.alignment});

  final SeatView seat;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final colour = seat.lit ? Palette.chalk : Palette.chalkDim;
    final count = seat.count;
    final label = seat.label ?? '';

    // `Expanded` + `SizedBox.expand` rather than `Spacer` + a size-to-content
    // number: given real height (the card stretched to fill an otherwise-empty
    // screen), this is what lets the digits grow to fill it instead of sitting
    // at their normal size with blank space beneath them. `FittedBox` only
    // fills a box it is given *tight* constraints for - `Expanded` alone only
    // makes the height tight, so `expand` forces the width tight too, or the
    // box (and the number in it) stays exactly its own natural size.
    return Expanded(
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.contain,
          alignment: alignment,
          child: count != null
              ? AnimatedFigure(
                  value: count,
                  style: Type.score.copyWith(color: colour),
                )
              : AnimatedSwitcher(
                  duration: Motion.scale(Motion.base),
                  switchInCurve: Motion.enter,
                  switchOutCurve: Motion.exit,
                  child: Text(
                    label,
                    key: ValueKey(label),
                    // A word like BULLSEYE at score size would dwarf the
                    // numerals it sits beside before the box scales it.
                    style:
                        (_word.hasMatch(label) ? Type.scoreSmall : Type.score)
                            .copyWith(color: colour),
                  ),
                ),
        ),
      ),
    );
  }

  static final RegExp _word = RegExp('[A-Za-z]');
}

/// A seat's score as its own card, for a device far enough away to read as a
/// piece of furniture rather than a phone: real borders instead of a hairline,
/// room for the tally to sit beside the name rather than stacked under the
/// score.
///
/// Carries the same fields and the same "only the thrower is lit" rule as
/// [_SeatColumn] - this is that idea with more room to say it in, not a
/// different one.
class _HeroSeatCard extends StatelessWidget {
  const _HeroSeatCard({required this.seat});

  final SeatView seat;

  @override
  Widget build(BuildContext context) {
    final lit = seat.lit;
    final caption = seat.heroCaption ?? seat.caption;

    return AnimatedContainer(
      duration: Motion.scale(Motion.base),
      curve: Motion.enter,
      padding: const EdgeInsets.all(Gap.lg),
      decoration: BoxDecoration(
        color: lit ? Palette.raised : Palette.sunk,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: lit ? seat.accent : Palette.edge, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: Motion.scale(Motion.base),
                  curve: Motion.enter,
                  style: Type.title.copyWith(
                    color: lit ? Palette.chalk : Palette.chalkDim,
                  ),
                  child: Text(
                    seat.name.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (seat.tally case final tally?)
                Text(
                  tally,
                  // Chalk, not the accent: a tally is a standing, not this
                  // leg's live state, and `Palette.live` is spent only on
                  // state, per its own doc.
                  style: Type.eyebrow.copyWith(
                    color: seat.tallyLit ? Palette.chalk : Palette.chalkDim,
                  ),
                ),
            ],
          ),
          _Figure(seat: seat, alignment: Alignment.centerLeft),
          if (seat.progress case final progress?) ...[
            const SizedBox(height: Gap.sm),
            ProgressRail(
              value: progress,
              ticks: seat.ticks,
              colour: lit ? seat.accent : Palette.chalkDim,
            ),
          ],
          if (caption != null) ...[
            const SizedBox(height: Gap.xs),
            Text(caption, style: Type.label.copyWith(color: Palette.chalkDim)),
          ],
        ],
      ),
    );
  }
}

class _SeatColumn extends StatelessWidget {
  const _SeatColumn({required this.seat});

  final SeatView seat;

  @override
  Widget build(BuildContext context) {
    final lit = seat.lit;

    return Column(
      children: [
        // The rule above the name is the only thing marking the throw. It is
        // three pixels tall and it is enough, because nothing else on the
        // screen is this pale.
        AnimatedContainer(
          duration: Motion.scale(Motion.base),
          curve: Motion.enter,
          height: 3,
          margin: const EdgeInsets.symmetric(horizontal: Gap.lg),
          color: lit ? seat.accent : Colors.transparent,
        ),
        const SizedBox(height: Gap.md),
        AnimatedDefaultTextStyle(
          duration: Motion.scale(Motion.base),
          curve: Motion.enter,
          style: Type.eyebrow.copyWith(
            color: lit ? seat.accent : Palette.chalkDim,
          ),
          child: Text(
            seat.name.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: Gap.sm),
        _Figure(seat: seat, alignment: Alignment.center),
        if (seat.progress case final progress?) ...[
          const SizedBox(height: Gap.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Gap.lg),
            child: ProgressRail(
              value: progress,
              ticks: seat.ticks,
              colour: lit ? seat.accent : Palette.chalkDim,
            ),
          ),
        ],
        if (seat.caption case final caption?) ...[
          const SizedBox(height: Gap.xs),
          Text(caption, style: Type.label.copyWith(color: Palette.chalkDim)),
        ],
        // The tally sits under the caption rather than beside the name: it
        // is what the match hangs on, but it is not what you look up to check
        // mid-turn, so it goes last.
        if (seat.tally case final tally?) ...[
          const SizedBox(height: Gap.sm),
          Text(
            tally,
            textAlign: TextAlign.center,
            style: Type.eyebrow.copyWith(
              color: seat.tallyLit ? Palette.chalk : Palette.chalkDim,
            ),
          ),
        ],
      ],
    );
  }
}

/// How far a seat has come, as a thin rail under its figure.
///
/// For the games whose figure does not say it on its own: a stop number is
/// not a distance travelled, and a points total means nothing without the
/// target beside it. With [ticks] it is drawn as that many separate steps -
/// the track of an Around the Clock - and falls back to one fill once the
/// steps would be too narrow to tell apart.
class ProgressRail extends StatelessWidget {
  const ProgressRail({
    super.key,
    required this.value,
    required this.colour,
    this.ticks,
  });

  /// 0 to 1.
  final double value;
  final Color colour;
  final int? ticks;

  static const double _height = 4;

  /// Narrower than this and the gaps between steps eat the steps.
  static const double _minTick = 6;

  @override
  Widget build(BuildContext context) {
    final fraction = value.clamp(0.0, 1.0);
    final ticks = this.ticks;

    return SizedBox(
      height: _height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (ticks != null && constraints.maxWidth / ticks >= _minTick) {
            final filled = (fraction * ticks).round();
            return Row(
              children: [
                for (var i = 0; i < ticks; i++) ...[
                  if (i > 0) const SizedBox(width: 2),
                  Expanded(
                    child: AnimatedContainer(
                      duration: Motion.scale(Motion.base),
                      curve: Motion.enter,
                      decoration: BoxDecoration(
                        color: i < filled ? colour : Palette.edge,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                ],
              ],
            );
          }

          return ClipRRect(
            borderRadius: BorderRadius.circular(_height / 2),
            child: ColoredBox(
              color: Palette.edge,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: AnimatedFractionallySizedBox(
                  duration: Motion.scale(Motion.base),
                  curve: Motion.enter,
                  widthFactor: fraction,
                  heightFactor: 1,
                  child: ColoredBox(color: colour),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
