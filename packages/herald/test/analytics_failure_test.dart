import 'package:herald/herald.dart';
import 'package:test/test.dart';

void main() {
  test('a failure reads as one line with the vendor, the call and the error', () {
    final failure = AnalyticsFailure(
      'analytics',
      const TrackOperation('checkout_started'),
      StateError('down'),
      StackTrace.empty,
    );

    expect('$failure', 'analytics failed on Track(checkout_started): Bad state: down');
  });
}
