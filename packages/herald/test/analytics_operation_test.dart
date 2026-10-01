import 'package:herald/herald.dart';
import 'package:test/test.dart';

void main() {
  test('operations are equal by kind and name', () {
    expect(const TrackOperation('a'), const TrackOperation('a'));
    expect(const TrackOperation('a'), isNot(const TrackOperation('b')));
    expect(const SetEnabledOperation(true), isNot(const SetEnabledOperation(false)));
  });

  test('operations of different kinds are not equal, even with the same name', () {
    expect(const TrackOperation('plan'), isNot(const SetPropertyOperation('plan')));
    expect(const StartOperation(), isNot(const FlushOperation()));
  });

  test('operations without fields are equal by kind, const or not', () {
    // ignore: prefer_const_constructors
    expect(IdentifyOperation(), const IdentifyOperation());
    // ignore: prefer_const_constructors
    expect(ResetOperation(), const ResetOperation());
    // ignore: prefer_const_constructors
    expect(StartOperation(), const StartOperation());
    // ignore: prefer_const_constructors
    expect(FlushOperation(), const FlushOperation());
  });

  test('operations print their kind and name', () {
    expect(const TrackOperation('checkout').toString(), 'Track(checkout)');
    expect(const SetPropertyOperation('plan').toString(), 'SetProperty(plan)');
    expect(const SetEnabledOperation(false).toString(), 'SetEnabled(false)');
    expect(const IdentifyOperation().toString(), 'Identify');
  });
}
