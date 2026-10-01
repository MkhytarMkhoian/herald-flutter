/// Where the log adapter prints.
///
/// Every record is one call with one string, already formatted. Point it at whatever logging you
/// use — Flutter's `debugPrint` fits as-is, as does `(message) => log(message, name: 'analytics')`
/// from `dart:developer` — and pass it to the adapter's factories.
///
/// One level only: a record is debug output by nature, and which level that maps to is the
/// implementation's decision.
typedef AnalyticsLogger = void Function(String message);
