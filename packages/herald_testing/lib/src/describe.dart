import 'package:herald/herald.dart';

/// Parameters as failures show them: sorted by key, or nothing when there are none.
String describeParameters(Map<String, AnalyticsValue> parameters) {
  if (parameters.isEmpty) return '';
  final entries = parameters.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
  return ' { ${entries.map((it) => '${it.key} = ${it.value.asString}').join(', ')} }';
}
