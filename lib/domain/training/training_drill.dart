/// [TrainingDrill], the practice loops a solo training session can run.
///
/// {@category Game modes}
library;

/// Which practice loop a training session runs.
///
/// A training session is never persisted - see `TrainingController` in
/// `lib/app/training_controller.dart` - so unlike `GameMode` this never
/// touches the database and has no reason to grow a stats calculator of its
/// own. Adding a drill means adding a value here, a `TrainingPlan` and a
/// `TrainingSession` for it, and a branch wherever `TrainingController` and
/// the training screens switch on those.
enum TrainingDrill {
  /// Just throw. No target and no win condition - only what was hit and
  /// running session numbers.
  freePractice,

  /// A random finish each round, one visit to take it out; the range adapts
  /// to how often you do.
  checkoutChallenge,

  /// Finish 121 in nine darts; every finish raises the target by one, every
  /// failure lowers it.
  ladder121,

  /// Doubles under pressure: start on 27, one visit at each double, and a
  /// blank visit costs you that double.
  bobs27,

  /// The app picks your weakest targets, in random order, and shows which
  /// way the misses go.
  weakSpot,
}
