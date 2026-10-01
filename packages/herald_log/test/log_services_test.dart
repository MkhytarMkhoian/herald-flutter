import 'package:herald/herald.dart';
import 'package:herald_log/herald_log.dart';
import 'package:test/test.dart';

import 'support.dart';

/// The usual setup: screen views, then every other event, and every property.
LogAnalyticsTrackerService _tracker(AnalyticsLogger logger) => LogAnalyticsTrackerService(
  eventTrackerFactory: CompositeLogEventTrackerFactory([
    ScreenViewLogEventTrackerFactory(logger),
    GenericLogEventTrackerFactory(logger),
  ]),
  propertySetterFactory: CompositeLogPropertySetterFactory([
    GenericLogPropertySetterFactory(logger),
  ]),
);

void main() {
  late List<String> printed;

  setUp(() => printed = []);

  test('lifecycle, identity and consent calls each print one line, in order', () async {
    final service = LogAnalyticsService(printed.add);

    await service.start();
    await service.setEnabled(true);
    await service.identify(const Identity('user-1'));
    await service.flush();
    await service.reset();
    await service.setEnabled(false);

    expect(printed, [
      '[herald] start',
      '[herald] enabled true',
      '[herald] user    user-1',
      '[herald] flush',
      '[herald] reset',
      '[herald] enabled false',
    ]);
  });

  test('the tracker service prints what its chains decide, through Herald', () async {
    final tracker = _tracker(printed.add);
    final herald = Herald(
      providers: [HeraldProvider(name: 'log', events: tracker, properties: tracker)],
    );

    await herald.track(const TestScreenView('home'));
    await herald.set(const TestProperty('plan', AnalyticsString('pro')));

    expect(printed, ['[herald] screen  home', '[herald] prop    plan = pro']);
  });

  test('an unclaimed event or property is ignored by a chain without a fallback', () async {
    final tracker = LogAnalyticsTrackerService(
      eventTrackerFactory: CompositeLogEventTrackerFactory([
        ScreenViewLogEventTrackerFactory(printed.add),
      ]),
      propertySetterFactory: CompositeLogPropertySetterFactory([]),
    );

    await tracker.track(const TestEvent('ignored'));
    await tracker.set(const TestProperty('ignored', AnalyticsInt(1)));

    expect(printed, isEmpty);
  });

  test('the handlers of one event run in order, and a failure stops the rest', () async {
    final tracker = LogAnalyticsTrackerService(
      eventTrackerFactory: ClaimingLogEventTrackerFactory('e', [
        MessageLogEventTracker(printed.add, 'first'),
        const ThrowingLogEventTracker(),
        MessageLogEventTracker(printed.add, 'third'),
      ]),
      propertySetterFactory: CompositeLogPropertySetterFactory([]),
    );

    await expectLater(tracker.track(const TestEvent('e')), throwsStateError);
    expect(printed, ['first']);
  });
}
