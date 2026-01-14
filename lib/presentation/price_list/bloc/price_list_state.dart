import 'package:equatable/equatable.dart';
import 'package:pos/domain/responses/price_list_response.dart';

abstract class PriceListState extends Equatable {
  const PriceListState();

  @override
  List<Object?> get props => [];
}

class PriceListInitial extends PriceListState {}

class PriceListLoading extends PriceListState {}

class PriceListLoaded extends PriceListState {
  final List<PriceList> allPriceLists;
  final List<PriceList> filteredPriceLists;

  const PriceListLoaded({
    required this.allPriceLists,
    required this.filteredPriceLists,
  });

  @override
  List<Object?> get props => [allPriceLists, filteredPriceLists];
}

class PriceListActionSuccess extends PriceListState {
  final String message;
  const PriceListActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class PriceListError extends PriceListState {
  final String message;
  const PriceListError(this.message);

  @override
  List<Object?> get props => [message];
}
