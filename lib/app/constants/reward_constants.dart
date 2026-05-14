/// Loyalty / gamification point values (Firestore-backed on `users.rewardPoints`).
abstract final class RewardConstants {
  /// Points granted when a complaint is accepted as a valid issue (`pending`).
  static const int pointsPerValidComplaint = 10;

  /// Points when AI marks the submission as not a valid issue (`not_issue`).
  /// Kept at zero so the flow does not incentivize low-quality reports.
  static const int pointsPerNotIssueComplaint = 0;
}
