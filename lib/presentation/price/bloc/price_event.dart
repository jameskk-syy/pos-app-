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

class GetProductPriceEvent extends PriceEvent {
  final String itemCode;
  final String company;
  final String? priceList;

  GetProductPriceEvent({
    required this.itemCode,
    required this.company,
    this.priceList,
  });
}

class LoadPriceListsForPriceEvent extends PriceEvent {
  final String company;
  LoadPriceListsForPriceEvent({required this.company});
}
