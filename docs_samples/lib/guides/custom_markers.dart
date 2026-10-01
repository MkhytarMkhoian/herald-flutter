import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:herald/herald.dart';
import 'package:herald_firebase/herald_firebase.dart';

// --8<-- [start:marker]
/// Money returned to a customer. Your app's idea, so your app's marker.
abstract interface class RefundEvent implements Event {
  double get amount;

  String get currency;

  String get transactionId;
}

final class const TicketRefunded({
  @override required final double amount,
  @override required final String currency,
  @override required final String transactionId,
}) extends Event implements RefundEvent {
  @override
  String get name => 'ticket_refunded';
}
// --8<-- [end:marker]

// --8<-- [start:marker-tracker]
final class const RefundFirebaseEventTracker(
  final RefundEvent event,
  final FirebaseAnalytics firebaseAnalytics,
) implements FirebaseEventTracker {
  @override
  Future<void> track() => firebaseAnalytics.logEvent(
    name: 'refund', // GA4's reserved refund
    parameters: {
      ...event.parameters.toFirebaseParameters(),
      'transaction_id': event.transactionId,
      'value': event.amount,
      'currency': event.currency,
    },
  );
}

final class const RefundFirebaseEventTrackerFactory(final FirebaseAnalytics firebaseAnalytics)
    implements FirebaseEventTrackerFactory {
  @override
  Resolution<FirebaseEventTracker> create(Event event) => switch (event) {
    RefundEvent() => .claimed([RefundFirebaseEventTracker(event, firebaseAnalytics)]),
    _ => .declined(),
  };
}
// --8<-- [end:marker-tracker]

// --8<-- [start:structured]
/// Names an event by where it happened, so two features can't pick the same name.
abstract class StructuredEvent extends Event {
  const StructuredEvent();

  String get screen;

  String get component;

  String get action;

  @override
  String get name => [screen, component, action].where((part) => part.isNotEmpty).join('_');
}

final class const CheckoutPayButtonTapped() extends StructuredEvent {
  @override
  String get screen => 'checkout';

  @override
  String get component => 'pay_button';

  @override
  String get action => 'tap';
}
// --8<-- [end:structured]

// --8<-- [start:structured-tracker]
final class const StructuredFirebaseEventTracker(
  final StructuredEvent event,
  final FirebaseAnalytics firebaseAnalytics,
) implements FirebaseEventTracker {
  @override
  Future<void> track() => firebaseAnalytics.logEvent(
    name: event.component,
    parameters: {
      ...event.parameters.toFirebaseParameters(),
      'screen': event.screen, // your call: spread the structure across
      'action': event.action, // parameters, or let the name carry it alone
    },
  );
}
// --8<-- [end:structured-tracker]
