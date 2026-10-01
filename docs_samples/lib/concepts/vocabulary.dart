import 'package:herald/herald.dart';

// --8<-- [start:no-parameters]
final class const SignInTapped() extends Event {
  @override
  String get name => 'sign_in_tapped';
}
// --8<-- [end:no-parameters]

// --8<-- [start:parameters]
final class const PlanSelected(
  final String plan, {
  required final int seats,
  required final double price,
  required final bool trial,
}) extends Event {
  @override
  String get name => 'plan_selected';

  @override
  Map<String, AnalyticsValue> get parameters => {
    'plan': .string(plan), // AnalyticsString
    'seats': .int(seats), // AnalyticsInt
    'price': .double(price), // AnalyticsDouble
    'trial': .bool(trial), // AnalyticsBool
  };
}
// --8<-- [end:parameters]

// --8<-- [start:screen-view]
final class const ProductScreenViewed(final String productId) extends ScreenViewEvent {
  @override
  String get name => 'product'; // the screen's name in GA4, Mixpanel and Amplitude

  @override
  Map<String, AnalyticsValue> get parameters => {'product_id': .string(productId)};
}
// --8<-- [end:screen-view]

// --8<-- [start:properties]
// Describes the session: a super property in Mixpanel, sent with every later event.
final class const AppTheme({required final bool dark}) extends Property {
  @override
  String get name => 'app_theme';

  @override
  AnalyticsValue get value => .string(dark ? 'dark' : 'light');
}

// Describes the person: Mixpanel's people profile, Amplitude's user properties.
final class const PurchaseCount(final int count) extends UserProperty {
  @override
  String get name => 'total_purchases';

  @override
  AnalyticsValue get value => .int(count);
}
// --8<-- [end:properties]
