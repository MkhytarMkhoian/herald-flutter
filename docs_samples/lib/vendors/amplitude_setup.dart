import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/autocapture/autocapture.dart';
import 'package:amplitude_flutter/configuration.dart';
import 'package:herald/herald.dart';
import 'package:herald_amplitude/herald_amplitude.dart';

HeraldProvider amplitudeProvider(String apiKey) {
  // --8<-- [start:provider]
  final amplitude = Amplitude(
    Configuration(
      apiKey: apiKey,
      optOut: true, // silent until consent
      autocapture: const AutocaptureOptions(screenViews: false), // Herald sends screen views
    ),
  );

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

  final provider = HeraldProvider(
    name: 'amplitude',
    events: tracker,
    properties: tracker,
    identity: service,
    lifecycle: service,
    consent: service,
  );
  // --8<-- [end:provider]
  return provider;
}
