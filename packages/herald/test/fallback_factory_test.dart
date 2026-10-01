import 'package:herald/herald.dart';
import 'package:test/test.dart';

final class const Partial() {
  @override
  String toString() => 'Partial';
}

final class const Fallback() implements FallbackFactory {
  @override
  String toString() => 'Fallback';
}

void main() {
  test('a chain with the fallback last is accepted', () {
    FallbackFactory.requireLast(const [Partial(), Partial(), Fallback()]);
  });

  test('a chain without a fallback is accepted', () {
    FallbackFactory.requireLast(const [Partial(), Partial()]);
    FallbackFactory.requireLast(const []);
  });

  test('a fallback in the middle is refused, with its name and position', () {
    expect(
      () => FallbackFactory.requireLast(const [Partial(), Fallback(), Partial()]),
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'Fallback answers for everything, so nothing placed after it is ever asked. '
              'It is factory 2 of 3; move it to the end.',
        ),
      ),
    );
  });

  test('a fallback first in a longer chain is refused', () {
    expect(
      () => FallbackFactory.requireLast(const [Fallback(), Partial()]),
      throwsA(isA<ArgumentError>().having((e) => e.message, 'message', contains('factory 1 of 2'))),
    );
  });

  test('two fallbacks are refused', () {
    expect(
      () => FallbackFactory.requireLast(const [Partial(), Fallback(), Fallback()]),
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'A chain can end in one fallback factory; this one has 2: '
              'Fallback (factory 2), Fallback (factory 3).',
        ),
      ),
    );
  });
}
