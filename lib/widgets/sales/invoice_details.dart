import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:pos/domain/models/invoice_model.dart';
import 'package:pos/domain/models/cart_item.dart';
import 'package:pos/domain/models/invoice_model_get.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/domain/repository/abstract_sales_repository.dart';

class InvoiceDetailsWidget extends StatefulWidget {
  final CreateInvoiceResponse response;
  final List<CartItem>? cartItems;
  final List<InvoicePayment>? payments;
  final double? change;

  const InvoiceDetailsWidget({
    super.key,
    required this.response,
    this.cartItems,
    this.payments,
    this.change,
  });

  @override
  State<InvoiceDetailsWidget> createState() => _InvoiceDetailsWidgetState();
}

class _InvoiceDetailsWidgetState extends State<InvoiceDetailsWidget> {
  bool _isPrinting = false;
  bool _isDownloading = false;
  Uint8List? _pdfBytes;
  CurrentUserResponse? _currentUser;
  SalesInvoiceData? _fullInvoiceData;

  @override
  void initState() {
    super.initState();
    _loadDataAndGeneratePdf();
  }

  Future<void> _loadDataAndGeneratePdf() async {
    setState(() {
      _isDownloading = true;
    });

    try {
      final storage = getIt<StorageService>();
      final userString = await storage.getString('current_user');
      if (userString != null) {
        _currentUser = CurrentUserResponse.fromJson(jsonDecode(userString));
      }

      final invoiceName = widget.response.data?.name;
      if (widget.cartItems == null && invoiceName != null && invoiceName.isNotEmpty) {
        final salesRepo = getIt<SalesRepository>();
        final response = await salesRepo.getSalesInvoice(invoiceName: invoiceName);
        if (response.success) {
          _fullInvoiceData = response.data;
        }
      }
    } catch (e) {
      debugPrint('Failed to load invoice or cashier details: $e');
    } finally {
      setState(() {
      });
      _generatePdf();
    }
  }

  Future<void> _generatePdf() async {
    setState(() {
      _isDownloading = true;
    });

    try {
      final pdf = await _createInvoicePdf();
      setState(() {
        _pdfBytes = pdf;
        _isDownloading = false;
      });
    } catch (e) {
      setState(() {
        _isDownloading = false;
      });
      _showError('Failed to generate PDF: $e');
    }
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      return DateFormat('dd/MM/yyyy').format(DateTime.now());
    }
    try {
      final parsed = DateTime.tryParse(dateStr);
      if (parsed != null) {
        return DateFormat('dd/MM/yyyy').format(parsed);
      }
    } catch (_) {}
    return dateStr;
  }

  String formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) {
      return DateFormat('HH:mm:ss').format(DateTime.now());
    }
    if (timeStr.contains('.')) {
      return timeStr.split('.').first;
    }
    return timeStr;
  }

  pw.Widget _buildReceiptRow(String left, String right, pw.TextStyle style) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(left, style: style),
          pw.Text(right, style: style),
        ],
      ),
    );
  }

  Future<Uint8List> _createInvoicePdf() async {
    final pdf = pw.Document();

    final fontRegular = pw.Font.courier();
    final fontBold = pw.Font.courierBold();

    final textStyle = pw.TextStyle(font: fontRegular, fontSize: 9);
    final boldStyle = pw.TextStyle(font: fontBold, fontSize: 9);

    final companyName = _currentUser?.message.company.companyName ?? 
                        widget.response.data?.company ?? 
                        _fullInvoiceData?.company ?? 
                        'pybusiness';

    final customerName = widget.response.data?.customer ?? 
                         _fullInvoiceData?.customer ?? 
                         'Walk-in Customer';

    final receiptNo = widget.response.data?.name ?? 
                      _fullInvoiceData?.name ?? 
                      'N/A';

    final warehouseName = _currentUser?.message.defaultWarehouse?? 
                          _fullInvoiceData?.setWarehouse ?? 
                          _currentUser?.message.posProfile.warehouse ?? 
                          'pybusiness';

    final cashierName = _currentUser?.message.user.fullName ?? 
                        _fullInvoiceData?.owner ?? 
                        'samson safdari';

    final postingDate = widget.response.data?.postingDate ?? 
                        _fullInvoiceData?.postingDate;

    final postingTime = _fullInvoiceData?.postingTime;

    final dateStr = formatDate(postingDate);
    final timeStr = formatTime(postingTime);

    final grandTotal = widget.response.data?.grandTotal ?? 
                       _fullInvoiceData?.grandTotal ?? 
                       0.0;

    final List<pw.Widget> itemsWidgets = [];
    int totalItemsQty = 0;

    if (widget.cartItems != null) {
      for (var item in widget.cartItems!) {
        final name = item.product.name;
        final qty = item.quantity;
        final rate = item.product.price;
        final amount = item.totalPrice;
        totalItemsQty += qty;

        itemsWidgets.add(
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(name, style: boldStyle),
              _buildReceiptRow(
                '${rate.toStringAsFixed(2)} x $qty',
                amount.toStringAsFixed(2),
                textStyle,
              ),
              pw.SizedBox(height: 2),
            ],
          ),
        );
      }
    } else if (_fullInvoiceData != null) {
      for (var item in _fullInvoiceData!.items) {
        final name = item.itemName ?? item.itemCode;
        final qty = item.qty;
        final rate = item.rate;
        final amount = item.amount;
        totalItemsQty += qty;

        itemsWidgets.add(
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(name, style: boldStyle),
              _buildReceiptRow(
                '${rate.toStringAsFixed(2)} x $qty',
                amount.toStringAsFixed(2),
                textStyle,
              ),
              pw.SizedBox(height: 2),
            ],
          ),
        );
      }
    }

    final List<pw.Widget> paymentsWidgets = [];
    if (widget.payments != null) {
      for (var payment in widget.payments!) {
        final mode = payment.modeOfPayment.toUpperCase();
        paymentsWidgets.add(
          _buildReceiptRow(
            '$mode PAYMENT',
            payment.amount.toStringAsFixed(2),
            textStyle,
          ),
        );
      }
    } else if (_fullInvoiceData?.payments != null && _fullInvoiceData!.payments!.isNotEmpty) {
      for (var payment in _fullInvoiceData!.payments!) {
        final mode = payment.modeOfPayment.toUpperCase();
        paymentsWidgets.add(
          _buildReceiptRow(
            '$mode PAYMENT',
            payment.amount.toStringAsFixed(2),
            textStyle,
          ),
        );
      }
    } else {
      paymentsWidgets.add(
        _buildReceiptRow(
          'CASH PAYMENT',
          grandTotal.toStringAsFixed(2),
          textStyle,
        ),
      );
    }

    if (widget.change != null && widget.change! > 0) {
      paymentsWidgets.add(
        _buildReceiptRow(
          'CHANGE',
          widget.change!.toStringAsFixed(2),
          textStyle,
        ),
      );
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.all(5 * PdfPageFormat.mm),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Center(
                child: pw.Text(
                  companyName.toUpperCase(),
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 12,
                  ),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'SALES RECEIPT',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 10,
                  ),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Divider(thickness: 0.8, color: PdfColors.black, height: 6),
              
              pw.Center(
                child: pw.Text(
                  'Customer: $customerName',
                  style: textStyle,
                ),
              ),
              pw.Divider(thickness: 0.8, color: PdfColors.black, height: 6),
              
              ...itemsWidgets,
              
              pw.Divider(thickness: 0.8, color: PdfColors.black, height: 6),
              
              _buildReceiptRow('TOTAL BEFORE DISCOUNT', grandTotal.toStringAsFixed(2), textStyle),
              _buildReceiptRow('SUB TOTAL', grandTotal.toStringAsFixed(2), textStyle),
              _buildReceiptRow('TOTAL', grandTotal.toStringAsFixed(2), boldStyle),
              
              pw.Divider(thickness: 0.8, color: PdfColors.black, height: 6),
              
              ...paymentsWidgets,
              _buildReceiptRow('ITEMS NUMBER', totalItemsQty.toString(), textStyle),
              
              pw.Divider(thickness: 0.8, color: PdfColors.black, height: 6),
              
              _buildReceiptRow('RECEIPT NO:', receiptNo, textStyle),
              _buildReceiptRow('WAREHOUSE:', warehouseName, textStyle),
              _buildReceiptRow('DATE: $dateStr', 'TIME: $timeStr', textStyle),
              
              pw.Divider(thickness: 0.8, color: PdfColors.black, height: 6),
              
              pw.Center(
                child: pw.Text(
                  'THANK YOU',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 10,
                  ),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  cashierName,
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 10,
                  ),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'Warehouse: $warehouseName',
                  style: pw.TextStyle(
                    font: fontRegular,
                    fontSize: 8,
                    color: PdfColors.grey,
                  ),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  'NON-BINDING INTERNAL RECORD',
                  style: pw.TextStyle(
                    font: fontRegular,
                    fontSize: 8,
                    color: PdfColors.grey,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<void> _printInvoice() async {
    if (_pdfBytes == null) {
      _showError('PDF not ready yet');
      return;
    }

    setState(() {
      _isPrinting = true;
    });

    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => _pdfBytes!,
      );
    } catch (e) {
      _showError('Failed to print: $e');
    } finally {
      setState(() {
        _isPrinting = false;
      });
    }
  }

  Future<void> _downloadPdf() async {
    if (_pdfBytes == null) {
      _showError('PDF not ready yet');
      return;
    }

    try {
      await Printing.sharePdf(
        bytes: _pdfBytes!,
        filename: 'invoice_${widget.response.data?.name}.pdf',
      );
    } catch (e) {
      _showError('Failed to share PDF: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _closeAndNavigateBack() {
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.response.data;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        Navigator.pop(context, true);
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('Invoice Details'),
            // leading: IconButton(
            //   icon: const Icon(Icons.arrow_back),
            //   onPressed: _closeAndNavigateBack,
            // ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Success Message
                // Card(
                //   color: Colors.green[50],
                //   child: Padding(
                //     padding: const EdgeInsets.all(16.0),
                //     child: Row(
                //       children: [
                //         const Icon(Icons.check_circle, color: Colors.green),
                //         const SizedBox(width: 12),
                //         Expanded(
                //           child: Text(
                //             widget.response.message,
                //             style: const TextStyle(
                //               fontWeight: FontWeight.bold,
                //               color: Colors.green,
                //             ),
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                const SizedBox(height: 24),

                if (data != null) ...[
                  // Invoice Details Card
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Invoice Details',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildDetailRow('Invoice Number', data.name),
                          _buildDetailRow('Customer', data.customer),
                          _buildDetailRow('Company', data.company),
                          _buildDetailRow('Posting Date', data.postingDate),
                          _buildDetailRow('Due Date', data.postingDate),

                          const Divider(height: 30),

                          // Totals
                          _buildTotalRow(
                            'Grand Total',
                            'KES ${data.grandTotal.toStringAsFixed(2)}',
                            Colors.black,
                            FontWeight.w400,
                          ),
                          _buildTotalRow(
                            'Outstanding Amount',
                            'KES ${data.outstandingAmount.toStringAsFixed(2)}',
                            Colors.red,
                            FontWeight.w400,
                          ),

                          const SizedBox(height: 16),

                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                data.docstatus == 1 ? "paid" : "unpaid",
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              data.docstatus == 1 ? "paid" : "unpaid",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                const Spacer(),

                // Action Buttons - Updated styling
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _isPrinting || _pdfBytes == null
                            ? null
                            : _printInvoice,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _isPrinting || _pdfBytes == null
                                  ? Colors.grey
                                  : Colors.blue,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.zero,
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_isPrinting)
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(
                                        Colors.blue,
                                      ),
                                    ),
                                  )
                                else
                                  const Icon(Icons.print, color: Colors.blue),
                                const SizedBox(width: 8),
                                Text(
                                  _isPrinting ? 'Printing...' : 'Print',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: _isPrinting || _pdfBytes == null
                                        ? Colors.grey
                                        : Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: _isDownloading || _pdfBytes == null
                            ? null
                            : _downloadPdf,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _isDownloading || _pdfBytes == null
                                  ? Colors.grey
                                  : Colors.blue,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.zero,
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_isDownloading)
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(
                                        Colors.blue,
                                      ),
                                    ),
                                  )
                                else
                                  const Icon(
                                    Icons.download,
                                    color: Colors.blue,
                                  ),
                                const SizedBox(width: 8),
                                Text(
                                  _isDownloading
                                      ? 'Generating...'
                                      : 'Download PDF',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: _isDownloading || _pdfBytes == null
                                        ? Colors.grey
                                        : Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // OK Button - Updated styling
                InkWell(
                  onTap: _closeAndNavigateBack,
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      border: Border.all(color: Colors.blue, width: 1.5),
                      borderRadius: BorderRadius.zero,
                    ),
                    child: const Center(
                      child: Text(
                        'OK',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label:', style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildTotalRow(
    String label,
    String value,
    Color color,
    FontWeight fontWeight,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              color: color,
              fontWeight: fontWeight,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'partially paid':
        return Colors.orange;
      case 'unpaid':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
