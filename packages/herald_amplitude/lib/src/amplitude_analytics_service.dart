import 'package:amplitude_flutter/amplitude.dart';
import 'package:herald/herald.dart';

/// Amplitude's lifecycle, identity and consent, over an [Amplitude] the app has created.
///
/// Amplitude collects from the moment it's created. Create it with `Configuration(optOut: true)` so
/// nothing is sent before the user answers. Amplitude forgets the opt-out between launches, so call
/// [setEnabled] with the stored answer after [start] on every launch.
final class const AmplitudeAnalyticsService(final Amplitude amplitude)
    implements AnalyticsLifecycleService, IdentifiableUserService, ConsentService {
  /// Amplitude starts itself when it's created; this waits for that. If it failed, this throws,
  /// and Herald reports it.
  @override
  Future<void> start() async {
    final built = await amplitude.isBuilt;
    if (!built) throw StateError('Amplitude failed to build.');
  }

  @override
  Future<void> flush() => amplitude.flush();

  @override
  Future<void> setEnabled(bool enabled) => amplitude.setOptOut(!enabled);

  @override
  Future<void> identify(Identity identity) => amplitude.setUserId(identity.userId);

  /// Clears the user id and also changes the device id, so the next user isn't linked to the last
  /// one.
  @override
  Future<void> reset() => amplitude.reset();
}
