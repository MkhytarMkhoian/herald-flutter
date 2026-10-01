import 'event.dart';

/// Somewhere an [Event] can be sent.
///
/// Vendor adapters, `Herald` and your own decorators implement it. A class that only tracks
/// events should depend on this, not on `Herald`.
///
/// ```dart
/// // Keeps events with personal data away from [inner].
/// final class const ExceptPiiEventTracker(final EventTrackerService inner)
///     implements EventTrackerService {
///   @override
///   Future<void> track(Event event) async {
///     if (event is! PiiEvent) await inner.track(event);
///   }
/// }
/// ```
abstract interface class EventTrackerService {
  Future<void> track(Event event);
}
