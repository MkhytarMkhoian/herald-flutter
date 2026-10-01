import 'package:herald/herald.dart';
import 'package:test/test.dart';

void main() {
  test('identities are equal by user id', () {
    expect(const Identity('u'), const Identity('u'));
    expect(const Identity('u'), isNot(const Identity('v')));
  });

  test('an identity hides its user id when printed', () {
    const identity = Identity('user-42');

    expect('$identity', isNot(contains('user-42')));
    expect(identity.userId, 'user-42');
  });
}
