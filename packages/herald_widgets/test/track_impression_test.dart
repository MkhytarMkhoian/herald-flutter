import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:herald/herald.dart';
import 'package:herald_testing/herald_testing.dart';
import 'package:herald_widgets/herald_widgets.dart';
import 'package:visibility_detector/visibility_detector.dart';

final class const _OfferShown(final String offerId) extends Event {
  @override
  String get name => 'offer_shown';

  @override
  Map<String, AnalyticsValue> get parameters => {'offer_id': .string(offerId)};

  @override
  bool operator ==(Object other) => other is _OfferShown && other.offerId == offerId;

  @override
  int get hashCode => offerId.hashCode;
}

/// A 1000-pixel-tall offer at the top of a 4000-pixel page, in an 800×600 test screen: 60% of it
/// is visible until [scroll] moves it. The page keeps the offer built while it is off screen, as a
/// `Column` does, so leaving and coming back is the same widget.
Widget _page(
  FakeAnalyticsProvider analytics,
  ScrollController scroll, {
  String offerId = 'spring',
  double threshold = 0.5,
  Duration minVisibleDuration = Duration.zero,
}) => HeraldScope(
  analytics: analytics,
  child: MaterialApp(
    home: SingleChildScrollView(
      controller: scroll,
      child: Column(
        children: [
          TrackImpression(
            event: _OfferShown(offerId),
            threshold: threshold,
            minVisibleDuration: minVisibleDuration,
            child: const SizedBox(width: double.infinity, height: 1000),
          ),
          const SizedBox(height: 3000),
        ],
      ),
    ),
  ),
);

void main() {
  late FakeAnalyticsProvider analytics;
  late ScrollController scroll;

  setUp(() {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
    analytics = FakeAnalyticsProvider();
    scroll = ScrollController();
  });

  tearDown(() => scroll.dispose());

  testWidgets('an offer visible past the threshold is tracked once', (tester) async {
    await tester.pumpWidget(_page(analytics, scroll));
    await tester.pump();
    await tester.pumpWidget(_page(analytics, scroll));
    await tester.pump();

    analytics.assertTracked('offer_shown', (event) => event.param('offer_id', 'spring'));
  });

  testWidgets('below the threshold nothing is tracked', (tester) async {
    await tester.pumpWidget(_page(analytics, scroll, threshold: 0.7));
    await tester.pump();

    analytics.assertNothingTracked();
  });

  testWidgets('with a minimum time, it must stay visible that long', (tester) async {
    await tester.pumpWidget(
      _page(analytics, scroll, minVisibleDuration: const Duration(seconds: 1)),
    );
    await tester.pump(); // the frame that reports the offer visible: the second starts here
    await tester.pump(const Duration(milliseconds: 900));
    analytics.assertNothingTracked();

    await tester.pump(const Duration(milliseconds: 200));
    analytics.assertTracked('offer_shown');
  });

  testWidgets('dropping below the threshold before the minimum time cancels the count', (
    tester,
  ) async {
    await tester.pumpWidget(
      _page(analytics, scroll, minVisibleDuration: const Duration(seconds: 1)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    scroll.jumpTo(800); // 20% left on screen
    await tester.pump(); // the frame that moves the offer
    await tester.pump(const Duration(seconds: 2));

    analytics.assertNothingTracked();
  });

  testWidgets('an offer that leaves the screen and comes back counts again', (tester) async {
    await tester.pumpWidget(_page(analytics, scroll));
    await tester.pump();

    scroll.jumpTo(2000);
    await tester.pump();
    scroll.jumpTo(0);
    await tester.pump();
    await tester.pump();

    analytics.assertTrackedTimes('offer_shown', 2);
  });

  testWidgets('a new event in the same place starts the count again', (tester) async {
    await tester.pumpWidget(_page(analytics, scroll));
    await tester.pump();

    await tester.pumpWidget(_page(analytics, scroll, offerId: 'summer'));
    await tester.pump();
    await tester.pump();

    expect(analytics.events, [const _OfferShown('spring'), const _OfferShown('summer')]);
  });

  testWidgets('a threshold outside 0 to 1 is refused', (tester) async {
    await tester.pumpWidget(_page(analytics, scroll, threshold: 1.5));

    expect(tester.takeException(), isArgumentError);
  });

  testWidgets('without a HeraldScope, the error says to add one', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TrackImpression(event: _OfferShown('spring'), child: SizedBox(height: 100)),
      ),
    );

    expect(
      tester.takeException(),
      isA<FlutterError>().having((e) => e.message, 'message', contains('No HeraldScope')),
    );
  });
}
