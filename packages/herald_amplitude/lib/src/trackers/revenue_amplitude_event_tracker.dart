import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/events/event_options.dart';

import '../amplitude_event_tracker.dart';
import '../amplitude_revenue_event.dart';

/// Sends [event] through Amplitude's revenue API. Its `insertId` goes as an event option, since
/// Amplitude's revenue type has no field for it.
final class const RevenueAmplitudeEventTracker(
  final AmplitudeRevenueEvent event,
  final Amplitude amplitude,
) implements AmplitudeEventTracker {
  @override
  Future<void> track() {
    final insertId = event.insertId;
    return amplitude.revenue(
      event.toAmplitudeRevenue(),
      insertId == null ? null : EventOptions(insertId: insertId),
    );
  }
}
