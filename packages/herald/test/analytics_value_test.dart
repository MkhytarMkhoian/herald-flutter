import 'package:herald/herald.dart';
import 'package:test/test.dart';

final class const _Bare() extends Event {
  @override
  String get name => 'an_event';
}

void main() {
  test('asString is the value as text', () {
    expect(const AnalyticsString('pro').asString, 'pro');
    expect(const AnalyticsInt(3).asString, '3');
    expect(const AnalyticsDouble(9.99).asString, '9.99');
    expect(const AnalyticsBool(true).asString, 'true');
  });

  test('the named constructors build each type', () {
    const Map<String, AnalyticsValue> parameters = {
      'plan': .string('pro'),
      'seats': .int(3),
      'price': .double(9.99),
      'trial': .bool(false),
    };

    expect(parameters, {
      'plan': const AnalyticsString('pro'),
      'seats': const AnalyticsInt(3),
      'price': const AnalyticsDouble(9.99),
      'trial': const AnalyticsBool(false),
    });
  });

  test('values are equal by type and value, so 3 is not "3"', () {
    expect(const AnalyticsInt(3), const AnalyticsInt(3));
    expect(const AnalyticsInt(3).hashCode, const AnalyticsInt(3).hashCode);
    expect(const AnalyticsInt(3), isNot(const AnalyticsString('3')));
    expect(const AnalyticsDouble(3), isNot(const AnalyticsInt(3)));
    expect(const AnalyticsBool(true), isNot(const AnalyticsString('true')));
  });

  test('values print their type and value', () {
    expect(const AnalyticsInt(3).toString(), 'AnalyticsInt(3)');
    expect(const AnalyticsString('pro').toString(), 'AnalyticsString(pro)');
  });

  test('of wraps by runtime type and refuses anything else', () {
    expect(AnalyticsValue.of('pro'), const AnalyticsString('pro'));
    expect(AnalyticsValue.of(3), const AnalyticsInt(3));
    expect(AnalyticsValue.of(9.99), const AnalyticsDouble(9.99));
    expect(AnalyticsValue.of(true), const AnalyticsBool(true));
    expect(() => AnalyticsValue.of(const <int>[]), throwsArgumentError);
  });

  test('value is the wrapped value', () {
    expect(const AnalyticsInt(3).value, 3);
    expect(const AnalyticsString('pro').value, 'pro');
  });

  test('an event without parameters has none', () {
    expect(const _Bare().parameters, isEmpty);
  });
}
