/// A factory's answer for one event or property:
///
/// - [Claimed]: mine, send it with these handlers.
/// - [Dropped]: mine, send nothing. Later factories aren't asked.
/// - [Declined]: not mine, ask the next factory.
///
/// ```dart
/// @override
/// Resolution<VendorEventTracker> create(Event event) => switch (event) {
///   CheckoutStarted() => .claimed([CheckoutTracker(event)]),
///   DebugPing() => .dropped(),
///   _ => .declined(),
/// };
/// ```
sealed class Resolution<T> {
  const Resolution();

  /// Throws if [handlers] is empty. Use [Resolution.dropped] to send nothing.
  factory Resolution.claimed(List<T> handlers) = Claimed<T>;

  const factory Resolution.dropped() = Dropped;

  const factory Resolution.declined() = Declined;

  /// The first answer that isn't [Declined], or [Declined] if all decline. Composite factories use
  /// it to run their chain.
  ///
  /// [resolutions] is read lazily, so with `factories.map((factory) => factory.create(event))` the
  /// factories after the one that answers aren't asked.
  static Resolution<R> firstOf<R>(Iterable<Resolution<R>> resolutions) {
    for (final resolution in resolutions) {
      if (resolution is! Declined) return resolution;
    }
    return const Declined();
  }

  /// The handlers to run. Empty for [Dropped] and [Declined].
  List<T> get handlers => const <Never>[];

  @override
  bool operator ==(Object other) {
    if (other is! Resolution || other.runtimeType != runtimeType) return false;
    if (other.handlers.length != handlers.length) return false;
    for (var i = 0; i < handlers.length; i++) {
      if (other.handlers[i] != handlers[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(runtimeType, Object.hashAll(handlers));

  @override
  String toString() => handlers.isEmpty ? '$runtimeType' : '$runtimeType($handlers)';
}

final class Claimed<T>(List<T> handlers) extends Resolution<T> {
  /// Throws if [handlers] is empty. Use [Dropped] to send nothing.
  this {
    if (handlers.isEmpty) {
      throw ArgumentError.value(
        handlers,
        'handlers',
        'Claimed needs at least one handler. Use Dropped to claim something and send nothing',
      );
    }
  }

  @override
  final List<T> handlers = List.unmodifiable(handlers);
}

final class const Dropped() extends Resolution<Never>;

final class const Declined() extends Resolution<Never>;
