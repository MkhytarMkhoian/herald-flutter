import 'package:flutter/widgets.dart';
import 'package:herald/herald.dart';

/// Tracks a screen view whenever a route becomes the visible one: when it is pushed, and when the
/// route above it is popped.
///
/// [screenViewFor] maps a route to its screen view, or `null` for routes that are not screens,
/// such as dialogs. Add it to `MaterialApp.navigatorObservers` (or go_router's `observers`).
class ScreenViewObserver(
  final EventTrackerService analytics,
  final ScreenViewEvent? Function(Route<Object?> route) screenViewFor,
) extends NavigatorObserver {
  void _track(Route<Object?>? route) {
    if (route == null) return;
    // Herald never fails a call, so there's nothing to wait for.
    if (screenViewFor(route) case final event?) analytics.track(event).ignore();
  }

  @override
  void didPush(Route<Object?> route, Route<Object?>? previousRoute) => _track(route);

  @override
  void didPop(Route<Object?> route, Route<Object?>? previousRoute) => _track(previousRoute);

  @override
  void didReplace({Route<Object?>? newRoute, Route<Object?>? oldRoute}) => _track(newRoute);
}
