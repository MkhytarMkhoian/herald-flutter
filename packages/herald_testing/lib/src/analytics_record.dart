import 'package:herald/herald.dart';

import 'describe.dart';

/// One call the fake received.
///
/// All calls go into one list, in order, so a test can check the order across kinds, such as a
/// property set before the event that should carry it. A record prints as the line a failure shows.
sealed class AnalyticsRecord {
  const AnalyticsRecord();

  /// What the call carried: the event, property, identity or flag.
  Object? get _subject => null;

  @override
  bool operator ==(Object other) =>
      other is AnalyticsRecord && other.runtimeType == runtimeType && other._subject == _subject;

  @override
  int get hashCode => Object.hash(runtimeType, _subject);
}

final class const TrackedRecord(final Event event) extends AnalyticsRecord {
  @override
  Object get _subject => event;

  @override
  String toString() => 'event    ${event.name}${describeParameters(event.parameters)}';
}

final class const PropertySetRecord(final Property property) extends AnalyticsRecord {
  @override
  Object get _subject => property;

  @override
  String toString() => 'property ${property.name} = ${property.value.asString}';
}

final class const IdentifiedRecord(final Identity identity) extends AnalyticsRecord {
  @override
  Object get _subject => identity;

  @override
  String toString() => 'identify ${identity.userId}';
}

final class const EnabledSetRecord(final bool enabled) extends AnalyticsRecord {
  @override
  Object get _subject => enabled;

  @override
  String toString() => 'enabled  $enabled';
}

final class const ResetRecord() extends AnalyticsRecord {
  @override
  String toString() => 'reset';
}

final class const StartedRecord() extends AnalyticsRecord {
  @override
  String toString() => 'start';
}

final class const FlushedRecord() extends AnalyticsRecord {
  @override
  String toString() => 'flush';
}
