import 'package:adjust_sdk/adjust_config.dart';
import 'package:herald/herald.dart';
import 'package:herald_adjust/herald_adjust.dart';

HeraldProvider adjustProvider(List<AdjustEventTrackerFactory> featureFactories) {
  // --8<-- [start:provider]
  final config = AdjustConfig('YOUR_APP_TOKEN', AdjustEnvironment.production);

  final tracker = AdjustAnalyticsTrackerService(
    eventTrackerFactory: CompositeAdjustEventTrackerFactory([
      ...featureFactories, // revenue and custom mappings first
      TokenAdjustEventTrackerFactory({'checkout_completed': 'abc123'}),
    ]), // nothing at the end: only tokened events are sent
    propertySetterFactory: CompositeAdjustPropertySetterFactory([
      const GenericAdjustPropertySetterFactory(),
    ]),
  );
  // Initialises Adjust itself, silent until consent. Don't call Adjust.initSdk yourself.
  final service = AdjustAnalyticsService(config);

  final provider = HeraldProvider(
    name: 'adjust',
    events: tracker,
    properties: tracker,
    identity: service,
    lifecycle: service,
    consent: service,
  );
  // --8<-- [end:provider]
  return provider;
}
