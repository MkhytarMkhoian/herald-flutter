import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:herald/herald.dart';
import 'package:herald_testing/herald_testing.dart';
import 'package:herald_widgets/herald_widgets.dart';

final class const _ScreenViewed(@override final String name) extends ScreenViewEvent;

final class const _Left(@override final String name) extends Event;

/// A page that tracks its screen view, and `<name>_left` when it is hidden.
final class const _Page(final String name) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => TrackScreenView(
    event: _ScreenViewed(name),
    child: TrackOnScreen(event: _Left('${name}_left'), on: .hidden, child: Text(name)),
  );
}

Widget _app(
  FakeAnalyticsProvider analytics,
  HeraldRouteObserver routes,
  GlobalKey<NavigatorState> navigator, {
  Widget home = const _Page('home'),
}) => HeraldScope(
  analytics: analytics,
  routes: routes,
  child: MaterialApp(navigatorKey: navigator, navigatorObservers: [routes], home: home),
);

List<String> _tracked(FakeAnalyticsProvider analytics) => [
  for (final event in analytics.events) event.name,
];

/// A tracker that changes UI state as soon as it gets an event, like an in-app event inspector.
final class _Timeline extends ChangeNotifier implements EventTrackerService {
  int count = 0;

  @override
  Future<void> track(Event event) async {
    count++;
    notifyListeners();
  }
}

MaterialPageRoute<void> _page(String name) => MaterialPageRoute(builder: (_) => _Page(name));

void main() {
  late FakeAnalyticsProvider analytics;
  late HeraldRouteObserver routes;
  late GlobalKey<NavigatorState> navigator;

  setUp(() {
    analytics = FakeAnalyticsProvider();
    routes = HeraldRouteObserver();
    navigator = GlobalKey<NavigatorState>();
  });

  group('shown and hidden', () {
    testWidgets('a page is shown when it appears', (tester) async {
      await tester.pumpWidget(_app(analytics, routes, navigator));

      expect(_tracked(analytics), ['home']);
    });

    testWidgets("rebuilding a page doesn't track it again", (tester) async {
      await tester.pumpWidget(_app(analytics, routes, navigator));
      await tester.pumpWidget(_app(analytics, routes, navigator));

      expect(_tracked(analytics), ['home']);
    });

    testWidgets('a page pushed over another hides it, and popping it shows it again', (
      tester,
    ) async {
      await tester.pumpWidget(_app(analytics, routes, navigator));

      navigator.currentState!.push(_page('details')).ignore();
      await tester.pumpAndSettle();
      navigator.currentState!.pop();
      await tester.pumpAndSettle();

      expect(_tracked(analytics), ['home', 'home_left', 'details', 'details_left', 'home']);
    });

    testWidgets("a dialog over a page doesn't hide it, and closing it doesn't show it", (
      tester,
    ) async {
      await tester.pumpWidget(_app(analytics, routes, navigator));

      showDialog<void>(
        context: navigator.currentContext!,
        builder: (_) => const Text('dialog'),
      ).ignore();
      await tester.pumpAndSettle();
      navigator.currentState!.pop();
      await tester.pumpAndSettle();

      expect(_tracked(analytics), ['home']);
    });

    testWidgets('replacing a page hides it and shows the new one', (tester) async {
      await tester.pumpWidget(_app(analytics, routes, navigator));

      navigator.currentState!.pushReplacement(_page('details')).ignore();
      await tester.pumpAndSettle();

      expect(_tracked(analytics), ['home', 'home_left', 'details']);
    });

    testWidgets('removing the page on top shows the one below', (tester) async {
      final details = _page('details');
      await tester.pumpWidget(_app(analytics, routes, navigator));
      navigator.currentState!.push(details).ignore();
      await tester.pumpAndSettle();

      navigator.currentState!.removeRoute(details);
      await tester.pumpAndSettle();

      expect(_tracked(analytics), ['home', 'home_left', 'details', 'details_left', 'home']);
    });
  });

  group('the app', () {
    testWidgets('going out of view hides the page on top, and coming back shows it', (
      tester,
    ) async {
      await tester.pumpWidget(_app(analytics, routes, navigator));

      tester.binding
        ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
        ..handleAppLifecycleStateChanged(AppLifecycleState.hidden)
        ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
        ..handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();

      expect(_tracked(analytics), ['home', 'home_left', 'home']);
    });

    testWidgets("briefly losing focus, as under the notification shade, doesn't count", (
      tester,
    ) async {
      await tester.pumpWidget(_app(analytics, routes, navigator));

      tester.binding
        ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
        ..handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();

      expect(_tracked(analytics), ['home']);
    });
  });

  testWidgets('a tracker that updates the UI at once works, though screens show during a build', (
    tester,
  ) async {
    final timeline = _Timeline();
    await tester.pumpWidget(
      HeraldScope(
        analytics: timeline,
        routes: routes,
        child: MaterialApp(
          navigatorObservers: [routes],
          home: Column(
            children: [
              // Already listening when the page below tracks its screen view, as an inspector is.
              ListenableBuilder(listenable: timeline, builder: (_, _) => Text('${timeline.count}')),
              const Expanded(child: _Page('home')),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('1'), findsOneWidget);
  });

  group('setup mistakes', () {
    testWidgets('without a HeraldScope, the error says to add one', (tester) async {
      await tester.pumpWidget(MaterialApp(navigatorObservers: [routes], home: const _Page('home')));

      expect(
        tester.takeException(),
        isA<FlutterError>().having((e) => e.message, 'message', contains('No HeraldScope')),
      );
    });

    testWidgets('a HeraldScope without routes says to pass them', (tester) async {
      await tester.pumpWidget(
        HeraldScope(
          analytics: analytics,
          child: const MaterialApp(home: _Page('home')),
        ),
      );

      expect(
        tester.takeException(),
        isA<FlutterError>().having((e) => e.message, 'message', contains('has no routes')),
      );
    });

    testWidgets("an observer the Navigator doesn't have says to add it", (tester) async {
      await tester.pumpWidget(
        HeraldScope(
          analytics: analytics,
          routes: routes,
          child: const MaterialApp(home: _Page('home')),
        ),
      );

      expect(
        tester.takeException(),
        isA<FlutterError>().having((e) => e.message, 'message', contains("isn't watching")),
      );
    });

    testWidgets('a screen widget in a dialog says a dialog is not a screen', (tester) async {
      await tester.pumpWidget(_app(analytics, routes, navigator));

      showDialog<void>(
        context: navigator.currentContext!,
        builder: (_) => const _Page('dialog'),
      ).ignore();
      await tester.pump();

      expect(
        tester.takeException(),
        isA<FlutterError>().having((e) => e.message, 'message', contains('inside a page route')),
      );
    });
  });
}
