/// Herald: one analytics vocabulary, heard by every vendor.
///
/// Your app describes what happened as an [Event], and [Herald] sends it to every analytics
/// service you use. Each vendor's adapter lives in its own package.
library;

export 'src/analytics_error_reporter.dart';
export 'src/analytics_lifecycle_service.dart';
export 'src/analytics_operation.dart';
export 'src/analytics_value.dart';
export 'src/consent_service.dart';
export 'src/event.dart';
export 'src/event_tracker_service.dart';
export 'src/fallback_factory.dart';
export 'src/herald.dart';
export 'src/identifiable_user_service.dart';
export 'src/identity.dart';
export 'src/property.dart';
export 'src/property_tracker_service.dart';
export 'src/resolution.dart';
export 'src/unhandled_exceptions.dart';
