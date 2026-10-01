/// A factory that answers for everything, so it must be last in a chain: the generic factories,
/// which send everything, and the `RequireMapped` ones, which throw.
abstract interface class FallbackFactory {
  /// Throws if [factories] has more than one [FallbackFactory], or one that isn't last.
  ///
  /// Composite factories call it when they're built, so a wrong chain fails at start-up.
  static void requireLast(List<Object> factories) {
    final fallbacks = [
      for (final (index, factory) in factories.indexed)
        if (factory is FallbackFactory) (number: index + 1, factory: factory),
    ];
    if (fallbacks.length > 1) {
      throw ArgumentError(
        'A chain can end in one fallback factory; this one has ${fallbacks.length}: '
        '${fallbacks.map((it) => '${it.factory} (factory ${it.number})').join(', ')}.',
      );
    }
    if (fallbacks.isEmpty) return;
    final (:number, :factory) = fallbacks.single;
    if (number != factories.length) {
      throw ArgumentError(
        '$factory answers for everything, so nothing placed after it is ever asked. '
        'It is factory $number of ${factories.length}; move it to the end.',
      );
    }
  }
}
