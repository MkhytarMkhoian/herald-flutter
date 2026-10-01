/// Starts a vendor and sends what it has buffered.
abstract interface class AnalyticsLifecycleService {
  /// Starts the vendor SDK. Call it once, when the app starts.
  Future<void> start();

  /// Asks the vendor to send what it has buffered. Useful when consent is revoked or the app goes
  /// to the background.
  Future<void> flush();
}
