import 'package:herald/herald.dart';

final class const TestEvent(
  @override final String name, [
  @override final Map<String, AnalyticsValue> parameters = const {},
]) extends Event;

final class const TestProperty(@override final String name, @override final AnalyticsValue value)
    extends Property;
