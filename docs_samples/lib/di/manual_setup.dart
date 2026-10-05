import 'package:herald/herald.dart';

import '../quick_start.dart';

// --8<-- [start:manual]
final class const AppGraph(final Herald herald) {
  // CheckoutViewModel asks for an EventTrackerService; Herald is one, so it is passed as that.
  CheckoutViewModel checkoutViewModel() => CheckoutViewModel(herald);
}
// --8<-- [end:manual]
