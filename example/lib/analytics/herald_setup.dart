import 'package:flutter/foundation.dart';
import 'package:herald/herald.dart';
import 'package:herald_log/herald_log.dart';

import 'timeline_analytics.dart';

/// The composition root: the one place that knows which vendors the app uses.
///
/// A real app adds its vendors here — `herald_firebase`, `herald_mixpanel` and the rest — each as
/// one more [HeraldProvider]. Nothing else in the app changes.
Herald buildHerald(TimelineAnalytics timeline) {
  final AnalyticsLogger logger = debugPrint;
  final logTracker = LogAnalyticsTrackerService(
    eventTrackerFactory: CompositeLogEventTrackerFactory([
      ScreenViewLogEventTrackerFactory(logger),
      GenericLogEventTrackerFactory(logger),
    ]),
    propertySetterFactory: CompositeLogPropertySetterFactory([
      GenericLogPropertySetterFactory(logger),
    ]),
  );
  final logService = LogAnalyticsService(logger);

  return Herald(
    providers: [
      if (kDebugMode)
        HeraldProvider(
          name: 'log',
          events: logTracker,
          properties: logTracker,
          identity: logService,
          lifecycle: logService,
          consent: logService,
        ),
      HeraldProvider(
        name: 'timeline',
        events: timeline,
        properties: timeline,
        identity: timeline,
        lifecycle: timeline,
        consent: timeline,
      ),
    ],
    errorReporter: (failure) => debugPrint('analytics: $failure'),
  );
}
