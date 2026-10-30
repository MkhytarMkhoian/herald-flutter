import 'package:flutter_test/flutter_test.dart';
import 'package:herald_docs_samples/guides/modular_apps.dart';

// --8<-- [start:fake]
// The feature's test fakes its own interface: no Herald, no vendors.
final class FakeCheckoutAnalytics implements CheckoutAnalytics {
  final checkouts = <(String, int)>[];
  final failedPayments = <String>[];

  @override
  Future<void> checkoutStarted(String plan, int seats) async {
    checkouts.add((plan, seats));
  }

  @override
  Future<void> paymentFailed(String reason) async {
    failedPayments.add(reason);
  }
}

void main() {
  test('a failed payment reports its reason', () async {
    final analytics = FakeCheckoutAnalytics();

    await PaymentViewModel(analytics).onPaymentFailed('card_declined');

    expect(analytics.failedPayments, ['card_declined']);
    expect(analytics.checkouts, isEmpty);
  });
}
// --8<-- [end:fake]
