/// One call to Firebase for one property. A factory builds it.
abstract interface class FirebasePropertySetter {
  Future<void> set();
}
