import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/widgets.dart';
import 'package:herald/herald.dart';
import 'package:herald_log/herald_log.dart';

import 'composition_root.dart';

// --8<-- [start:event]
final class const CheckoutStarted(final String plan, final int seats) extends Event {
  @override
  String get name => 'checkout_started';

  @override
  Map<String, AnalyticsValue> get parameters => {'plan': .string(plan), 'seats': .int(seats)};

  // Equality lets a test compare a tracked event with the one it expects.
  @override
  bool operator ==(Object other) =>
      other is CheckoutStarted && other.plan == plan && other.seats == seats;

  @override
  int get hashCode => Object.hash(plan, seats);
}
// --8<-- [end:event]

Herald createHerald() {
  // --8<-- [start:herald]
  // Where the log lines go: Flutter's debugPrint fits as-is.
  final AnalyticsLogger logger = debugPrint;

  // Handles events and user properties, using Herald's ready-made factories.
  final logTracker = LogAnalyticsTrackerService(
    eventTrackerFactory: CompositeLogEventTrackerFactory([
      ScreenViewLogEventTrackerFactory(logger), // screen views
      GenericLogEventTrackerFactory(logger), // every other event
    ]),
    propertySetterFactory: CompositeLogPropertySetterFactory([
      GenericLogPropertySetterFactory(logger),
    ]),
  );
  // Handles the rest: start-up, sign-in and sign-out, consent.
  final logService = LogAnalyticsService(logger);

  final herald = Herald(
    providers: [
      HeraldProvider(
        name: 'log',
        events: logTracker,
        properties: logTracker,
        identity: logService,
        lifecycle: logService,
        consent: logService,
      ),
    ],
  );
  // --8<-- [end:herald]
  return herald;
}

Herald quickStartWithFirebase(FirebaseAnalytics firebaseAnalytics) {
  final AnalyticsLogger logger = debugPrint;
  final logTracker = LogAnalyticsTrackerService(
    eventTrackerFactory: CompositeLogEventTrackerFactory([GenericLogEventTrackerFactory(logger)]),
    propertySetterFactory: CompositeLogPropertySetterFactory([
      GenericLogPropertySetterFactory(logger),
    ]),
  );
  final logService = LogAnalyticsService(logger);
  // --8<-- [start:add-firebase]
  final herald = Herald(
    providers: [
      HeraldProvider(
        name: 'log',
        events: logTracker,
        properties: logTracker,
        identity: logService,
        lifecycle: logService,
        consent: logService,
      ),
      firebaseProvider(firebaseAnalytics), // the new line
    ],
  );
  // --8<-- [end:add-firebase]
  return herald;
}

// --8<-- [start:track]
class CheckoutViewModel(final EventTrackerService analytics) {
  Future<void> onCheckout(String plan, int seats) => analytics.track(CheckoutStarted(plan, seats));
}
// --8<-- [end:track]

// --8<-- [start:app]
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final herald = createHerald();
  await herald.start();
  runApp(MyApp(analytics: herald));
}
// --8<-- [end:app]

class const MyApp({required final EventTrackerService analytics, super.key})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const SizedBox();
}
