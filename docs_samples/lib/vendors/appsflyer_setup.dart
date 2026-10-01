import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:herald/herald.dart';
import 'package:herald_appsflyer/herald_appsflyer.dart';

Future<void> initAppsFlyer() async {
  // --8<-- [start:init]
  final appsFlyer = AppsFlyerSdk.instance;
  await appsFlyer.init(devKey: 'YOUR_DEV_KEY', appId: 'YOUR_APPLE_APP_ID');
  // AppsFlyer 7 sends a session only on start(), once per foreground. While Herald keeps the SDK
  // stopped, before consent, it sends nothing.
  await appsFlyer.registerSessionReadyListener(() async {
    await appsFlyer.start();
  });
  // --8<-- [end:init]
}

HeraldProvider appsFlyerProvider(List<AppsFlyerEventTrackerFactory> featureFactories) {
  // --8<-- [start:provider]
  final appsFlyer = AppsFlyerSdk.instance; // initialised at start-up

  final tracker = AppsFlyerAnalyticsTrackerService(
    // Your conversions and revenue. Nothing at the end, so other events aren't sent.
    eventTrackerFactory: CompositeAppsFlyerEventTrackerFactory(featureFactories),
  );
  final service = AppsFlyerAnalyticsService(appsFlyer);

  final provider = HeraldProvider(
    name: 'appsflyer',
    events: tracker, // no properties: AppsFlyer keeps no user attributes
    identity: service,
    lifecycle: service,
    consent: service,
  );
  // --8<-- [end:provider]
  return provider;
}
