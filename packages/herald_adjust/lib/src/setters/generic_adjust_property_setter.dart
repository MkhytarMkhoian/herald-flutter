import 'package:adjust_sdk/adjust.dart';
import 'package:herald/herald.dart';

import '../adjust_property_setter.dart';

/// Adds [property] as a global callback parameter, as text, so Adjust attaches it to every later
/// event.
///
/// `AdjustAnalyticsService` keeps the user id in the same place, so a property named like its
/// identity parameter overwrites the user id.
final class const GenericAdjustPropertySetter(final Property property)
    implements AdjustPropertySetter {
  @override
  Future<void> set() async =>
      Adjust.addGlobalCallbackParameter(property.name, property.value.asString);
}
