import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pos/domain/models/reports/sales_analytics_model.dart';
import 'package:pos/domain/models/reports/inventory_reports_model.dart';
import 'package:pos/domain/models/reports/stock_movement_model.dart';
import 'package:pos/domain/models/reports/performance_metrics_model.dart';
import 'package:printing/printing.dart';
import 'package:pos/domain/responses/purchase/purchase_order_detail_response.dart';
import 'package:pos/domain/responses/purchase/purchase_invoice_detail_response.dart';
import 'package:pos/domain/responses/purchase/grn_detail_response.dart';

class ReportPdfGenerator {
  Future<void> generateSalesAnalyticsPdf(
    SalesAnalyticsData data,
    String currency,
  ) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.openSansRegular();
    final boldFont = await PdfGoogleFonts.openSansBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Sales Analytics Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            _buildSalesSummary(data.summary, currency),
            pw.SizedBox(height: 20),
            pw.Text(
              'Daily Sales',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            _buildDailySalesTable(data.dailySales, currency),
            pw.SizedBox(height: 20),
            pw.Text(
              'Revenue by Item Group',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            _buildRevenueByGroupTable(data.revenueByItemGroup, currency),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.Widget _buildSalesSummary(SalesSummary summary, String currency) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        _buildMetricBox(
          'Total Revenue',
          '$currency ${_formatCurrency(summary.totalRevenue)}',
        ),
        _buildMetricBox('Total Invoices', '${summary.totalInvoices}'),
        _buildMetricBox(
          'Avg Order Value',
          '$currency ${_formatCurrency(summary.averageOrderValue)}',
        ),
      ],
    );
  }

  pw.Widget _buildMetricBox(String title, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        children: [
          pw.Text(title, style: const pw.TextStyle(color: PdfColors.grey700)),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildDailySalesTable(List<DailySales> data, String currency) {
    return pw.TableHelper.fromTextArray(
      headers: ['Date', 'Total Amount', 'Qty', 'Invoices'],
      data: data
          .map(
            (item) => [
              item.date,
              '$currency ${_formatCurrency(item.totalAmount)}',
              item.totalQty.toString(),
              item.invoiceCount.toString(),
            ],
          )
          .toList(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
      },
    );
  }

  pw.Widget _buildRevenueByGroupTable(
    List<RevenueByItemGroup> data,
    String currency,
  ) {
    return pw.TableHelper.fromTextArray(
      headers: ['Item Group', 'Revenue', 'Qty', 'Percentage'],
      data: data
          .map(
            (item) => [
              item.itemGroup,
              '$currency ${_formatCurrency(item.totalRevenue)}',
              item.totalQty.toString(),
              '${item.percentage.toStringAsFixed(1)}%',
            ],
          )
          .toList(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
      },
    );
  }

  Future<void> generateInventoryValuationPdf(
    List<InventoryCategoryValue> data,
    String currency,
  ) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.openSansRegular();
    final boldFont = await PdfGoogleFonts.openSansBold();

    final totalValue = data.fold(0.0, (sum, item) => sum + item.totalValue);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Inventory Valuation Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Total Inventory Value: $currency ${_formatCurrency(totalValue)}',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headers: ['Category', 'Total Value'],
              data: data
                  .map(
                    (item) => [
                      item.itemGroup,
                      '$currency ${_formatCurrency(item.totalValue)}',
                    ],
                  )
                  .toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey200,
              ),
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerRight,
              },
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<void> generateStockMovementPdf(
    List<InventoryTurnoverData> turnoverData,
    List<DaysOnHandData> daysOnHandData,
    String currency,
  ) async {
    // Currency might not be used here but keeping signature consistent
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.openSansRegular();
    final boldFont = await PdfGoogleFonts.openSansBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Stock Movement Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Inventory Turnover',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.TableHelper.fromTextArray(
              headers: ['Item', 'Avg Stock', 'Turnover Rate', 'Days'],
              data: turnoverData
                  .map(
                    (item) => [
                      item.itemName,
                      item.averageStock.toStringAsFixed(1),
                      item.turnoverRate.toStringAsFixed(2),
                      item.turnoverDays.toStringAsFixed(1),
                    ],
                  )
                  .toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey200,
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Days On Hand',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.TableHelper.fromTextArray(
              headers: ['Item', 'Current Stock', 'Days On Hand', 'Status'],
              data: daysOnHandData
                  .map(
                    (item) => [
                      item.itemName,
                      item.currentStock.toStringAsFixed(1),
                      item.daysOnHand.toStringAsFixed(1),
                      item.status.toUpperCase(),
                    ],
                  )
                  .toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey200,
              ),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<void> generatePerformanceMetricsPdf(
    InventoryAccuracyData accuracyData,
    List<InventoryVarianceData> varianceData,
    String currency,
  ) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.openSansRegular();
    final boldFont = await PdfGoogleFonts.openSansBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Performance Metrics Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            _buildMetricBox(
              'Inventory Accuracy',
              '${accuracyData.accuracyRate.toStringAsFixed(1)}%',
            ),
            pw.SizedBox(height: 10),
            _buildMetricBox(
              'Total Variance Value',
              '$currency ${_formatCurrency(accuracyData.totalVarianceValue)}',
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Inventory Variances',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.TableHelper.fromTextArray(
              headers: ['Item', 'Book Qty', 'Counted', 'Variance', '%'],
              data: varianceData
                  .map(
                    (item) => [
                      item.itemName,
                      item.bookQty.toString(),
                      item.countedQty.toString(),
                      item.varianceQty.toString(),
                      '${item.variancePercentage.toStringAsFixed(1)}%',
                    ],
                  )
                  .toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey200,
              ),
            ),
          ];
        },
      ),
    );
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  String _formatCurrency(double value) {
    return value
        .toStringAsFixed(2)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  Future<void> generateGrnPdf(PurchaseOrderDetail po, String grnNumber) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.openSansRegular();
    final boldFont = await PdfGoogleFonts.openSansBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Goods Received Note',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    grnNumber,
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildPdfInfoRow('Supplier:', po.supplier),
                  pw.SizedBox(height: 4),
                  _buildPdfInfoRow('Purchase Order:', po.name),
                  pw.SizedBox(height: 4),
                  _buildPdfInfoRow(
                    'Date:',
                    DateTime.now().toString().split(' ')[0],
                  ),
                  pw.SizedBox(height: 4),
                  _buildPdfInfoRow('Project:', po.company),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Received Items',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.TableHelper.fromTextArray(
              headers: ['Item Code', 'Description', 'UOM', 'Qty Received'],
              data: po.items
                  .map(
                    (item) => [
                      item.itemCode,
                      item.description,
                      item.uom,
                      item.qty.toString(),
                    ],
                  )
                  .toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey200,
              ),
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.center,
                3: pw.Alignment.centerRight,
              },
            ),
            pw.SizedBox(height: 30),
            _buildSignatureSection(),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<void> generateGrnDetailPdf(GrnDetailData grn) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.openSansRegular();
    final boldFont = await PdfGoogleFonts.openSansBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Goods Received Note',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    grn.grnNo,
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildPdfInfoRow('Supplier:', grn.supplierName),
                  pw.SizedBox(height: 4),
                  _buildPdfInfoRow('Purchase Order:', grn.purchaseOrder),
                  pw.SizedBox(height: 4),
                  _buildPdfInfoRow('Date:', grn.postingDate),
                  pw.SizedBox(height: 4),
                  _buildPdfInfoRow('Warehouse:', grn.setWarehouse),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Received Items',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.TableHelper.fromTextArray(
              headers: [
                'Item Code',
                'Item Name',
                'UOM',
                'Qty Received',
                'Amount',
              ],
              data: grn.items
                  .map(
                    (item) => [
                      item.itemCode,
                      item.itemName,
                      item.uom,
                      item.receivedQty.toString(),
                      _formatCurrency(item.amount),
                    ],
                  )
                  .toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey200,
              ),
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.center,
                3: pw.Alignment.centerRight,
                4: pw.Alignment.centerRight,
              },
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    _buildSummaryLine('Net Total:', grn.netTotal),
                    _buildSummaryLine(
                      'Grand Total:',
                      grn.grandTotal,
                      isBold: true,
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 30),
            _buildSignatureSection(),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'GRN_${grn.grnNo}',
    );
  }

  pw.Widget _buildSignatureSection() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Received By:'),
            pw.SizedBox(height: 30),
            pw.Container(
              width: 150,
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.black),
                ),
              ),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Authorized Signature:'),
            pw.SizedBox(height: 30),
            pw.Container(
              width: 150,
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.black),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildPdfInfoRow(String label, String value) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text(
          '$label ',
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey700,
          ),
        ),
        pw.Text(value),
      ],
    );
  }

  Future<void> generatePurchaseInvoicePdf(
    PurchaseInvoiceDetailData invoice,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'PURCHASE INVOICE',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.Text(invoice.invoiceNo),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        invoice.company,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text('Date: ${invoice.postingDate}'),
                      pw.Text('Status: ${invoice.status}'),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Supplier:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(invoice.supplierName),
                    pw.Text(invoice.supplier),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Due Date:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(invoice.dueDate),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headers: ['Item', 'Qty', 'UOM', 'Rate', 'Amount'],
              data: invoice.items.map((item) {
                return [
                  item.itemName,
                  item.qty.toString(),
                  item.uom,
                  _formatCurrency(item.rate),
                  _formatCurrency(item.amount),
                ];
              }).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
              cellAlignment: pw.Alignment.centerLeft,
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(1),
                2: const pw.FlexColumnWidth(1),
                3: const pw.FlexColumnWidth(2),
                4: const pw.FlexColumnWidth(2),
              },
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    _buildSummaryLine('Net Total:', invoice.netTotal),
                    _buildSummaryLine('Taxes:', invoice.totalTaxesAndCharges),
                    pw.Divider(),
                    _buildSummaryLine(
                      'Grand Total:',
                      invoice.grandTotal,
                      isBold: true,
                    ),
                    _buildSummaryLine('Paid:', invoice.paidAmount),
                    _buildSummaryLine(
                      'Outstanding:',
                      invoice.outstandingAmount,
                      isBold: true,
                    ),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Invoice_${invoice.invoiceNo}',
    );
  }

  pw.Widget _buildSummaryLine(
    String label,
    double value, {
    bool isBold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 12)),
          pw.SizedBox(width: 20),
          pw.SizedBox(
            width: 80,
            child: pw.Text(
              _formatCurrency(value),
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: isBold ? pw.FontWeight.bold : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
