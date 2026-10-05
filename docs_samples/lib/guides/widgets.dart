import 'package:flutter/material.dart';
import 'package:herald/herald.dart';
import 'package:herald_widgets/herald_widgets.dart';

final class const ProductScreenViewed(final String productId) extends ScreenViewEvent {
  @override
  String get name => 'product';

  @override
  Map<String, AnalyticsValue> get parameters => {'product_id': .string(productId)};
}

final class const CheckoutLeft(final int itemsInCart) extends Event {
  @override
  String get name => 'checkout_left';

  @override
  Map<String, AnalyticsValue> get parameters => {'items_in_cart': .int(itemsInCart)};
}

final class const PromoBannerTapped(final String promoId) extends Event {
  @override
  String get name => 'promo_banner_tapped';

  @override
  Map<String, AnalyticsValue> get parameters => {'promo_id': .string(promoId)};
}

final class const OfferShown(final String offerId) extends Event {
  @override
  String get name => 'offer_shown';

  @override
  Map<String, AnalyticsValue> get parameters => {'offer_id': .string(offerId)};

  // Equal events keep the count across rebuilds.
  @override
  bool operator ==(Object other) => other is OfferShown && other.offerId == offerId;

  @override
  int get hashCode => offerId.hashCode;
}

// --8<-- [start:setup]
final class ShopApp(final Herald herald) extends StatelessWidget {
  // One per Navigator: it tells screens when they are shown or hidden.
  final routes = HeraldRouteObserver();

  @override
  Widget build(BuildContext context) => HeraldScope(
    analytics: herald,
    routes: routes,
    child: MaterialApp(
      navigatorObservers: [routes], // go_router: GoRouter(observers: [routes])
      home: const ProductPage('day_pass'),
    ),
  );
}
// --8<-- [end:setup]

// --8<-- [start:screen-view]
final class const ProductPage(final String productId, {super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => TrackScreenView(
    event: ProductScreenViewed(productId),
    child: Scaffold(appBar: AppBar(title: Text(productId))),
  );
}
// --8<-- [end:screen-view]

final class const CheckoutPage(final int itemsInCart, {super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      // --8<-- [start:on-screen]
      TrackOnScreen(
        event: CheckoutLeft(itemsInCart),
        on: ScreenMoment.hidden, // pushed over, closed, or the app went out of view
        child: const Scaffold(),
      );
  // --8<-- [end:on-screen]
}

final class const PromoBanner(final String promoId, {super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      // --8<-- [start:tap]
      ElevatedButton(
        onPressed: () => HeraldScope.of(context).track(PromoBannerTapped(promoId)),
        child: const Text('See the offer'),
      );
  // --8<-- [end:tap]
}

final class const OfferList(final List<String> offerIds, {super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      // --8<-- [start:impression]
      ListView(
        children: [
          for (final offerId in offerIds)
            TrackImpression(
              event: OfferShown(offerId),
              threshold: 0.5, // half of it on screen
              minVisibleDuration: const Duration(seconds: 1), // for a second, not a fast scroll
              child: ListTile(title: Text(offerId)),
            ),
        ],
      );
  // --8<-- [end:impression]
}
