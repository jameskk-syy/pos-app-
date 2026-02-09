part of 'grn_bloc.dart';

abstract class GrnState {}

class GrnInitial extends GrnState {}

class GrnListLoading extends GrnState {}

class GrnListLoaded extends GrnState {
  final GrnListResponse response;
  GrnListLoaded({required this.response});
}

class GrnListError extends GrnState {
  final String message;
  GrnListError({required this.message});
}

class GrnListEmpty extends GrnState {}

class GrnDetailLoading extends GrnState {}

class GrnDetailLoaded extends GrnState {
  final GrnDetailResponse response;
  GrnDetailLoaded({required this.response});
}

class GrnDetailError extends GrnState {
  final String message;
  GrnDetailError({required this.message});
}
