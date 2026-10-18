/// One call to Meta for one event. A factory builds it.
abstract interface class MetaEventTracker {
  Future<void> track();
}
