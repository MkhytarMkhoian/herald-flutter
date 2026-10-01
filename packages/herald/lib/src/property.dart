import 'analytics_value.dart';

/// A lasting attribute, such as the user's plan, that vendors attach to later events.
///
/// The value keeps its type. Vendors that take only text use [AnalyticsValue.asString].
abstract class Property {
  const Property();

  String get name;

  AnalyticsValue get value;
}

/// A property about the person, not the session. Vendors with a user profile store it there.
abstract class UserProperty extends Property {
  const UserProperty();
}
