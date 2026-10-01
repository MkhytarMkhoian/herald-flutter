import 'package:adjust_sdk/adjust.dart';
import 'package:adjust_sdk/adjust_config.dart';
import 'package:herald/herald.dart';

/// Adjust's lifecycle, identity and consent.
///
/// [start] turns Adjust off and only then starts it with [config], so nothing is sent, not even the
/// install, until [setEnabled] turns it on. Turning it off after the start would be too late: the
/// first session would already be on its way. So let this service start Adjust; don't call
/// `Adjust.initSdk` yourself.
///
/// [start] turns Adjust off on every launch, so call [setEnabled] with the stored answer after it.
///
/// Adjust has no user id, so [identify] adds it as the global callback parameter
/// [identityParameter]. Set up a parameter with that name in the Adjust dashboard, and don't give a
/// property the same name.
final class const AdjustAnalyticsService(
  final AdjustConfig config, {
  final String identityParameter = 'user_id',
}) implements AnalyticsLifecycleService, IdentifiableUserService, ConsentService {
  @override
  Future<void> start() async {
    Adjust.disable();
    Adjust.initSdk(config);
  }

  /// Adjust has no flush API.
  @override
  Future<void> flush() async {}

  @override
  Future<void> setEnabled(bool enabled) async => enabled ? Adjust.enable() : Adjust.disable();

  @override
  Future<void> identify(Identity identity) async =>
      Adjust.addGlobalCallbackParameter(identityParameter, identity.userId);

  @override
  Future<void> reset() async => Adjust.removeGlobalCallbackParameter(identityParameter);
}
