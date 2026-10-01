import 'package:herald/herald.dart';

import '../analytics_logger.dart';
import '../log_event_tracker.dart';
import '../log_record.dart';

final class const GenericLogEventTracker(final Event event, final AnalyticsLogger logger)
    implements LogEventTracker {
  @override
  Future<void> track() async =>
      logger(logRecord(kind: 'event', headline: event.name, parameters: event.parameters));
}
