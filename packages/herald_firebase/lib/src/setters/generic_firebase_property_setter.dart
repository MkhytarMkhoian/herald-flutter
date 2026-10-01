import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:herald/herald.dart';

import '../firebase_property_setter.dart';

/// Sets [property] as a Firebase user property. Firebase user properties are text only, so the
/// value is written in its string form.
final class const GenericFirebasePropertySetter(
  final Property property,
  final FirebaseAnalytics analytics,
) implements FirebasePropertySetter {
  @override
  Future<void> set() =>
      analytics.setUserProperty(name: property.name, value: property.value.asString);
}
