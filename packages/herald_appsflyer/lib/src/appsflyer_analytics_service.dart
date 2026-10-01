import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:herald/herald.dart';

/// AppsFlyer's lifecycle, identity and consent, over an [AppsFlyerSdk] the app has set up with
/// `init` and its listeners.
///
/// **AppsFlyer starts on consent, not on [start].** [start] stops AppsFlyer, so a fresh install
/// sends nothing, not even the install, until [setEnabled] turns it on. AppsFlyer forgets both the
/// stop and the user id between launches, so on every cold start call [identify], then
/// [setEnabled] with the stored answer.
///
/// Granular consent, such as `setConsentData` or `anonymizeUser`, is set on your [AppsFlyerSdk].
final class const AppsFlyerAnalyticsService(final AppsFlyerSdk appsFlyer)
    implements AnalyticsLifecycleService, IdentifiableUserService, ConsentService {
  @override
  Future<void> start() => appsFlyer.stop(true);

  /// AppsFlyer has no flush API.
  @override
  Future<void> flush() async {}

  @override
  Future<void> setEnabled(bool enabled) async {
    await appsFlyer.stop(!enabled);
    if (enabled) await appsFlyer.start();
  }

  @override
  Future<void> identify(Identity identity) => appsFlyer.setCustomerUserId(identity.userId);

  /// Does nothing: AppsFlyer's Flutter plugin can't clear the user id. AppsFlyer forgets it at the
  /// next cold start; until then, events still carry it.
  @override
  Future<void> reset() async {}
}
