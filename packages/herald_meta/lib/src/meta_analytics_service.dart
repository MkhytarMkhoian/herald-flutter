import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:herald/herald.dart';

/// Meta's start, sign-in and consent, over the app's [FacebookAppEvents].
///
/// [setEnabled] turns Meta's own collection on or off: the events it logs by itself, such as
/// installs, and the advertiser id. It doesn't stop the events your app logs. Turn Meta's automatic
/// collection off in both native projects, as its plugin's README shows, so a fresh install
/// collects nothing by itself. Then call [setEnabled] with the stored answer on every launch.
///
/// The plugin starts Meta's SDK when the app launches. Don't set `FacebookAutoInitEnabled` to
/// `false` in iOS's `Info.plist`: the plugin then refuses every call, and each refusal reaches
/// Herald's error reporter.
final class const MetaAnalyticsService(final FacebookAppEvents appEvents)
    implements AnalyticsLifecycleService, IdentifiableUserService, ConsentService {
  /// The plugin starts Meta's SDK itself.
  @override
  Future<void> start() async {}

  @override
  Future<void> flush() => appEvents.flush();

  @override
  Future<void> setEnabled(bool enabled) async {
    // Finishes starting the SDK on Android, where AutoInitEnabled is false. Repeating it is harmless.
    if (enabled) await appEvents.initializeSdk();
    await appEvents.setAutoLogAppEventsEnabled(enabled);
    await appEvents.setAdvertiserIdCollectionEnabled(enabled);
  }

  @override
  Future<void> identify(Identity identity) => appEvents.setUserID(identity.userId);

  @override
  Future<void> reset() => appEvents.clearUserID();
}
