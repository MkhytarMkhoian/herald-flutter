import 'package:herald/herald.dart';

/// The wrapper most apps already have, called from everywhere.
class LegacyAnalytics {
  Future<void> logEvent(String name, Map<String, String> params) async {}
}

// --8<-- [start:bridge]
// Step 1: Herald forwards to the old wrapper, so migrated and unmigrated code report the same.
final class const LegacyEventTracker(final LegacyAnalytics legacy) implements EventTrackerService {
  @override
  Future<void> track(Event event) => legacy.logEvent(event.name, {
    for (final MapEntry(:key, :value) in event.parameters.entries) key: value.asString,
  });
}

Herald migratingHerald(LegacyAnalytics legacy) => Herald(
  providers: [HeraldProvider(name: 'legacy', events: LegacyEventTracker(legacy))],
);
// --8<-- [end:bridge]
