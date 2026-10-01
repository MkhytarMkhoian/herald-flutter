/// A parameter or property value that keeps its type, so a number reaches the vendor as a number.
///
/// Vendors can sum or average numbers, but only group text. Vendors that take only text use
/// [asString].
///
/// ```dart
/// @override
/// Map<String, AnalyticsValue> get parameters => {
///   'plan': .string(plan),
///   'seats': .int(seats),
///   'price': .double(9.99),
///   'trial': .bool(false),
/// };
/// ```
///
/// On the web, `3.0` and `3` are the same number, so pick the constructor for the type you mean.
sealed class AnalyticsValue {
  const AnalyticsValue();

  const factory AnalyticsValue.string(String value) = AnalyticsString;

  const factory AnalyticsValue.int(int value) = AnalyticsInt;

  const factory AnalyticsValue.double(double value) = AnalyticsDouble;

  const factory AnalyticsValue.bool(bool value) = AnalyticsBool;

  /// Wraps a [String], [int], [double] or [bool] by its runtime type, and throws for anything else.
  /// Prefer the typed constructors: on the web, a whole `double` is an `int`.
  factory AnalyticsValue.of(Object value) => switch (value) {
    final String value => AnalyticsString(value),
    final int value => AnalyticsInt(value),
    final double value => AnalyticsDouble(value),
    final bool value => AnalyticsBool(value),
    _ => throw ArgumentError.value(
      value,
      'value',
      'An analytics value is a String, int, double or bool, not ${value.runtimeType}',
    ),
  };

  Object get value;

  /// The value as text, for vendors that take only text.
  String get asString => value.toString();

  @override
  bool operator ==(Object other) =>
      other is AnalyticsValue && other.runtimeType == runtimeType && other.value == value;

  @override
  int get hashCode => Object.hash(runtimeType, value);

  @override
  String toString() => '$runtimeType($value)';
}

final class const AnalyticsString(@override final String value) extends AnalyticsValue;

final class const AnalyticsInt(@override final int value) extends AnalyticsValue;

final class const AnalyticsDouble(@override final double value) extends AnalyticsValue;

final class const AnalyticsBool(@override final bool value) extends AnalyticsValue;
