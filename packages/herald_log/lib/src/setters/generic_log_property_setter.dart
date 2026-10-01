import 'package:herald/herald.dart';

import '../analytics_logger.dart';
import '../log_property_setter.dart';
import '../log_record.dart';

final class const GenericLogPropertySetter(final Property property, final AnalyticsLogger logger)
    implements LogPropertySetter {
  @override
  Future<void> set() async =>
      logger(logRecord(kind: 'prop', headline: '${property.name} = ${property.value.asString}'));
}
