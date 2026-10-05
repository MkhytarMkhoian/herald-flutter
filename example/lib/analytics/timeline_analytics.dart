import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:herald/herald.dart';

/// A provider of your own: it keeps every call as a line, for the timeline screen.
///
/// Implementing Herald's interfaces is all a provider takes. This one implements all five, so it
/// sees the whole story — consent, sign-in, events and properties — in the order Herald sent it.
final class TimelineAnalytics extends ChangeNotifier
    implements
        EventTrackerService,
        PropertyTrackerService,
        IdentifiableUserService,
        AnalyticsLifecycleService,
        ConsentService {
  final List<String> _lines = [];

  List<String> get lines => _lines.reversed.toList(growable: false);

  void _add(String line) {
    _lines.add(line);
    // A call can come in the middle of a build, such as a screen tracking itself in initState, and
    // the timeline on screen can't rebuild then. So it updates right after.
    scheduleMicrotask(notifyListeners);
  }

  @override
  Future<void> track(Event event) async {
    final parameters = event.parameters.entries.map((it) => '${it.key}=${it.value.asString}');
    final title = event is ScreenViewEvent ? 'screen ${event.name}' : 'event ${event.name}';
    _add(parameters.isEmpty ? title : '$title  ${parameters.join(', ')}');
  }

  @override
  Future<void> set(Property property) async =>
      _add('property ${property.name}=${property.value.asString}');

  @override
  Future<void> identify(Identity identity) async => _add('identify ${identity.userId}');

  @override
  Future<void> reset() async => _add('reset');

  @override
  Future<void> start() async => _add('start');

  @override
  Future<void> flush() async => _add('flush');

  @override
  Future<void> setEnabled(bool enabled) async => _add('consent $enabled');
}
