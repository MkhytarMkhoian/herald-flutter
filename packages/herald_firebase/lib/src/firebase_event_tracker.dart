/// One call to Firebase for one event. A factory builds it.
abstract interface class FirebaseEventTracker {
  Future<void> track();
}
