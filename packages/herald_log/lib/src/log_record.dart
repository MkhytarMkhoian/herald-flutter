import 'package:herald/herald.dart';

/// Starts every record, so Herald's lines are easy to filter.
const logTag = '[herald]';

/// Length of the longest kind, `enabled`, so headlines line up.
const _kindWidth = 7;

/// Renders one record as one string: a header line, then a branch per parameter with the last one
/// closed by `└─`, values aligned on the longest key.
///
/// One string, and one log call, so a record cannot be split by another one.
///
/// A record with no headline — `reset`, `start`, `flush` — is the bare kind, with no padding to
/// trail the line.
String logRecord({
  required String kind,
  required String headline,
  Map<String, AnalyticsValue> parameters = const {},
}) {
  final record = StringBuffer('$logTag ');
  record.write(headline.isEmpty ? kind : '${kind.padRight(_kindWidth)} $headline');
  if (parameters.isEmpty) return record.toString();

  final keys = parameters.keys.toList()..sort();
  final keyWidth = keys.map((key) => key.length).reduce((a, b) => a > b ? a : b);
  for (final (index, key) in keys.indexed) {
    final branch = index == keys.length - 1 ? '└─' : '├─';
    record.write('\n    $branch ${key.padRight(keyWidth)} = ${parameters[key]!.asString}');
  }
  return record.toString();
}
