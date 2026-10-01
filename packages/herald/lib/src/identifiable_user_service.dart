import 'identity.dart';

abstract interface class IdentifiableUserService {
  Future<void> identify(Identity identity);

  /// Forgets the current user. Call it on sign-out.
  Future<void> reset();
}
