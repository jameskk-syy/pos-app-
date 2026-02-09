import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pos/domain/requests/purchase/pay_purchase_invoice_request.dart';
import 'package:pos/domain/responses/purchase/purchase_invoice_detail_response.dart';
import 'package:pos/presentation/purchase_invoice/bloc/purchase_invoice_bloc.dart';
import 'package:pos/widgets/common/app_button.dart';
import 'package:pos/widgets/common/app_drop_down.dart';
import 'package:pos/widgets/common/app_text_field.dart';

class PayInvoiceScreen extends StatefulWidget {
  final PurchaseInvoiceDetailData invoiceData;

  const PayInvoiceScreen({super.key, required this.invoiceData});

  @override
  State<PayInvoiceScreen> createState() => _PayInvoiceScreenState();
}

class _PayInvoiceScreenState extends State<PayInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _invoiceNoController;
  late TextEditingController _amountController;
  late TextEditingController _postingDateController;
  late TextEditingController _referenceNoController;
  late TextEditingController _referenceDateController;
  late TextEditingController _remarksController;

  String _modeOfPayment = 'Cash';
  final List<String> _paymentModes = ['Cash', 'Bank', 'Mpesa', 'Cheque'];

  @override
  void initState() {
    super.initState();
    _invoiceNoController = TextEditingController(
      text: widget.invoiceData.invoiceNo,
    );
    _amountController = TextEditingController(
      text: widget.invoiceData.outstandingAmount.toString(),
    );
    _postingDateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    _referenceNoController = TextEditingController();
    _referenceDateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    _remarksController = TextEditingController();
  }

  @override
  void dispose() {
    _invoiceNoController.dispose();
    _amountController.dispose();
    _postingDateController.dispose();
    _referenceNoController.dispose();
    _referenceDateController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _submitPayment() {
    if (_formKey.currentState!.validate()) {
      final request = PayPurchaseInvoiceRequest(
        invoiceNo: _invoiceNoController.text,
        paidAmount: double.tryParse(_amountController.text) ?? 0.0,
        modeOfPayment: _modeOfPayment,
        postingDate: _postingDateController.text,
        referenceNo: _referenceNoController.text,
        referenceDate: _referenceDateController.text,
        remarks: _remarksController.text,
        submit: true,
      );

      context.read<PurchaseInvoiceBloc>().add(
        PayPurchaseInvoiceEvent(request: request),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PurchaseInvoiceBloc, PurchaseInvoiceState>(
      listener: (context, state) {
        if (state is PaidPurchaseInvoice) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.response.message),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else if (state is PayPurchaseInvoiceError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pay Purchase Invoice'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue,
          elevation: 0.5,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey[200]!),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        AppTextField(
                          controller: _invoiceNoController,
                          labelText: 'Invoice No',
                          enabled: false,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _amountController,
                          labelText: 'Amount to Pay',
                          keyboardType: TextInputType.number,
                          type: AppTextFieldType.currency,
                        ),
                        const SizedBox(height: 16),
                        AppDropDown<String>(
                          labelText: 'Mode of Payment',
                          selectedValue: _modeOfPayment,
                          dropdownItems: _paymentModes.map((mode) {
                            return DropdownMenuItem(
                              value: mode,
                              child: Text(mode),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _modeOfPayment = val);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _postingDateController,
                          labelText: 'Posting Date',
                          suffixWidget: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () =>
                                _selectDate(context, _postingDateController),
                          ),
                          enabled: false, // User should use the picker
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _referenceNoController,
                          labelText: 'Reference No',
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _referenceDateController,
                          labelText: 'Reference Date',
                          suffixWidget: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () =>
                                _selectDate(context, _referenceDateController),
                          ),
                          enabled: false,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _remarksController,
                          labelText: 'Remarks',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 24),
                        BlocBuilder<PurchaseInvoiceBloc, PurchaseInvoiceState>(
                          builder: (context, state) {
                            return AppButton(
                              text: state is PayingPurchaseInvoice
                                  ? 'Processing...'
                                  : 'Submit Payment',
                              buttonColor: Colors.blue,
                              onTap: state is PayingPurchaseInvoice
                                  ? null
                                  : _submitPayment,
                              enabled: state is! PayingPurchaseInvoice,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
