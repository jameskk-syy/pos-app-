import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pos/domain/models/cart_item.dart';
import 'package:pos/domain/models/invoice_model.dart';
import 'package:pos/domain/responses/sales/crm_customer.dart';

class CheckoutReviewStep extends StatelessWidget {
  final List<CartItem> cartItems;
  final double total;

  const CheckoutReviewStep({super.key, required this.cartItems, required this.total});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Order Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            color: Colors.grey[50],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey[200]!)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  for (var item in cartItems)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.grey[300]!)),
                            child: Center(child: Text(item.product.image, style: const TextStyle(fontSize: 16))),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.product.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 2),
                                Text('${item.quantity} × ${item.product.price.toStringAsFixed(2)}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                              ],
                            ),
                          ),
                          Text(item.totalPrice.toStringAsFixed(2), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  const Divider(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Subtotal', style: TextStyle(fontSize: 14)), Text(total.toStringAsFixed(2), style: const TextStyle(fontSize: 14))]),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      Text(total.toStringAsFixed(2), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blue)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CheckoutCustomerStep extends StatelessWidget {
  final String? selectedCustomerId;
  final String? selectedCustomerName;
  final List<Customer> filteredCustomers;
  final bool isLoadingCustomers;
  final bool showCustomerResults;
  final TextEditingController searchController;
  final Function(String) onSearch;
  final Function(Customer) onSelect;
  final VoidCallback onClear;
  final VoidCallback onTapSearch;

  const CheckoutCustomerStep({
    super.key,
    required this.selectedCustomerId,
    required this.selectedCustomerName,
    required this.filteredCustomers,
    required this.isLoadingCustomers,
    required this.showCustomerResults,
    required this.searchController,
    required this.onSearch,
    required this.onSelect,
    required this.onClear,
    required this.onTapSearch,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Customer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text('Choose an existing customer or add a new one', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 16),
          if (selectedCustomerId != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green[100]!)),
              child: Row(
                children: [
                  const Icon(Icons.person, color: Colors.green, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(selectedCustomerName ?? 'Unknown Customer', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        Text('ID: $selectedCustomerId', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.close, size: 20), onPressed: onClear, tooltip: 'Change customer'),
                ],
              ),
            ),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name, email, or phone...',
                      border: InputBorder.none,
                      suffixIcon: isLoadingCustomers
                          ? const Padding(padding: EdgeInsets.all(10), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)))
                          : IconButton(icon: const Icon(Icons.search), onPressed: onTapSearch),
                    ),
                    onChanged: onSearch,
                    onTap: onTapSearch,
                  ),
                ),
                if (showCustomerResults)
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredCustomers.length,
                      itemBuilder: (context, index) {
                        final customer = filteredCustomers[index];
                        return ListTile(
                          leading: const Icon(Icons.person_outline),
                          title: Text(customer.name),
                          subtitle: customer.emailId != null ? Text(customer.emailId!) : null,
                          trailing: selectedCustomerId == customer.name ? const Icon(Icons.check, color: Colors.green) : null,
                          onTap: () => onSelect(customer),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CheckoutPaymentStep extends StatelessWidget {
  final List<Map<String, dynamic>> paymentMethods;
  final String selectedPayment;
  final bool isLoading;
  final double total;
  final double changeAmount;
  final TextEditingController amountPaidController;
  final TextEditingController mpesaPhoneController;
  final Function(String?) onPaymentChanged;
  final bool isMPesa;
  final String? customerName;

  const CheckoutPaymentStep({
    super.key,
    required this.paymentMethods,
    required this.selectedPayment,
    required this.isLoading,
    required this.total,
    required this.changeAmount,
    required this.amountPaidController,
    required this.mpesaPhoneController,
    required this.onPaymentChanged,
    required this.isMPesa,
    this.customerName,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (customerName != null)
            Container(
              padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue[100]!)),
              child: Row(children: [const Icon(Icons.person, color: Colors.blue, size: 20), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Customer', style: TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w600)), Text(customerName!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))]))]),
            ),
          const Text('Select Payment Method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text('Choose your preferred payment method', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 16),
          if (isLoading)
            const Center(child: Column(children: [CircularProgressIndicator(), SizedBox(height: 10), Text('Loading payment methods...', style: TextStyle(fontSize: 12))]))
          else if (paymentMethods.isEmpty)
            const Center(child: Text('No payment methods available', style: TextStyle(fontSize: 12, color: Colors.grey)))
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8), color: Colors.white),
              child: DropdownButton<String>(
                value: selectedPayment.isEmpty ? null : selectedPayment,
                hint: const Text('Select a payment method', style: TextStyle(fontSize: 14)),
                isExpanded: true, underline: const SizedBox(), icon: const Icon(Icons.arrow_drop_down, size: 24), borderRadius: BorderRadius.circular(8),
                onChanged: onPaymentChanged,
                items: paymentMethods.where((m) => m['enabled'] == 1).map<DropdownMenuItem<String>>((m) => DropdownMenuItem<String>(
                  value: m['name'],
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(m['name'].toString().replaceAll(RegExp(r'\(.*?\)'), '').trim(), style: const TextStyle(fontSize: 14)), if (m['type'] != null) Text('Type: ${m['type']}', style: TextStyle(fontSize: 11, color: Colors.grey[600]))]),
                )).toList(),
              ),
            ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Amount Paid', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                TextField(
                  controller: amountPaidController, keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(hintText: 'Enter amount paid', prefixIcon: Icon(Icons.payments_outlined, size: 20), suffixText: 'KES', suffixStyle: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                if (changeAmount > 0) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green[100]!)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Change is:', style: TextStyle(fontSize: 14, color: Colors.green[700], fontWeight: FontWeight.w500)), const SizedBox(height: 4), Text('KES ${changeAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.green[800]))]),
                  ),
                ],
              ],
            ),
          ),
          if (isMPesa) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('M-Pesa Phone Number', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)), const SizedBox(height: 10), TextField(controller: mpesaPhoneController, keyboardType: TextInputType.phone, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: const InputDecoration(hintText: 'Enter phone number (e.g., 0712345678)', prefixIcon: Icon(Icons.phone_android, size: 20), border: OutlineInputBorder()), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))]),
            ),
          ],
        ],
      ),
    );
  }
}

class CheckoutCompleteStep extends StatelessWidget {
  final CreateInvoiceResponse? createdInvoice;
  final String? customerName;
  final String? customerId;
  final String selectedPayment;
  final List<Map<String, dynamic>> paymentMethods;
  final VoidCallback onPrint;
  final VoidCallback onEmail;
  final bool receiptPrinted;
  final double total;

  const CheckoutCompleteStep({
    super.key,
    required this.createdInvoice,
    required this.customerName,
    required this.customerId,
    required this.selectedPayment,
    required this.paymentMethods,
    required this.onPrint,
    required this.onEmail,
    required this.receiptPrinted,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final isSuccess = createdInvoice?.success == true;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatusIcon(isSuccess),
            const SizedBox(height: 20),
            Text(isSuccess ? 'Order Completed Successfully!' : 'Order Processing Failed', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: isSuccess ? Colors.green.shade800 : Colors.red.shade800), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(isSuccess ? 'Thank you for your purchase' : 'Please try again or contact support', style: const TextStyle(fontSize: 14, color: Colors.grey), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            if (isSuccess && createdInvoice?.data != null) _buildInvoiceCard(),
            if (customerName != null) _buildInfoCard(Icons.person, 'Customer', customerName!, subtitle: 'ID: $customerId'),
            if (selectedPayment.isNotEmpty) _buildPaymentCard(),
            const SizedBox(height: 16),
            _buildTotalDisplay(),
            const SizedBox(height: 24),
            _buildReceiptActions(context),
            const SizedBox(height: 20),
            _buildNextSteps(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(bool success) {
    return Container(
      width: 100, height: 100,
      decoration: BoxDecoration(color: success ? Colors.green.shade50 : Colors.red.shade50, shape: BoxShape.circle, border: Border.all(color: success ? Colors.green.shade200 : Colors.red.shade200, width: 3)),
      child: Center(child: Icon(success ? Icons.check_circle : Icons.error_outline, color: success ? Colors.green : Colors.red, size: 48)),
    );
  }

  Widget _buildInvoiceCard() {
    return Card(
      elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(children: [Icon(Icons.receipt_long, color: Colors.blue.shade700, size: 24), const SizedBox(width: 12), const Text('Invoice Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))]),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.all(12),
              child: Row(children: [
                Expanded(child: _infoColumn('Invoice Number', createdInvoice!.data!.name)),
                Container(height: 40, width: 1, color: Colors.grey.shade300),
                const SizedBox(width: 16),
                Expanded(child: _infoColumn('Grand Total', createdInvoice!.data!.grandTotal.toStringAsFixed(2), valColor: Colors.green.shade700)),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoColumn(String label, String value, {Color? valColor}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)), Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: valColor))]);
  }

  Widget _buildInfoCard(IconData icon, String label, String title, {String? subtitle}) {
    return Card(
      elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.blue.shade100, shape: BoxShape.circle), child: Icon(icon, color: Colors.blue.shade700, size: 24)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)), const SizedBox(height: 4), Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis), if (subtitle != null) Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600))])),
        ]),
      ),
    );
  }

  Widget _buildPaymentCard() {
    Map<String, dynamic>? method;
    try { method = paymentMethods.firstWhere((m) => m['name'] == selectedPayment); } catch (_) {}
    return Card(
      elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.green.shade100, shape: BoxShape.circle), child: const Icon(Icons.payment, color: Colors.green, size: 24)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Payment Method', style: TextStyle(fontSize: 12, color: Colors.grey)), Text(selectedPayment, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)), if (method != null && method['type'] != null) Text('Type: ${method['type']}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600))])),
          ]),
        ]),
      ),
    );
  }

  Widget _buildTotalDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.blue.shade50, Colors.blue.shade100]), borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.blue.shade100, blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(children: [const Text('Total Amount Paid', style: TextStyle(fontSize: 14, color: Colors.grey)), const SizedBox(height: 8), Text('KES ${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.blue))]),
    );
  }

  Widget _buildReceiptActions(BuildContext context) {
    return Card(
      elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.receipt, color: Colors.blue, size: 20), SizedBox(width: 8), Text('RECEIPT', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.blue))]),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: _actionBtn(receiptPrinted ? 'Printed' : 'Print', Icons.print, receiptPrinted ? Colors.green : Colors.blue, onPrint)),
            const SizedBox(width: 12),
            Expanded(child: _actionBtn('Email', Icons.email_outlined, Colors.orange, onEmail, isOutline: false)),
          ]),
        ]),
      ),
    );
  }

  Widget _actionBtn(String label, IconData icon, Color color, VoidCallback onTap, {bool isOutline = true}) {
    return ElevatedButton.icon(
      onPressed: onTap, icon: Icon(icon, size: 18), label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(backgroundColor: isOutline ? Colors.white : color, foregroundColor: isOutline ? color : Colors.white, side: BorderSide(color: color, width: 1.5), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
    );
  }

  Widget _buildNextSteps() {
    return Card(
      elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('What\'s Next?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          _stepItem(Icons.local_shipping, Colors.blue.shade700, 'Order Processing', 'Your order is being prepared', '2-3 business days'),
          const SizedBox(height: 12),
          _stepItem(Icons.track_changes, Colors.green.shade700, 'Track Your Order', 'Use tracking ID sent to email', 'Within 24 hours'),
        ]),
      ),
    );
  }

  Widget _stepItem(IconData icon, Color color, String title, String sub, String time) {
    return Container(
      padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
      child: Row(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withAlpha(10), shape: BoxShape.circle), child: Icon(icon, color: color, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)), Text(sub, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)), Text(time, style: TextStyle(fontSize: 11, color: Colors.grey.shade500))])),
      ]),
    );
  }
}

class CreditLimitWarningDialog extends StatelessWidget {
  final double limit;
  final double available;
  final double total;
  final VoidCallback onConfirm;

  const CreditLimitWarningDialog({super.key, required this.limit, required this.available, required this.total, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0, backgroundColor: Colors.transparent,
      child: Container(
        width: 450, padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.zero),
        child: Column(
          mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.red[50], shape: BoxShape.circle), child: Icon(Icons.warning_amber_rounded, color: Colors.red[600], size: 48))),
            const SizedBox(height: 24),
            const Center(child: Text('Credit Limit Exceeded', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
            const SizedBox(height: 16),
            const Text('This transaction cannot proceed on credit:', style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 16),
            Container(width: double.infinity, padding: const EdgeInsets.all(16), color: Colors.grey[50], child: Column(children: [_row('Credit Limit:', limit), _row('Available Credit:', available, isCritical: available < total), _row('Current Total:', total)])),
            const SizedBox(height: 24),
            Text(limit <= 0 ? 'Customer has no credit facility enabled.' : 'Amount exceeds available credit.', style: TextStyle(fontSize: 13, color: Colors.red[700], fontWeight: FontWeight.w500)),
            const SizedBox(height: 32),
            SizedBox(width: double.infinity, height: 48, child: ElevatedButton(onPressed: onConfirm, style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[600], foregroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero), elevation: 0), child: const Text('OK, I UNDERSTAND'))),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, double val, {bool isCritical = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(fontSize: 13)), Text('${val.toStringAsFixed(2)} KES', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isCritical ? Colors.red[700] : Colors.black87))]),
    );
  }
}

class CheckoutStepIndicator extends StatelessWidget {
  final int currentStep;
  const CheckoutStepIndicator({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), color: Colors.grey[50],
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_step(0, 'Review'), _line(0), _step(1, 'Customer'), _line(1), _step(2, 'Payment'), _line(2), _step(3, 'Complete')]),
    );
  }

  Widget _step(int step, String title) {
    final active = currentStep == step; final done = currentStep > step;
    return Column(children: [
      Container(width: 28, height: 28, decoration: BoxDecoration(color: done ? Colors.green : (active ? Colors.blue : Colors.grey[300]), shape: BoxShape.circle), child: Center(child: done ? const Icon(Icons.check, color: Colors.white, size: 16) : Text('${step + 1}', style: TextStyle(fontSize: 12, color: active ? Colors.white : Colors.grey[700], fontWeight: FontWeight.w600)))),
      const SizedBox(height: 4),
      Text(title, style: TextStyle(fontSize: 10, fontWeight: active ? FontWeight.w600 : FontWeight.normal, color: active ? Colors.blue : Colors.grey[600])),
    ]);
  }

  Widget _line(int step) {
    return Expanded(child: Divider(height: 2, indent: 8, endIndent: 8, color: currentStep > step ? Colors.green : Colors.grey[300]));
  }
}
