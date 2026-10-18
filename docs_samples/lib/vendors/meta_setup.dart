import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:herald/herald.dart';
import 'package:herald_meta/herald_meta.dart';

import '../concepts/factory_chain.dart';
import '../concepts/vocabulary.dart';

HeraldProvider metaProvider(List<MetaEventTrackerFactory> featureFactories) {
  // --8<-- [start:provider]
  final appEvents = FacebookAppEvents();
  final service = MetaAnalyticsService(appEvents);

  final tracker = MetaAnalyticsTrackerService(
    // Your conversions. Nothing at the end, so other events aren't sent.
    eventTrackerFactory: CompositeMetaEventTrackerFactory(featureFactories),
  );

  final provider = HeraldProvider(
    name: 'meta',
    events: tracker, // no properties: Meta keeps no user attributes
    identity: service,
    lifecycle: service,
    consent: service,
  );
  // --8<-- [end:provider]
  return provider;
}

// --8<-- [start:conversions]
final class const CheckoutMetaEventTrackerFactory(final FacebookAppEvents appEvents)
    implements MetaEventTrackerFactory {
  @override
  Resolution<MetaEventTracker> create(Event event) => switch (event) {
    // A purchase: Meta's fb_mobile_purchase, which it counts as revenue.
    CheckoutCompleted() => .claimed([
      PurchaseMetaEventTracker(
        MetaPurchaseEvent(
          name: event.name,
          amount: event.value,
          currency: event.currency,
          parameters: event.parameters,
        ),
        appEvents,
      ),
    ]),
    // Any other conversion, under one of Meta's standard names.
    PlanSelected() => .claimed([_InitiatedCheckoutTracker(event, appEvents)]),
    _ => .declined(),
  };
}

final class const _InitiatedCheckoutTracker(final Event event, final FacebookAppEvents appEvents)
    implements MetaEventTracker {
  @override
  Future<void> track() => appEvents.logEvent(
    name: FacebookAppEvents.eventNameInitiatedCheckout,
    parameters: event.parameters.toMetaParameters(),
  );
}
// --8<-- [end:conversions]
