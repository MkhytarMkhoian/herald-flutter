import 'package:herald/herald.dart';
import 'package:herald_log/herald_log.dart';

final class const TestEvent(
  @override final String name, [
  @override final Map<String, AnalyticsValue> parameters = const {},
]) extends Event;

final class const TestScreenView(
  @override final String name, [
  @override final Map<String, AnalyticsValue> parameters = const {},
]) extends ScreenViewEvent;

final class const TestProperty(@override final String name, @override final AnalyticsValue value)
    extends Property;

/// Prints a fixed [message], standing in for a custom tracker.
final class const MessageLogEventTracker(final AnalyticsLogger logger, final String message)
    implements LogEventTracker {
  @override
  Future<void> track() async => logger(message);
}

/// Fails, standing in for a tracker that throws.
final class const ThrowingLogEventTracker() implements LogEventTracker {
  @override
  Future<void> track() async => throw StateError('tracker failed');
}

/// Claims the event called [eventName] with [handlers], and declines the rest.
final class const ClaimingLogEventTrackerFactory(
  final String eventName,
  final List<LogEventTracker> handlers,
) implements LogEventTrackerFactory {
  @override
  Resolution<LogEventTracker> create(Event event) =>
      event.name == eventName ? .claimed(handlers) : .declined();
}
