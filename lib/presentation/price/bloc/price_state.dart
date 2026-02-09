import 'package:flutter/foundation.dart';
import 'package:pos/domain/responses/products/product_price_response.dart';
import 'package:pos/domain/responses/price_list_response.dart';

@immutable
sealed class PriceState {}

final class PriceInitial extends PriceState {}

final class PriceLoading extends PriceState {}

final class PriceSuccess extends PriceState {
  final String message;
  PriceSuccess(this.message);
}

final class PriceFailure extends PriceState {
  final String error;
  PriceFailure(this.error);
}

final class ProductPriceLoaded extends PriceState {
  final ProductPriceMessage priceDetails;
  ProductPriceLoaded(this.priceDetails);
}

final class PriceListsLoaded extends PriceState {
  final List<PriceList> priceLists;
  PriceListsLoaded(this.priceLists);
}
