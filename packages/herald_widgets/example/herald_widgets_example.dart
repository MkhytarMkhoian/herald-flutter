import 'package:flutter/material.dart';
import 'package:herald/herald.dart';
import 'package:herald_widgets/herald_widgets.dart';

final class const HomeScreenViewed() extends ScreenViewEvent {
  @override
  String get name => 'home';
}

final class const OfferShown(final String offerId) extends Event {
  @override
  String get name => 'offer_shown';

  @override
  Map<String, AnalyticsValue> get parameters => {'offer_id': .string(offerId)};

  @override
  bool operator ==(Object other) => other is OfferShown && other.offerId == offerId;

  @override
  int get hashCode => offerId.hashCode;
}

final class const OfferTapped(final String offerId) extends Event {
  @override
  String get name => 'offer_tapped';

  @override
  Map<String, AnalyticsValue> get parameters => {'offer_id': .string(offerId)};
}

/// Stands in for your vendors: in an app, use a Herald set up with herald_firebase and the rest.
final class PrintEventTracker implements EventTrackerService {
  @override
  Future<void> track(Event event) async => debugPrint('${event.name} ${event.parameters}');
}

void main() {
  final routes = HeraldRouteObserver();
  runApp(
    HeraldScope(
      analytics: PrintEventTracker(),
      routes: routes,
      child: MaterialApp(navigatorObservers: [routes], home: const HomePage()),
    ),
  );
}

final class const HomePage({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => TrackScreenView(
    event: const HomeScreenViewed(),
    child: Scaffold(
      body: ListView(
        children: [
          for (final offerId in ['spring', 'summer', 'autumn'])
            TrackImpression(
              event: OfferShown(offerId),
              minVisibleDuration: const Duration(seconds: 1),
              child: ListTile(
                title: Text(offerId),
                onTap: () => HeraldScope.of(context).track(OfferTapped(offerId)),
              ),
            ),
        ],
      ),
    ),
  );
}
