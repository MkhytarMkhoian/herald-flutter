import 'analytics_value.dart';

/// Something that happened in the app.
///
/// [name] identifies it and [parameters] carries its data.
///
/// ```dart
/// final class const CheckoutStarted(final String plan, final int seats) extends Event {
///   @override
///   String get name => 'checkout_started';
///
///   @override
///   Map<String, AnalyticsValue> get parameters => {'plan': .string(plan), 'seats': .int(seats)};
/// }
/// ```
abstract class Event {
  const Event();

  String get name;

  Map<String, AnalyticsValue> get parameters => const {};
}

/// A screen becoming visible. Its [name] is the screen's name.
///
/// Vendors with a screen-view event of their own send it that way. To show a different name in one
/// vendor's screen reports, put a factory for that event before the vendor's screen-view factory.
abstract class ScreenViewEvent extends Event {
  const ScreenViewEvent();
}
