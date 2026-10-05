import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/autocapture/autocapture.dart';
import 'package:amplitude_flutter/configuration.dart';
import 'package:flutter/widgets.dart';
import 'package:herald/herald.dart';
import 'package:herald_amplitude/herald_amplitude.dart';

final class const CheckoutStarted(final String plan, final int seats) extends Event {
  @override
  String get name => 'checkout_started';

  @override
  Map<String, AnalyticsValue> get parameters => {'plan': .string(plan), 'seats': .int(seats)};
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final amplitude = Amplitude(
    Configuration(
      apiKey: 'YOUR_API_KEY',
      optOut: true, // silent until consent
      autocapture: const AutocaptureOptions(screenViews: false), // Herald sends screen views
    ),
  );
  final herald = Herald(providers: [amplitudeProvider(amplitude)]);

  await herald.start();
  await herald.setEnabled(true); // the user agreed
  await herald.track(const CheckoutStarted('pro', 3));
}
