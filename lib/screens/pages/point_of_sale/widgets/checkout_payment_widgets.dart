import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pos/domain/models/payment_method_model.dart';
import 'checkout_common_widgets.dart';

class CheckoutSinglePaymentInput extends StatelessWidget {
  final List<PaymentMethod> paymentMethods;
  final bool isLoadingPaymentMethods;
  final String? selectedPaymentMethod;
  final TextEditingController mpesaPhoneController;
  final TextEditingController amountPaidController;
  final double change;
  final double total;
  final String? uploadedFileName;
  final Function(String?) onPaymentMethodChanged;
  final Function() onUploadCheque;
  final bool Function(String) isMPesa;
  final String Function(PaymentMethod) getPaymentMethodDisplayName;
  final PaymentMethod Function() getSelectedPaymentMethod;

  const CheckoutSinglePaymentInput({
    super.key,
    required this.paymentMethods,
    required this.isLoadingPaymentMethods,
    required this.selectedPaymentMethod,
    required this.mpesaPhoneController,
    required this.amountPaidController,
    required this.change,
    required this.total,
    this.uploadedFileName,
    required this.onPaymentMethodChanged,
    required this.onUploadCheque,
    required this.isMPesa,
    required this.getPaymentMethodDisplayName,
    required this.getSelectedPaymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCashSelected = selectedPaymentMethod != null &&
        getSelectedPaymentMethod().type.toLowerCase() == 'cash';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: RichText(
            text: TextSpan(
              text: 'Payment Method',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black),
              children: [TextSpan(text: '*', style: TextStyle(color: Colors.red.shade600))],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: isLoadingPaymentMethods
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 12),
                      Text('Loading payment methods...', style: TextStyle(fontSize: 14, color: Colors.black54)),
                    ],
                  ),
                )
              : paymentMethods.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text('No payment methods available', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                    )
                  : DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedPaymentMethod,
                        hint: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('Select Payment Method', style: TextStyle(fontSize: 14, color: Colors.black54)),
                        ),
                        isExpanded: true,
                        icon: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Icon(Icons.arrow_drop_down, size: 24, color: Colors.grey.shade600),
                        ),
                        items: paymentMethods.map((method) {
                          return DropdownMenuItem<String>(
                            value: method.name,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(getPaymentMethodDisplayName(method), style: const TextStyle(fontSize: 14, color: Colors.black87)),
                            ),
                          );
                        }).toList(),
                        onChanged: onPaymentMethodChanged,
                      ),
                    ),
        ),
        if (selectedPaymentMethod != null && isMPesa(selectedPaymentMethod!)) ...[
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: RichText(
              text: TextSpan(
                text: 'M-Pesa Phone Number',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black),
                children: [TextSpan(text: '*', style: TextStyle(color: Colors.red.shade600))],
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: mpesaPhoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: 'Enter phone number',
              hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: const OutlineInputBorder(),
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ],
        if (isCashSelected) ...[
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: RichText(
              text: TextSpan(
                text: 'Amount Paid',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black),
                children: [TextSpan(text: '*', style: TextStyle(color: Colors.red.shade600))],
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: amountPaidController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: 'Enter amount paid',
              hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.white,
              prefixText: 'KES ',
              prefixStyle: const TextStyle(fontSize: 14, color: Colors.black87),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            style: const TextStyle(fontSize: 14),
          ),
          if (change > 0) ...[
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Change', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black)),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border.all(color: Colors.green.shade200),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'KES ${change.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.green.shade800),
              ),
            ),
          ],
        ],
        if (selectedPaymentMethod != null && getSelectedPaymentMethod().type.toLowerCase() == 'cheque') ...[
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onUploadCheque,
            child: Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 30,
                    decoration: BoxDecoration(color: Colors.blue.shade700, borderRadius: BorderRadius.circular(4)),
                    child: const Icon(Icons.cloud_upload_outlined, color: Colors.white, size: 24),
                  ),
                  const SizedBox(height: 12),
                  const Text('Click to upload a file', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text(uploadedFileName ?? 'Max size: 5MB', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class CheckoutSplitPaymentInput extends StatelessWidget {
  final List<SplitPayment> splitPayments;
  final List<PaymentMethod> paymentMethods;
  final bool isLoadingPaymentMethods;
  final Function() onAddRow;
  final Function(int) onRemoveRow;
  final Function(int, String?) onPaymentMethodChanged;
  final bool Function(String) isMPesa;
  final String Function(PaymentMethod) getPaymentMethodDisplayName;

  const CheckoutSplitPaymentInput({
    super.key,
    required this.splitPayments,
    required this.paymentMethods,
    required this.isLoadingPaymentMethods,
    required this.onAddRow,
    required this.onRemoveRow,
    required this.onPaymentMethodChanged,
    required this.isMPesa,
    required this.getPaymentMethodDisplayName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text('Payment Method', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Text('Amount', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              ...List.generate(splitPayments.length, (index) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: index < splitPayments.length - 1
                        ? Border(bottom: BorderSide(color: Colors.grey.shade200))
                        : null,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: isLoadingPaymentMethods
                              ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                              : DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: splitPayments[index].paymentMethod,
                                    hint: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 8),
                                      child: Text('Select', style: TextStyle(fontSize: 13, color: Colors.black54)),
                                    ),
                                    isExpanded: true,
                                    icon: Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey.shade600),
                                    ),
                                    items: paymentMethods.map((method) {
                                      return DropdownMenuItem<String>(
                                        value: method.name,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          child: Text(getPaymentMethodDisplayName(method), style: const TextStyle(fontSize: 13, color: Colors.black87)),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (val) => onPaymentMethodChanged(index, val),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: splitPayments[index].amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            hintText: '0.00',
                            hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            isDense: true,
                          ),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        child: IconButton(
                          onPressed: () => onRemoveRow(index),
                          icon: Icon(
                            Icons.close,
                            size: 18,
                            color: splitPayments.length > 1 ? Colors.red.shade400 : Colors.grey.shade300,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              ...splitPayments.asMap().entries.map((entry) {
                final index = entry.key;
                final split = entry.value;
                if (split.paymentMethod == null || !isMPesa(split.paymentMethod!)) {
                  return const SizedBox.shrink();
                }
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'M-Pesa Phone (Row ${index + 1})',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: split.mpesaPhoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          hintText: 'Enter phone number',
                          hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                          isDense: true,
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onAddRow,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Row'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
      ],
    );
  }
}
