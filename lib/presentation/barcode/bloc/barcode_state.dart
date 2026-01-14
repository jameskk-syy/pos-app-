part of 'barcode_bloc.dart';

sealed class BarcodeState {}

class BarcodeInitial extends BarcodeState {}

class BarcodeLoading extends BarcodeState {}

class BarcodeSuccess extends BarcodeState {
  final String message;
  BarcodeSuccess(this.message);
}

class BarcodeFailure extends BarcodeState {
  final String error;
  BarcodeFailure(this.error);
}
