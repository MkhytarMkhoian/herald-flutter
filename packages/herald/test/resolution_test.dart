import 'package:herald/herald.dart';
import 'package:test/test.dart';

const _handler = 'a-handler';

/// Notes that the factory at [index] was asked, and gives its [answer].
Resolution<String> _ask(List<int> asked, int index, Resolution<String> answer) {
  asked.add(index);
  return answer;
}

void main() {
  test('claimed carries its handlers', () {
    expect(Resolution.claimed([_handler]).handlers, [_handler]);
  });

  test('claimed refuses an empty list and points to dropped', () {
    expect(
      () => Claimed<String>([]),
      throwsA(isA<ArgumentError>().having((e) => e.message, 'message', contains('Dropped'))),
    );
  });

  test('claimed keeps its own copy of the handlers', () {
    final handlers = [_handler];
    final claimed = Claimed(handlers);

    handlers.add('another');

    expect(claimed.handlers, [_handler]);
  });

  test('claimed resolutions with the same handlers are equal', () {
    expect(Claimed(['a', 'b']), Claimed(['a', 'b']));
    expect(Claimed(['a']), isNot(Claimed(['b'])));
  });

  test('dropped and declined carry no handlers', () {
    expect(const Dropped().handlers, isEmpty);
    expect(const Declined().handlers, isEmpty);
  });

  test('dropped and declined are not equal', () {
    expect(const Dropped(), isNot(const Declined()));
  });

  test('every dropped is equal, and so is every declined, const or not', () {
    // ignore: prefer_const_constructors
    expect(Dropped(), const Dropped());
    // ignore: prefer_const_constructors
    expect(Declined(), const Declined());
  });

  test('dropped and declined fit a resolution of any handler type', () {
    const Resolution<int> dropped = .dropped();
    const Resolution<int> declined = .declined();

    expect(dropped, isA<Dropped>());
    expect(declined, isA<Declined>());
  });

  group('firstOf', () {
    test("returns the first answer that isn't a decline", () {
      final answer = Resolution.firstOf<String>([
        const Declined(),
        Claimed(['first']),
        Claimed(['second']),
      ]);

      expect(answer, Claimed(['first']));
    });

    test('counts dropped as an answer', () {
      expect(Resolution.firstOf<String>([const Declined(), const Dropped()]), const Dropped());
    });

    test('declines when all decline, or there are none', () {
      expect(Resolution.firstOf<String>([const Declined()]), const Declined());
      expect(Resolution.firstOf<String>([]), const Declined());
    });

    test('stops asking once one has answered', () {
      final asked = <int>[];
      const answers = <Resolution<String>>[Declined(), Dropped(), Declined()];

      Resolution.firstOf(answers.indexed.map((it) => _ask(asked, it.$1, it.$2)));

      expect(asked, [0, 1]);
    });
  });
}
