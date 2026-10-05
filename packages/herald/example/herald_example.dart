import 'package:herald/herald.dart';

final class const CheckoutStarted(final String plan, final int seats) extends Event {
  @override
  String get name => 'checkout_started';

  @override
  Map<String, AnalyticsValue> get parameters => {'plan': .string(plan), 'seats': .int(seats)};
}

/// A vendor of your own. The vendor packages, such as herald_firebase, provide real ones.
final class PrintEventTracker implements EventTrackerService {
  @override
  Future<void> track(Event event) async => print('${event.name} ${event.parameters}');
}

Future<void> main() async {
  final herald = Herald(
    providers: [HeraldProvider(name: 'print', events: PrintEventTracker())],
    errorReporter: (failure) => print('$failure'),
  );

  await herald.track(const CheckoutStarted('pro', 3));
}
