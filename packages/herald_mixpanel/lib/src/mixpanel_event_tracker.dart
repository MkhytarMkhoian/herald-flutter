/// One call to Mixpanel for one event. A factory builds it.
abstract interface class MixpanelEventTracker {
  Future<void> track();
}
