/// One call to AppsFlyer for one event. A factory builds it.
abstract interface class AppsFlyerEventTracker {
  Future<void> track();
}
