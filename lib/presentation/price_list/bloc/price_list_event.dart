import 'package:equatable/equatable.dart';

abstract class PriceListEvent extends Equatable {
  const PriceListEvent();

  @override
  List<Object?> get props => [];
}

class LoadPriceLists extends PriceListEvent {}

class SearchPriceLists extends PriceListEvent {
  final String query;
  const SearchPriceLists(this.query);

  @override
  List<Object?> get props => [query];
}

class CreatePriceList extends PriceListEvent {
  final String company;
  final String priceListName;
  final String currency;
  final bool enabled;
  final bool buying;
  final bool selling;

  const CreatePriceList({
    required this.company,
    required this.priceListName,
    required this.currency,
    required this.enabled,
    required this.buying,
    required this.selling,
  });

  @override
  List<Object?> get props => [
    company,
    priceListName,
    currency,
    enabled,
    buying,
    selling,
  ];
}

class UpdatePriceListEvent extends PriceListEvent {
  final String name;
  final String newPriceListName;
  final String currency;
  final bool enabled;
  final bool buying;
  final bool selling;

  const UpdatePriceListEvent({
    required this.name,
    required this.newPriceListName,
    required this.currency,
    required this.enabled,
    required this.buying,
    required this.selling,
  });

  @override
  List<Object?> get props => [
    name,
    newPriceListName,
    currency,
    enabled,
    buying,
    selling,
  ];
}
