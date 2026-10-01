/// Which call failed: tracking an event, setting a property, and so on.
///
/// Holds names only, never values, so no personal data reaches the error reporter.
sealed class AnalyticsOperation {
  const AnalyticsOperation();

  /// What the call was about: an event or property name, or the enabled flag.
  Object? get _subject => null;

  @override
  bool operator ==(Object other) =>
      other is AnalyticsOperation && other.runtimeType == runtimeType && other._subject == _subject;

  @override
  int get hashCode => Object.hash(runtimeType, _subject);
}

// Each operation spells out its own toString: these strings reach crash reports from release
// builds, where `--obfuscate` would scramble a class name.

final class const TrackOperation(final String eventName) extends AnalyticsOperation {
  @override
  Object get _subject => eventName;

  @override
  String toString() => 'Track($eventName)';
}

final class const SetPropertyOperation(final String propertyName) extends AnalyticsOperation {
  @override
  Object get _subject => propertyName;

  @override
  String toString() => 'SetProperty($propertyName)';
}

final class const SetEnabledOperation(final bool enabled) extends AnalyticsOperation {
  @override
  Object get _subject => enabled;

  @override
  String toString() => 'SetEnabled($enabled)';
}

final class const IdentifyOperation() extends AnalyticsOperation {
  @override
  String toString() => 'Identify';
}

final class const ResetOperation() extends AnalyticsOperation {
  @override
  String toString() => 'Reset';
}

final class const StartOperation() extends AnalyticsOperation {
  @override
  String toString() => 'Start';
}

final class const FlushOperation() extends AnalyticsOperation {
  @override
  String toString() => 'Flush';
}
