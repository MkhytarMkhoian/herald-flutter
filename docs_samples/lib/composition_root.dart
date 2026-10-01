import 'package:adjust_sdk/adjust_config.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:herald/herald.dart';
import 'package:herald_adjust/herald_adjust.dart';
import 'package:herald_amplitude/herald_amplitude.dart';
import 'package:herald_firebase/herald_firebase.dart';
import 'package:herald_mixpanel/herald_mixpanel.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

import 'guides/consent.dart';

// --8<-- [start:firebase-provider]
HeraldProvider firebaseProvider(FirebaseAnalytics firebaseAnalytics) {
  final tracker = FirebaseAnalyticsTrackerService(
    eventTrackerFactory: CompositeFirebaseEventTrackerFactory([
      ScreenViewFirebaseEventTrackerFactory(firebaseAnalytics), // GA4's reserved screen_view
      GenericFirebaseEventTrackerFactory(firebaseAnalytics), // everything else, as-is
    ]),
    propertySetterFactory: CompositeFirebasePropertySetterFactory([
      GenericFirebasePropertySetterFactory(firebaseAnalytics),
    ]),
  );
  final service = FirebaseAnalyticsService(firebaseAnalytics);
  return HeraldProvider(
    name: 'firebase',
    events: tracker,
    properties: tracker,
    identity: service,
    lifecycle: service,
    consent: service,
  );
}
// --8<-- [end:firebase-provider]

HeraldProvider mixpanelProvider(Mixpanel mixpanel) {
  final tracker = MixpanelAnalyticsTrackerService(
    eventTrackerFactory: CompositeMixpanelEventTrackerFactory([
      ScreenViewMixpanelEventTrackerFactory(mixpanel),
      GenericMixpanelEventTrackerFactory(mixpanel),
    ]),
    propertySetterFactory: CompositeMixpanelPropertySetterFactory([
      UserPropertyMixpanelPropertySetterFactory(mixpanel), // before the generic one
      GenericMixpanelPropertySetterFactory(mixpanel),
    ]),
  );
  final service = MixpanelAnalyticsService(mixpanel);
  return HeraldProvider(
    name: 'mixpanel',
    events: tracker,
    properties: tracker,
    identity: service,
    lifecycle: service,
    consent: service,
  );
}

HeraldProvider adjustProvider(AdjustConfig config, Map<String, String> tokens) {
  final tracker = AdjustAnalyticsTrackerService(
    eventTrackerFactory: CompositeAdjustEventTrackerFactory([
      TokenAdjustEventTrackerFactory(tokens), // only events with a dashboard token
    ]),
    propertySetterFactory: CompositeAdjustPropertySetterFactory([
      const GenericAdjustPropertySetterFactory(),
    ]),
  );
  final service = AdjustAnalyticsService(config);
  return HeraldProvider(
    name: 'adjust',
    events: tracker,
    properties: tracker,
    identity: service,
    lifecycle: service,
    consent: service,
  );
}

HeraldProvider amplitudeProvider(Amplitude amplitude) {
  final tracker = AmplitudeAnalyticsTrackerService(
    eventTrackerFactory: CompositeAmplitudeEventTrackerFactory([
      ScreenViewAmplitudeEventTrackerFactory(amplitude),
      GenericAmplitudeEventTrackerFactory(amplitude),
    ]),
    propertySetterFactory: CompositeAmplitudePropertySetterFactory([
      GenericAmplitudePropertySetterFactory(amplitude),
    ]),
  );
  final service = AmplitudeAnalyticsService(amplitude);
  return HeraldProvider(
    name: 'amplitude',
    events: tracker,
    properties: tracker,
    identity: service,
    lifecycle: service,
    consent: service,
  );
}

Herald buildHerald({
  required FirebaseAnalytics firebaseAnalytics,
  required Mixpanel mixpanel,
  required AdjustConfig adjustConfig,
  required Map<String, String> adjustTokens,
}) {
  // --8<-- [start:herald]
  final herald = Herald(
    providers: [
      firebaseProvider(firebaseAnalytics),
      mixpanelProvider(mixpanel),
      adjustProvider(adjustConfig, adjustTokens),
    ],
    errorReporter: (failure) => debugPrint('analytics: $failure\n${failure.stackTrace}'),
  );
  // --8<-- [end:herald]
  return herald;
}

// --8<-- [start:start-from-main]
Future<void> startAnalytics(
  Herald herald,
  AnalyticsConsentRepository consentRepository, // however you store the answer
) async {
  await herald.start(); // some vendors start quiet here
  await herald.setEnabled(await consentRepository.isEnabled()); // so re-apply the stored answer
}
// --8<-- [end:start-from-main]
