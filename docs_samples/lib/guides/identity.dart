import 'package:herald/herald.dart';

abstract interface class Session {
  String? get userId;
}

// --8<-- [start:session]
class AnalyticsIdentity(final IdentifiableUserService identity) {
  Future<void> onSignedIn(String userId) => identity.identify(Identity(userId));

  Future<void> onSignedOut() => identity.reset();

  /// Call it at every app start: some vendors forget the user between launches.
  Future<void> restore(Session session) async {
    if (session.userId case final userId?) await identity.identify(Identity(userId));
  }
}
// --8<-- [end:session]
