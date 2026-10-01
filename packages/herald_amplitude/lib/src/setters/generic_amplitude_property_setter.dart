import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/events/identify.dart';
import 'package:herald/herald.dart';

import '../amplitude_property_setter.dart';
import '../amplitude_values.dart';

final class const GenericAmplitudePropertySetter(final Property property, final Amplitude amplitude)
    implements AmplitudePropertySetter {
  @override
  Future<void> set() =>
      amplitude.identify(Identify()..set(property.name, property.value.asAmplitudeValue));
}
