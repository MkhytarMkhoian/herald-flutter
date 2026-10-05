import 'package:flutter/widgets.dart';
import 'package:herald/herald.dart';

import 'screen_tracking.dart';

/// Gives the widgets below it the app's tracker, and the [routes] that tell [TrackScreenView] and
/// [TrackOnScreen] when their screen is shown or hidden.
///
/// Put one around the app. A nested `Navigator`, such as go_router's shell route, has its own
/// [HeraldRouteObserver]: give it to another `HeraldScope` around that navigator.
final class const HeraldScope({
  super.key,
  required final EventTrackerService analytics,
  final HeraldRouteObserver? routes,
  required super.child,
}) extends InheritedWidget {
  /// The tracker of the nearest [HeraldScope]. Throws if there is none.
  static EventTrackerService of(BuildContext context) => _scopeOf(context).analytics;

  /// The route observer of the nearest [HeraldScope]. Throws if there is none, or it has none.
  static HeraldRouteObserver routesOf(BuildContext context) {
    final routes = _scopeOf(context).routes;
    if (routes == null) {
      throw FlutterError(
        'The HeraldScope above has no routes.\n'
        'TrackScreenView and TrackOnScreen need a HeraldRouteObserver: pass it to HeraldScope '
        "as `routes`, and add it to the Navigator's observers.",
      );
    }
    return routes;
  }

  static HeraldScope _scopeOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<HeraldScope>();
    if (scope == null) {
      throw FlutterError(
        'No HeraldScope found above ${context.widget.runtimeType}.\n'
        'Wrap the app in HeraldScope(analytics: ..., child: ...).',
      );
    }
    return scope;
  }

  @override
  bool updateShouldNotify(HeraldScope oldWidget) =>
      analytics != oldWidget.analytics || routes != oldWidget.routes;
}
