import 'package:herald/herald.dart';

/// The app's events. Screens track these and never name a vendor.

final class const HomeViewed() extends ScreenViewEvent {
  @override
  String get name => 'home';
}

final class const ProductViewed(final String productId) extends ScreenViewEvent {
  @override
  String get name => 'product';

  @override
  Map<String, AnalyticsValue> get parameters => {'product_id': .string(productId)};
}

final class const SettingsViewed() extends ScreenViewEvent {
  @override
  String get name => 'settings';
}

final class const AddedToCart(final String productId, final double price) extends Event {
  @override
  String get name => 'added_to_cart';

  @override
  Map<String, AnalyticsValue> get parameters => {
    'product_id': .string(productId),
    'price': .double(price), // stays a number all the way to the vendor
  };
}

final class const OrderPaid(final int items, final double total) extends Event {
  @override
  String get name => 'order_paid';

  @override
  Map<String, AnalyticsValue> get parameters => {'items': .int(items), 'total': .double(total)};
}

/// About the session.
final class const AppTheme({required final bool dark}) extends Property {
  @override
  String get name => 'app_theme';

  @override
  AnalyticsValue get value => .string(dark ? 'dark' : 'light');
}

/// About the person.
final class const PurchaseCount(final int count) extends UserProperty {
  @override
  String get name => 'total_purchases';

  @override
  AnalyticsValue get value => .int(count);
}
