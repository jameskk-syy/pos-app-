import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pos/screens/pages/point_of_sale/product_page.dart';
import 'package:printing/printing.dart';
import 'package:pos/domain/models/invoice_model.dart';

class InvoiceDetailsWidget extends StatefulWidget {
  final CreateInvoiceResponse response;

  const InvoiceDetailsWidget({super.key, required this.response});

  @override
  State<InvoiceDetailsWidget> createState() => _InvoiceDetailsWidgetState();
}

class _InvoiceDetailsWidgetState extends State<InvoiceDetailsWidget> {
  bool _isPrinting = false;
  bool _isDownloading = false;
  Uint8List? _pdfBytes;

  @override
  void initState() {
    super.initState();
    // Load PDF when widget initializes
    _generatePdf();
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

  Future<Uint8List> _createInvoicePdf() async {
    final pdf = pw.Document();

    final data = widget.response.data;
    if (data == null) {
      throw Exception('No invoice data available');
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Text(
                  'INVOICE',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Invoice Number: ${data.name}'),
                      pw.Text('Customer: ${data.customer}'),
                      pw.Text('Posting Date: ${data.postingDate}'),
                      pw.Text('Due Date: ${data.postingDate}'),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Grand Total',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'KES ${data.grandTotal.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'Outstanding: KES ${data.outstandingAmount.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              pw.Divider(),
              pw.SizedBox(height: 20),

              // Status
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  'Status: ${data.docstatus == 1 ? "paid" : "unpaid"}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ),

              pw.SizedBox(height: 20),

              // Footer
              pw.Center(
                child: pw.Text(
                  'Thank you for your business!',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontStyle: pw.FontStyle.italic,
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
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context2) => ProductsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.response.data;

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        _closeAndNavigateBack();
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Invoice Details'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _closeAndNavigateBack,
            ),
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
