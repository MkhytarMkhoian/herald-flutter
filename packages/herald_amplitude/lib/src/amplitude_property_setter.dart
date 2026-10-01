/// One call to Amplitude for one property. A factory builds it.
abstract interface class AmplitudePropertySetter {
  Future<void> set();
}
