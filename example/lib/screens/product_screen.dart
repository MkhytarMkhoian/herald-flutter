import 'package:flutter/material.dart';
import 'package:herald/herald.dart';

import '../analytics/events.dart';

/// A product. The screen tracks its own events and doesn't know which vendors get them.
class const ProductScreen({
  required final String productId,
  required final EventTrackerService analytics,
  required final PropertyTrackerService properties,
  super.key,
}) extends StatefulWidget {
  static const route = '/product';

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  static const _price = 4.99;
  var _inCart = 0;
  var _purchases = 0;

  Future<void> _addToCart() async {
    setState(() => _inCart++);
    await widget.analytics.track(AddedToCart(widget.productId, _price));
  }

  Future<void> _buy() async {
    final items = _inCart;
    setState(() {
      _inCart = 0;
      _purchases++;
    });
    await widget.properties.set(PurchaseCount(_purchases));
    await widget.analytics.track(OrderPaid(items, items * _price));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.productId)),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('\$$_price', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          FilledButton(onPressed: _addToCart, child: const Text('Add to cart')),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: _inCart == 0 ? null : _buy, child: Text('Buy $_inCart')),
        ],
      ),
    ),
  );
}
