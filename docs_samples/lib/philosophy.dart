import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:herald/herald.dart';
import 'package:herald_appsflyer/herald_appsflyer.dart';

// --8<-- [start:event]
// The event: what happened, in your app's words. It knows nothing about AppsFlyer.
final class const TicketPurchased(final String fare, final double price, final String currency)
    extends Event {
  @override
  String get name => 'ticket_purchased';

  @override
  Map<String, AnalyticsValue> get parameters => {'fare': .string(fare)};
}
// --8<-- [end:event]

// --8<-- [start:mapping]
// The mapping: the only code that knows how AppsFlyer wants a purchase.
extension TicketPurchasedAppsFlyer on TicketPurchased {
  AppsFlyerPurchaseEvent toAppsFlyerPurchaseEvent() => AppsFlyerPurchaseEvent(
    name: name,
    revenue: price, // sent as af_revenue
    currency: currency,
    contentId: fare,
    parameters: parameters,
  );
}

// The factory: sends the purchase to AppsFlyer, using the mapping above.
final class const TicketsAppsFlyerEventTrackerFactory(final AppsFlyerSdk appsFlyer)
    implements AppsFlyerEventTrackerFactory {
  @override
  Resolution<AppsFlyerEventTracker> create(Event event) => switch (event) {
    TicketPurchased() => .claimed([
      PurchaseAppsFlyerEventTracker(event.toAppsFlyerPurchaseEvent(), appsFlyer),
    ]),
    _ => .declined(), // not mine
  };
}
// --8<-- [end:mapping]
