part of 'biller_bloc.dart';

abstract class BillerState {}

class BillerInitial extends BillerState {}

// Get User Context
class UserContextLoading extends BillerState {}

class UserContextLoaded extends BillerState {
  final UserContextResponse response;
  UserContextLoaded(this.response);
}

class UserContextError extends BillerState {
  final String message;
  UserContextError(this.message);
}

// Set Active Biller
class SetActiveBillerLoading extends BillerState {}

class SetActiveBillerSuccess extends BillerState {
  final SetActiveBillerResponse response;
  SetActiveBillerSuccess(this.response);
}

class SetActiveBillerError extends BillerState {
  final String message;
  SetActiveBillerError(this.message);
}

// Get Biller Details
class BillerDetailsLoading extends BillerState {}

class BillerDetailsLoaded extends BillerState {
  final BillerDetailsResponse response;
  BillerDetailsLoaded(this.response);
}

class BillerDetailsError extends BillerState {
  final String message;
  BillerDetailsError(this.message);
}

// List Billers
class ListBillersLoading extends BillerState {}

class ListBillersLoaded extends BillerState {
  final ListBillersResponse response;
  final bool hasReachedMax;
  ListBillersLoaded(this.response, {this.hasReachedMax = false});
}

class ListBillersMoreLoading extends BillerState {
  final List<BillerProfile> existingBillers;
  ListBillersMoreLoading(this.existingBillers);
}

class ListBillersError extends BillerState {
  final String message;
  ListBillersError(this.message);
}

// Create Biller
class CreateBillerLoading extends BillerState {}

class CreateBillerSuccess extends BillerState {
  final CreateBillerResponse response;
  CreateBillerSuccess(this.response);
}

class CreateBillerError extends BillerState {
  final String message;
  CreateBillerError(this.message);
}
