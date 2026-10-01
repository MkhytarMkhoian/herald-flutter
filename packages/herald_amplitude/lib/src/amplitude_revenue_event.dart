import 'package:amplitude_flutter/events/revenue.dart';
import 'package:herald/herald.dart';

import 'amplitude_values.dart';

/// A purchase, in the fields Amplitude's revenue API takes.
///
/// Your events don't extend it: your Amplitude factory builds one from your event and sends it with
/// `RevenueAmplitudeEventTracker`.
final class const AmplitudeRevenueEvent({
  /// Not sent. Only used in failure reports.
  @override required final String name,

  /// Price of one item. Amplitude drops revenue without it.
  required final double price,
  final int quantity = 1,
  final String? productId,
  final String? revenueType,

  /// Without one, Amplitude assumes USD.
  final String? currency,

  /// The total, when it isn't [price] times [quantity].
  final double? revenue,
  final String? receipt,
  final String? receiptSig,

  /// Makes a purchase sent twice count once.
  final String? insertId,
  @override final Map<String, AnalyticsValue> parameters = const {},
}) extends Event {
  /// This purchase as Amplitude's [Revenue]. [insertId] isn't in it: the tracker sends it as an
  /// event option.
  Revenue toAmplitudeRevenue() => Revenue()
    ..price = price
    ..quantity = quantity
    ..productId = productId
    ..revenueType = revenueType
    ..revenueCurrency = currency
    ..revenue = revenue
    ..receipt = receipt
    ..receiptSig = receiptSig
    ..properties = parameters.toAmplitudeProperties();

  @override
  bool operator ==(Object other) =>
      other is AmplitudeRevenueEvent &&
      other._fields == _fields &&
      _sameParameters(other.parameters, parameters);

  @override
  int get hashCode => Object.hash(_fields, _hashParameters(parameters));

  (String, double, int, String?, String?, String?, double?, String?, String?, String?)
  get _fields => (
    name,
    price,
    quantity,
    productId,
    revenueType,
    currency,
    revenue,
    receipt,
    receiptSig,
    insertId,
  );

  @override
  String toString() => 'AmplitudeRevenueEvent($name, price: $price, quantity: $quantity)';
}

bool _sameParameters(Map<String, AnalyticsValue> a, Map<String, AnalyticsValue> b) =>
    a.length == b.length && a.entries.every((entry) => b[entry.key] == entry.value);

int _hashParameters(Map<String, AnalyticsValue> parameters) =>
    Object.hashAllUnordered(parameters.entries.map((it) => Object.hash(it.key, it.value)));
