import 'package:herald/herald.dart';

final class const TestEvent(
  @override final String name, [
  @override final Map<String, AnalyticsValue> parameters = const {},
]) extends Event;

final class const TestProperty(@override final String name, @override final AnalyticsValue value)
    extends Property;

final class RecordingService([final List<String>? calls])
    implements
        AnalyticsLifecycleService,
        EventTrackerService,
        PropertyTrackerService,
        IdentifiableUserService,
        ConsentService {
  final received = <String>[];
  Object? failure;

  Future<void> _record(String call) async {
    received.add(call);
    calls?.add(call);
    final failure = this.failure;
    if (failure != null) throw failure;
  }

  @override
  Future<void> track(Event event) => _record('track ${event.name}');

  @override
  Future<void> set(Property property) => _record('set ${property.name}');

  @override
  Future<void> identify(Identity identity) => _record('identify ${identity.userId}');

  @override
  Future<void> reset() => _record('reset');

  @override
  Future<void> start() => _record('start');

  @override
  Future<void> flush() => _record('flush');

  @override
  Future<void> setEnabled(bool enabled) => _record('enabled $enabled');
}

final class TestEventTracker(final Future<void> Function(Event event) onTrack)
    implements EventTrackerService {
  @override
  Future<void> track(Event event) => onTrack(event);
}
