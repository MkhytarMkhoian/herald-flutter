import 'package:herald/herald.dart';

/// However your app stores the user's answer.
abstract interface class AnalyticsConsentRepository {
  Future<bool> isEnabled();

  Future<void> setEnabled(bool enabled);
}

// --8<-- [start:record]
class PrivacySettingsController(
  final AnalyticsConsentRepository consentRepository,
  final ConsentService consent,
) {
  Future<void> onAnalyticsConsentChanged(bool enabled) async {
    await consentRepository.setEnabled(enabled); // save the answer first
    await consent.setEnabled(enabled); // then apply it to every vendor
  }
}
// --8<-- [end:record]

Future<void> startAnalytics(
  AnalyticsLifecycleService analytics,
  ConsentService consent,
  AnalyticsConsentRepository consentRepository,
) async {
  // --8<-- [start:restore]
  await analytics.start(); // some vendors start quiet here
  await consent.setEnabled(await consentRepository.isEnabled()); // so re-apply it, every launch
  // --8<-- [end:restore]
}
