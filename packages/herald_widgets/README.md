# Herald widgets

An optional package for tracking Herald events from Flutter widgets: screen views each time a
screen becomes visible, impressions when something is really on screen, and taps in widgets that
have no bloc.

You don't need it to use Herald. A screen, bloc or view model can track its own events, screen
views included, through `EventTrackerService`. Use this package when tracking from the widget tree
is the simpler fit, such as counting a screen each time the user comes back to it.

```yaml
dependencies:
  herald_widgets: ^1.0.0-dev.2
```

## Set it up once

```dart
final routes = HeraldRouteObserver();

runApp(
  HeraldScope(
    analytics: herald, // or your DI's EventTrackerService
    routes: routes,
    child: MaterialApp(
      navigatorObservers: [routes], // go_router: GoRouter(observers: [routes])
      home: const HomePage(),
    ),
  ),
);
```

## Screen views, owned by each screen

```dart
@override
Widget build(BuildContext context) => TrackScreenView(
  event: ProductScreenViewed(productId),
  child: Scaffold(...),
);
```

It tracks each time the screen becomes visible: when it appears, when the user comes back to it,
and when the app comes back to view with it on top. Rebuilds don't count, and neither do dialogs,
bottom sheets or menus over it.

To track when the user leaves a screen:

```dart
TrackOnScreen(
  event: CheckoutLeft(itemsInCart: cart.length),
  on: ScreenMoment.hidden,
  child: CheckoutView(cart),
)
```

## Taps

```dart
ElevatedButton(
  onPressed: () => HeraldScope.of(context).track(PromoBannerTapped(promo.id)),
  child: const Text('See the offer'),
)
```

Events that come from your app's logic belong in its bloc or view model. This is for small widgets
that have none.

## Impressions

```dart
TrackImpression(
  event: OfferShown(offer.id),
  threshold: 0.5, // half of it on screen
  minVisibleDuration: const Duration(seconds: 1), // for a second, not a fast scroll
  child: OfferCard(offer),
)
```

It counts once per appearance: something that leaves the screen and comes back counts again.
Give events value equality, so a rebuild with an equal event doesn't start the count again.

## Tests and previews

Wrap the widget in a `HeraldScope` with a `FakeAnalyticsProvider` from `herald_testing`, and add a
`HeraldRouteObserver` for screens:

```dart
final analytics = FakeAnalyticsProvider();
final routes = HeraldRouteObserver();
await tester.pumpWidget(
  HeraldScope(
    analytics: analytics,
    routes: routes,
    child: MaterialApp(navigatorObservers: [routes], home: const ProductPage('p1')),
  ),
);

analytics.assertTracked('product', (event) => event.param('product_id', 'p1'));
```

A widget preview can do the same through `@Preview(wrapper: ...)`.

## Limits

- **Tabs aren't screens.** Switching tabs doesn't push a page, so track it from the code that
  switches.
- **A nested `Navigator`**, such as go_router's shell route, needs a `HeraldRouteObserver` of its
  own, given to a `HeraldScope` around it.

## Documentation

The [Herald website](https://mkhytarmkhoian.github.io/herald/) has the guides, and the
[repository](https://github.com/MkhytarMkhoian/herald-flutter) has the other packages and an
example app.
