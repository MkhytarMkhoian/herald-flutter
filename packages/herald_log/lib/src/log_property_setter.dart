/// One call to the log for one property. A factory builds it.
abstract interface class LogPropertySetter {
  Future<void> set();
}
