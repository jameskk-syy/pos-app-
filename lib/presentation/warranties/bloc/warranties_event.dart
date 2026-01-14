import 'package:equatable/equatable.dart';

abstract class WarrantiesEvent extends Equatable {
  const WarrantiesEvent();

  @override
  List<Object?> get props => [];
}

class LoadWarranties extends WarrantiesEvent {
  final bool isRefresh;
  const LoadWarranties({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

class SearchWarranties extends WarrantiesEvent {
  final String query;
  const SearchWarranties(this.query);

  @override
  List<Object?> get props => [query];
}

class SetWarrantyEvent extends WarrantiesEvent {
  final String company;
  final String itemCode;
  final int warrantyPeriod;
  final String warrantyPeriodUnit;

  const SetWarrantyEvent({
    required this.company,
    required this.itemCode,
    required this.warrantyPeriod,
    required this.warrantyPeriodUnit,
  });

  @override
  List<Object?> get props => [
    company,
    itemCode,
    warrantyPeriod,
    warrantyPeriodUnit,
  ];
}
