/// Which practice loop a training session runs.
///
/// A training session is never persisted - see `TrainingController` in
/// `lib/app/training_controller.dart` - so unlike `GameMode` this never
/// touches the database and has no reason to grow a stats calculator of its
/// own. Adding a drill means adding a value here and a branch wherever
/// `TrainingController` and the training screens switch on it.
enum TrainingDrill {
  /// Just throw. No target and no win condition - only what was hit and
  /// running session numbers.
  freePractice,

  /// Practice finishing a chosen start score under double-out, the same
  /// rules as an x01 leg, with the checkout suggestion visible throughout.
  checkoutPractice,
}
