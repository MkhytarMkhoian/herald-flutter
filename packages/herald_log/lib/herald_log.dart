/// A Herald vendor that prints every call, for debug builds.
///
/// ```dart
/// final logTracker = LogAnalyticsTrackerService(
///   eventTrackerFactory: CompositeLogEventTrackerFactory([
///     ScreenViewLogEventTrackerFactory(debugPrint),
///     GenericLogEventTrackerFactory(debugPrint),
///   ]),
///   propertySetterFactory: CompositeLogPropertySetterFactory([
///     GenericLogPropertySetterFactory(debugPrint),
///   ]),
/// );
/// ```
library;

export 'src/analytics_logger.dart';
export 'src/log_analytics_service.dart';
export 'src/log_analytics_tracker_service.dart';
export 'src/log_event_tracker.dart';
export 'src/log_event_tracker_factory.dart';
export 'src/log_factories.dart';
export 'src/log_property_setter.dart';
export 'src/log_property_setter_factory.dart';
export 'src/require_mapped_log_factories.dart';
export 'src/setters/generic_log_property_setter.dart';
export 'src/trackers/generic_log_event_tracker.dart';
export 'src/trackers/screen_view_log_event_tracker.dart';
