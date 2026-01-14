part of 'barcode_bloc.dart';

sealed class BarcodeEvent {}

class AddBarcodeEvent extends BarcodeEvent {
  final String itemCode;
  final String barcode;

  AddBarcodeEvent({required this.itemCode, required this.barcode});
}
