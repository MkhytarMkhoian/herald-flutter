/// One call to Amplitude for one event. A factory builds it.
abstract interface class AmplitudeEventTracker {
  Future<void> track();
}
