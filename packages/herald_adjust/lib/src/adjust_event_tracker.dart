/// One call to Adjust for one event. A factory builds it.
abstract interface class AdjustEventTracker {
  Future<void> track();
}
