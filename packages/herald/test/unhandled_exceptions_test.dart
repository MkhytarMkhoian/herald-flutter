import 'package:herald/herald.dart';
import 'package:test/test.dart';

import 'support.dart';

void main() {
  test('an unhandled event names the event and its type', () {
    expect(
      const UnhandledEventException(TestEvent('checkout')).toString(),
      contains("No factory claimed event 'checkout' (TestEvent)"),
    );
  });

  test('an unhandled property names the property and its type', () {
    expect(
      const UnhandledPropertyException(TestProperty('plan', AnalyticsString('pro'))).toString(),
      contains("No factory claimed property 'plan' (TestProperty)"),
    );
  });
}
