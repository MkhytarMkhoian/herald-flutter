/// The current user.
///
/// [toString] hides [userId], so an identity printed by accident doesn't leak it into logs or crash
/// reports. Use [userId] when you really need it.
final class const Identity(final String userId) {
  @override
  bool operator ==(Object other) => other is Identity && other.userId == userId;

  @override
  int get hashCode => userId.hashCode;

  @override
  String toString() => 'Identity(…)';
}
