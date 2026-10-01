/// One call to Mixpanel for one property. A factory builds it.
abstract interface class MixpanelPropertySetter {
  Future<void> set();
}
