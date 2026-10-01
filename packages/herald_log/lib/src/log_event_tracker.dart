/// One call to the log for one event. A factory builds it.
abstract interface class LogEventTracker {
  Future<void> track();
}
