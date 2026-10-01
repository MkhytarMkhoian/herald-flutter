import 'package:herald/herald.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

/// Mixpanel's lifecycle, identity and consent, over a [Mixpanel] the app has created.
///
/// [start] doesn't opt out: `optOutTracking` deletes unsent events and the stored user, so doing it
/// every launch would wipe a user who agreed. Create Mixpanel with `optOutTrackingDefault: true`
/// instead; [setEnabled] opts in when the user agrees, and Mixpanel remembers it.
///
/// To keep the user id away from Mixpanel, register the provider without `identity`.
final class const MixpanelAnalyticsService(final Mixpanel mixpanel)
    implements AnalyticsLifecycleService, IdentifiableUserService, ConsentService {
  /// Mixpanel is ready once `Mixpanel.init` has returned, so there is nothing to do.
  @override
  Future<void> start() async {}

  @override
  Future<void> flush() => mixpanel.flush();

  /// Opting out flushes first, so events sent before it still arrive.
  @override
  Future<void> setEnabled(bool enabled) async {
    if (enabled) {
      mixpanel.optInTracking();
    } else {
      await mixpanel.flush();
      mixpanel.optOutTracking();
    }
  }

  @override
  Future<void> identify(Identity identity) => mixpanel.identify(identity.userId);

  @override
  Future<void> reset() => mixpanel.reset();
}
