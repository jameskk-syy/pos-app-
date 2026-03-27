part of 'biller_bloc.dart';

abstract class BillerEvent {}

class GetUserContext extends BillerEvent {}

class SetActiveBiller extends BillerEvent {
  final SetActiveBillerRequest request;
  SetActiveBiller(this.request);
}

class GetBillerDetails extends BillerEvent {
  final GetBillerDetailsRequest request;
  GetBillerDetails(this.request);
}

class ListBillers extends BillerEvent {
  final ListBillersRequest request;
  ListBillers(this.request);
}

class CreateBiller extends BillerEvent {
  final CreateBillerRequest request;
  CreateBiller(this.request);
}
