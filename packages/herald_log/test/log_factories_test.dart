import 'package:herald/herald.dart';
import 'package:herald_log/herald_log.dart';
import 'package:test/test.dart';

import 'support.dart';

const _event = TestEvent('an_event');
const _screenView = TestScreenView('checkout');
const _property = TestProperty('plan', AnalyticsString('pro'));

void main() {
  late List<String> printed;

  setUp(() => printed = []);

  test('the screen-view factory claims screen views and declines the rest', () {
    final factory = ScreenViewLogEventTrackerFactory(printed.add);

    expect(factory.create(_screenView).handlers.single, isA<ScreenViewLogEventTracker>());
    expect(factory.create(_event), const Declined());
  });

  test('the generic factories claim everything', () {
    expect(
      GenericLogEventTrackerFactory(printed.add).create(_screenView).handlers.single,
      isA<GenericLogEventTracker>(),
    );
    expect(
      GenericLogPropertySetterFactory(printed.add).create(_property).handlers.single,
      isA<GenericLogPropertySetter>(),
    );
  });

  test('the require-mapped factories fail for anything that reaches them', () {
    expect(
      () => const RequireMappedLogEventTrackerFactory().create(_event),
      throwsA(isA<UnhandledEventException>()),
    );
    expect(
      () => const RequireMappedLogPropertySetterFactory().create(_property),
      throwsA(isA<UnhandledPropertyException>()),
    );
  });

  test('a chain takes the first factory that does not decline', () {
    final chain = CompositeLogEventTrackerFactory([
      ScreenViewLogEventTrackerFactory(printed.add),
      GenericLogEventTrackerFactory(printed.add),
    ]);

    expect(chain.create(_screenView).handlers.single, isA<ScreenViewLogEventTracker>());
    expect(chain.create(_event).handlers.single, isA<GenericLogEventTracker>());
  });

  test('a chain with its fallback anywhere but last is refused', () {
    expect(
      () => CompositeLogEventTrackerFactory([
        GenericLogEventTrackerFactory(printed.add),
        ScreenViewLogEventTrackerFactory(printed.add),
      ]),
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('GenericLogEventTrackerFactory answers for everything'),
        ),
      ),
    );
  });

  test('a custom factory placed first takes its event from the generic one', () async {
    final chain = CompositeLogEventTrackerFactory([
      ClaimingLogEventTrackerFactory('an_event', [MessageLogEventTracker(printed.add, 'custom')]),
      GenericLogEventTrackerFactory(printed.add),
    ]);

    await chain.create(_event).handlers.single.track();

    expect(printed, ['custom']);
    expect(chain.create(_screenView).handlers.single, isA<GenericLogEventTracker>());
  });
}
