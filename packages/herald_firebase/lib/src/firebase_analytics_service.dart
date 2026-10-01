import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:herald/herald.dart';

/// Firebase's lifecycle, identity and consent, over a [FirebaseAnalytics] the app owns.
///
/// **Before consent arrives, Firebase collects.** [start] does not opt out, because Firebase's
/// off-by-default switch is read when the SDK starts, before any Dart code runs. Set it in the
/// native projects if a fresh install must collect nothing until the user has answered:
///
/// ```xml
/// <!-- android/app/src/main/AndroidManifest.xml, inside <application> -->
/// <meta-data android:name="firebase_analytics_collection_enabled" android:value="false" />
/// ```
///
/// ```xml
/// <!-- ios/Runner/Info.plist -->
/// <key>FIREBASE_ANALYTICS_COLLECTION_ENABLED</key>
/// <false/>
/// ```
///
/// [setEnabled] then flips collection on, and Firebase persists the choice across launches.
///
/// To keep the user id away from Firebase, register the provider without `identity`.
final class const FirebaseAnalyticsService(final FirebaseAnalytics analytics)
    implements AnalyticsLifecycleService, IdentifiableUserService, ConsentService {
  /// Firebase Analytics starts itself once `Firebase.initializeApp` has run, so there is nothing
  /// to do.
  @override
  Future<void> start() async {}

  /// Firebase has no flush API.
  @override
  Future<void> flush() async {}

  @override
  Future<void> setEnabled(bool enabled) => analytics.setAnalyticsCollectionEnabled(enabled);

  @override
  Future<void> identify(Identity identity) => analytics.setUserId(id: identity.userId);

  @override
  Future<void> reset() => analytics.setUserId();
}
