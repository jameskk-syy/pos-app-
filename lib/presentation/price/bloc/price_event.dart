import 'package:flutter/foundation.dart';

@immutable
sealed class PriceEvent {}

class SetProductPriceEvent extends PriceEvent {
  final String itemCode;
  final double price;
  final String priceList;
  final String currency;

  SetProductPriceEvent({
    required this.itemCode,
    required this.price,
    required this.priceList,
    required this.currency,
  });
}
