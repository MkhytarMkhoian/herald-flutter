import 'package:herald/herald.dart';
import 'package:herald_log/herald_log.dart';
import 'package:test/test.dart';

import 'support.dart';

void main() {
  late List<String> printed;

  setUp(() => printed = []);

  test('an event prints with its parameters, as one record', () async {
    await GenericLogEventTracker(
      const TestEvent('checkout_started', {
        'plan': .string('pro'),
        'seats': .int(3),
        'price': .double(9.99),
        'trial': .bool(false),
      }),
      printed.add,
    ).track();

    expect(printed, [
      [
        '[herald] event   checkout_started',
        '    ├─ plan  = pro',
        '    ├─ price = 9.99',
        '    ├─ seats = 3',
        '    └─ trial = false',
      ].join('\n'),
    ]);
  });

  test('keys are sorted, so the same event always prints the same way', () async {
    await GenericLogEventTracker(
      const TestEvent('e', {'zulu': .string('z'), 'alpha': .string('a')}),
      printed.add,
    ).track();

    expect(printed, ['[herald] event   e\n    ├─ alpha = a\n    └─ zulu  = z']);
  });

  test('a single parameter is closed, not branched', () async {
    await GenericLogEventTracker(const TestEvent('e', {'only': .int(1)}), printed.add).track();

    expect(printed, ['[herald] event   e\n    └─ only = 1']);
  });

  test('a screen view prints its name, with its parameters', () async {
    await ScreenViewLogEventTracker(
      const TestScreenView('checkout', {'source': .string('cart')}),
      printed.add,
    ).track();

    expect(printed, ['[herald] screen  checkout\n    └─ source = cart']);
  });

  test('a property prints as name = value', () async {
    await GenericLogPropertySetter(const TestProperty('seats', AnalyticsInt(2)), printed.add).set();

    expect(printed, ['[herald] prop    seats = 2']);
  });

  test('kinds are padded so headlines line up', () async {
    await GenericLogEventTracker(const TestEvent('x'), printed.add).track();
    await ScreenViewLogEventTracker(const TestScreenView('x'), printed.add).track();
    await GenericLogPropertySetter(const TestProperty('x', AnalyticsInt(1)), printed.add).set();
    await LogAnalyticsService(printed.add).identify(const Identity('x'));
    await LogAnalyticsService(printed.add).setEnabled(true);

    // '[herald] ' and a 7-wide kind with a space after it: every headline starts at column 17.
    expect(printed.map((line) => line.substring(17)), ['x', 'x', 'x = 1', 'x', 'true']);
  });
}
