import 'dart:async';

import 'analytics_operation.dart';

/// Where Herald reports a vendor that failed.
///
/// Herald catches a failing vendor so the others still run. Without a reporter you won't see the
/// failure, so send it to your crash or logging tool. The reporter may return a future; Herald
/// doesn't wait for it, and ignores it if it fails:
///
/// ```dart
/// errorReporter: (failure) => crashReporter.recordError(
///   failure.error,
///   failure.stackTrace,
///   reason: '$failure',
/// ),
/// ```
typedef AnalyticsErrorReporter = FutureOr<void> Function(AnalyticsFailure failure);

/// A vendor call that failed: which vendor, which call, and what it threw.
///
/// It holds no event parameters, property values or user id, so it's safe to send to a crash tool.
/// Its [toString] reads like `analytics failed on Track(checkout_started): <error>`.
final class const AnalyticsFailure(
  final String provider,
  final AnalyticsOperation operation,
  final Object error,
  final StackTrace stackTrace,
) {
  @override
  String toString() => '$provider failed on $operation: $error';
}
