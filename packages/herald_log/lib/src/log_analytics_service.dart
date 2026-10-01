import 'package:herald/herald.dart';

import 'analytics_logger.dart';
import 'log_record.dart';

/// Prints the calls that are not events or properties, so the log shows the whole story: whether
/// consent was ever granted, whether `identify` ran before the first event, whether `reset` fired
/// on sign-out.
///
/// The user id is printed as-is. That is the point in a debug build and a leak in a release one,
/// so register this provider under the same condition as the rest of the log adapter:
///
/// ```dart
/// if (kDebugMode)
///   HeraldProvider(
///     name: 'log',
///     events: logTracker,
///     properties: logTracker,
///     identity: logService,
///     lifecycle: logService,
///     consent: logService,
///   ),
/// ```
final class const LogAnalyticsService(final AnalyticsLogger logger)
    implements IdentifiableUserService, AnalyticsLifecycleService, ConsentService {
  @override
  Future<void> identify(Identity identity) async =>
      logger(logRecord(kind: 'user', headline: identity.userId));

  @override
  Future<void> reset() async => logger(logRecord(kind: 'reset', headline: ''));

  @override
  Future<void> start() async => logger(logRecord(kind: 'start', headline: ''));

  @override
  Future<void> flush() async => logger(logRecord(kind: 'flush', headline: ''));

  @override
  Future<void> setEnabled(bool enabled) async =>
      logger(logRecord(kind: 'enabled', headline: '$enabled'));
}
