import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pos/domain/models/reports/sales_analytics_model.dart';
import 'package:pos/domain/models/reports/inventory_reports_model.dart';
import 'package:pos/domain/models/reports/stock_movement_model.dart';
import 'package:pos/domain/models/reports/performance_metrics_model.dart';
import 'package:printing/printing.dart';

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
}
