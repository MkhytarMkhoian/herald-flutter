import 'package:herald/herald.dart';
import 'package:test_api/hooks.dart' show TestFailure;

import 'analytics_record.dart';
import 'describe.dart';

/// A vendor that records calls instead of sending them, for tests.
///
/// It has all five capabilities. Register it with a real `Herald`, so the test also runs your
/// setup, or pass it straight to the class under test:
///
/// ```dart
/// final analytics = FakeAnalyticsProvider();
/// final herald = Herald(
///   providers: [HeraldProvider(name: 'test', events: analytics, properties: analytics)],
/// );
///
/// await viewModel.onPayTapped();
///
/// analytics
///   ..assertTracked('checkout_pay_tapped', (event) => event.param('plan', 'pro'))
///   ..assertNothingElseTracked();
/// ```
///
/// A failed assertion throws a [TestFailure] that lists everything recorded.
final class FakeAnalyticsProvider
    implements
        AnalyticsLifecycleService,
        EventTrackerService,
        PropertyTrackerService,
        IdentifiableUserService,
        ConsentService {
  final _recorded = <AnalyticsRecord>[];
  final _accountedFor = <int>{};

  /// Everything received, oldest first. Later calls don't change this list.
  List<AnalyticsRecord> get records => List.unmodifiable(_recorded);

  List<Event> get events => [
    for (final record in _recorded)
      if (record is TrackedRecord) record.event,
  ];

  List<Property> get properties => [
    for (final record in _recorded)
      if (record is PropertySetRecord) record.property,
  ];

  @override
  Future<void> track(Event event) async => _recorded.add(TrackedRecord(event));

  @override
  Future<void> set(Property property) async => _recorded.add(PropertySetRecord(property));

  @override
  Future<void> identify(Identity identity) async => _recorded.add(IdentifiedRecord(identity));

  @override
  Future<void> reset() async => _recorded.add(const ResetRecord());

  @override
  Future<void> start() async => _recorded.add(const StartedRecord());

  @override
  Future<void> setEnabled(bool enabled) async => _recorded.add(EnabledSetRecord(enabled));

  @override
  Future<void> flush() async => _recorded.add(const FlushedRecord());

  /// Forgets everything, including which events were already asserted on.
  void clear() {
    _recorded.clear();
    _accountedFor.clear();
  }

  /// Asserts that exactly one event called [name] was tracked, then runs [assertions] on it.
  ///
  /// Exactly one, so a duplicated event fails instead of passing. Use [assertTrackedTimes] when
  /// repeats are expected.
  ///
  /// ```dart
  /// analytics.assertTracked('checkout_started', (event) => event
  ///   ..param('plan', 'pro')
  ///   ..param('seats', 3));
  /// ```
  void assertTracked(String name, [void Function(TrackedEventAssert event)? assertions]) {
    final matches = _trackedIndicesOf(name);
    switch (matches) {
      case []:
        _fail("Expected an event named '$name', but it was never tracked.");
      case [final index]:
        _accountedFor.add(index);
        final event = (_recorded[index] as TrackedRecord).event;
        assertions?.call(TrackedEventAssert._(name, event, _fail));
      default:
        _fail(
          "Expected one event named '$name', but ${matches.length} were tracked. "
          "Use assertTrackedTimes('$name', ${matches.length}) if that is intended.",
        );
    }
  }

  void assertTrackedTimes(String name, int times) {
    final matches = _trackedIndicesOf(name);
    if (matches.length != times) {
      _fail(
        "Expected '$name' to be tracked $times times, but it was tracked ${matches.length} times.",
      );
    }
    _accountedFor.addAll(matches);
  }

  void assertNotTracked(String name) {
    if (_trackedIndicesOf(name).isNotEmpty) _fail("Expected '$name' never to be tracked.");
  }

  void assertNothingTracked() {
    final tracked = events;
    if (tracked.isNotEmpty) _fail('Expected no events, but ${tracked.length} were tracked.');
  }

  /// Asserts that every tracked event was already checked by an earlier assertion, so an
  /// unexpected event, such as a duplicate, doesn't go unnoticed.
  void assertNothingElseTracked() {
    final unexpected = [
      for (final (index, record) in _recorded.indexed)
        if (record is TrackedRecord && !_accountedFor.contains(index)) record.event.name,
    ];
    if (unexpected.isNotEmpty) _fail('Unexpected events tracked: ${unexpected.join(', ')}.');
  }

  /// Asserts that the property [name] currently has [value], meaning the last value it was set
  /// to. If it had the right value and was then overwritten, this fails and shows every value.
  ///
  /// [value] is an [AnalyticsValue], or a [String], [int], [double] or [bool]. It's compared by
  /// type too, so `assertPropertySet('seats', 3)` fails against the text `'3'`.
  void assertPropertySet(String name, Object value) {
    final expected = value is AnalyticsValue ? value : AnalyticsValue.of(value);
    final history = [
      for (final property in properties)
        if (property.name == name) property.value,
    ];
    if (history.isEmpty) _fail("Expected property '$name' to be set, but it never was.");
    if (history.last != expected) {
      _fail(
        "Expected property '$name' to be $expected, but it was set to ${history.join(' then ')}.",
      );
    }
  }

  /// Asserts that the user was identified as [userId] at some point, even if `reset` came later.
  /// Use [records] to check the order.
  void assertIdentified(String userId) {
    final identified = _recorded.whereType<IdentifiedRecord>();
    if (!identified.any((record) => record.identity.userId == userId)) {
      _fail("Expected the user to be identified as '$userId'.");
    }
  }

  List<int> _trackedIndicesOf(String name) => [
    for (final (index, record) in _recorded.indexed)
      if (record is TrackedRecord && record.event.name == name) index,
  ];

  Never _fail(String message) {
    final timeline = _recorded.isEmpty
        ? '  (nothing was recorded)'
        : [for (final (index, record) in _recorded.indexed) '  ${index + 1}. $record'].join('\n');
    throw TestFailure('$message\n\nRecorded:\n$timeline');
  }
}

/// Checks on one tracked event, given to the callback of
/// [FakeAnalyticsProvider.assertTracked].
final class TrackedEventAssert._(
  final String _name,

  /// The event, for checks the methods here don't cover.
  final Event event,
  final Never Function(String message) _fail,
) {
  /// Asserts that the event has the parameter [key] with [value].
  ///
  /// [value] is an [AnalyticsValue], or a [String], [int], [double] or [bool]. It's compared by
  /// type too, so `param('seats', 3)` fails against the text `'3'`. On the web a whole `double` is
  /// an `int`, so pass an [AnalyticsDouble] there.
  void param(String key, Object value) {
    final expected = value is AnalyticsValue ? value : AnalyticsValue.of(value);
    final actual = event.parameters[key];
    if (actual == null) {
      _fail("Event '$_name' has no parameter '$key'${describeParameters(event.parameters)}.");
    }
    if (actual != expected) {
      _fail("Event '$_name' parameter '$key' was $actual, expected $expected.");
    }
  }

  void noParameters() {
    if (event.parameters.isNotEmpty) {
      _fail(
        "Expected '$_name' to carry no parameters, "
        'but it carried${describeParameters(event.parameters)}.',
      );
    }
  }
}
