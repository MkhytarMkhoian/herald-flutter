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

HeraldProvider gatedMetaProvider(List<MetaEventTrackerFactory> featureFactories) {
  final appEvents = FacebookAppEvents();
  final tracker = MetaAnalyticsTrackerService(
    eventTrackerFactory: CompositeMetaEventTrackerFactory(featureFactories),
  );
  final service = MetaAnalyticsService(appEvents);
  // --8<-- [start:gate]
  final gate = ConsentGate(tracker, service);

  final provider = HeraldProvider(
    name: 'meta',
    events: gate, // dropped while consent is off
    identity: service,
    lifecycle: service,
    consent: gate, // keeps the answer, then turns Meta's own switch
  );
  // --8<-- [end:gate]
  return provider;
}

// --8<-- [start:gate-class]
/// Meta's own switch doesn't stop the events your app logs, so this drops them while consent is
/// off.
final class ConsentGate(final EventTrackerService _events, final ConsentService _consent)
    implements EventTrackerService, ConsentService {
  bool _enabled = false;

  @override
  Future<void> track(Event event) async {
    if (_enabled) await _events.track(event);
  }

  @override
  Future<void> setEnabled(bool enabled) async {
    _enabled = enabled;
    await _consent.setEnabled(enabled);
  }
}
// --8<-- [end:gate-class]

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
