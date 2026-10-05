import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:herald/herald.dart';

import 'herald_scope.dart';

/// When a screen is tracked by [TrackOnScreen].
enum ScreenMoment {
  /// The screen became visible: it appeared, the screen above it closed, or the app came back to
  /// view with it on top.
  shown,

  /// The screen stopped being visible: another screen opened over it, it closed, or the app went
  /// out of view.
  hidden,
}

/// Tells [TrackScreenView] and [TrackOnScreen] when their screen is shown or hidden. Add it to the
/// `Navigator`'s observers, and give the same one to [HeraldScope] as `routes`.
///
/// A screen is a full page, a [PageRoute]. A dialog, bottom sheet or menu over it doesn't hide it.
/// The app briefly losing focus, as under the notification shade, doesn't either: only going out
/// of view does.
///
/// It can watch one `Navigator`. A nested navigator needs one of its own.
final class HeraldRouteObserver extends NavigatorObserver {
  final List<Route<Object?>> _routes = [];
  final Map<PageRoute<Object?>, Set<_TrackOnScreenState>> _listeners = {};
  PageRoute<Object?>? _top;
  bool _appVisible = true;
  AppLifecycleListener? _appLifecycle;

  @override
  void didPush(Route<Object?> route, Route<Object?>? previousRoute) {
    _routes.add(route);
    _update();
  }

  @override
  void didPop(Route<Object?> route, Route<Object?>? previousRoute) {
    _routes.remove(route);
    _update();
  }

  @override
  void didRemove(Route<Object?> route, Route<Object?>? previousRoute) {
    _routes.remove(route);
    _update();
  }

  @override
  void didReplace({Route<Object?>? newRoute, Route<Object?>? oldRoute}) {
    final index = _routes.indexOf(oldRoute!);
    if (index == -1) {
      _routes.add(newRoute!);
    } else {
      _routes[index] = newRoute!;
    }
    _update();
  }

  /// Moves the top screen when the page on top changes, and tells both.
  void _update() {
    PageRoute<Object?>? top;
    for (final route in _routes.reversed) {
      if (route is PageRoute<Object?>) {
        top = route;
        break;
      }
    }
    if (identical(top, _top)) return;
    final previous = _top;
    _top = top;
    if (!_appVisible) return;
    _notify(previous, ScreenMoment.hidden);
    _notify(top, ScreenMoment.shown);
  }

  void _notify(PageRoute<Object?>? route, ScreenMoment moment) {
    for (final listener in _listeners[route]?.toList() ?? const <_TrackOnScreenState>[]) {
      listener._reach(moment);
    }
  }

  void _subscribe(_TrackOnScreenState listener, PageRoute<Object?> route) {
    if (navigator == null) {
      throw FlutterError(
        "The HeraldScope's HeraldRouteObserver isn't watching any Navigator.\n"
        "Add it to the Navigator's observers, such as MaterialApp.navigatorObservers or "
        "GoRouter's observers.",
      );
    }
    if (!identical(route.navigator, navigator)) {
      throw FlutterError(
        "This screen's Navigator isn't the one the HeraldRouteObserver watches.\n"
        'A nested Navigator needs a HeraldRouteObserver of its own, given to a HeraldScope '
        'around it.',
      );
    }
    _appLifecycle ??= _watchApp();
    _listeners.putIfAbsent(route, () => {}).add(listener);
    if (identical(route, _top) && _appVisible) listener._reach(ScreenMoment.shown);
  }

  void _unsubscribe(_TrackOnScreenState listener) {
    for (final route in _listeners.keys.toList()) {
      final listeners = _listeners[route]!..remove(listener);
      if (listeners.isEmpty) _listeners.remove(route);
    }
  }

  AppLifecycleListener _watchApp() {
    final state = WidgetsBinding.instance.lifecycleState;
    _appVisible =
        state == null || state == AppLifecycleState.resumed || state == AppLifecycleState.inactive;
    return AppLifecycleListener(onShow: _appShown, onHide: _appHidden);
  }

  void _appShown() {
    _appVisible = true;
    _notify(_top, ScreenMoment.shown);
  }

  void _appHidden() {
    _appVisible = false;
    _notify(_top, ScreenMoment.hidden);
  }
}

/// Tracks [event] each time its screen reaches [on]: by default, each time the screen becomes
/// visible. Rebuilds don't count.
///
/// It needs a [HeraldScope] with `routes` above it, and must be inside a page: a dialog or a sheet
/// isn't a screen.
final class const TrackOnScreen({
  super.key,
  required final Event event,
  final ScreenMoment on = .shown,
  required final Widget child,
}) extends StatefulWidget {
  @override
  State<TrackOnScreen> createState() => _TrackOnScreenState();
}

final class _TrackOnScreenState extends State<TrackOnScreen> {
  late EventTrackerService _analytics;
  HeraldRouteObserver? _routes;
  PageRoute<Object?>? _route;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _analytics = HeraldScope.of(context);
    final routes = HeraldScope.routesOf(context);
    final route = ModalRoute.of(context);
    if (route is! PageRoute<Object?>) {
      throw FlutterError(
        '${widget.runtimeType} must be inside a page route.\n'
        "A dialog, bottom sheet or menu isn't a screen; track it from where it opens.",
      );
    }
    // The route's status changes often, as when a dialog opens over it; only a new route or
    // observer means subscribing again.
    if (identical(routes, _routes) && identical(route, _route)) return;
    _routes?._unsubscribe(this);
    _routes = routes;
    _route = route;
    routes._subscribe(this, route);
  }

  void _reach(ScreenMoment moment) {
    if (moment != widget.on) return;
    final event = widget.event;
    final analytics = _analytics;
    // Screens are often shown during a build, and a tracker that updates the UI can't run then.
    scheduleMicrotask(() => analytics.track(event).ignore());
  }

  @override
  void dispose() {
    _routes?._unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Tracks [event] each time its screen becomes visible: when it appears, when the user comes back
/// to it, and when the app comes back to view with it on top. That is what Firebase's automatic
/// screen tracking counts.
///
/// It needs a [HeraldScope] with `routes` above it, and must be inside a page.
final class const TrackScreenView({
  super.key,
  required final ScreenViewEvent event,
  required final Widget child,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => TrackOnScreen(event: event, child: child);
}
