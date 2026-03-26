import 'package:pos/domain/requests/sales/dashboard_request.dart';
import 'package:pos/domain/responses/sales/dashboard_response.dart';
import 'package:pos/domain/models/top_selling_item_model.dart';
import 'package:pos/domain/models/invoice_list_model.dart';
import 'package:pos/domain/responses/purchase/purchase_invoice_response.dart';

abstract class DashboardRepo {
  Future<DashboardResponse> getDashboardStats(DashboardRequest dashboardRequest);

  Future<TopSellingItemResponse> getTopSellingItems({
    required String company,
    String? warehouse,
    String? period,
    int limit = 10,
  });

  Future<InvoiceListResponse> getLatestOrders({
    required String company,
    int limit = 5,
    int limitStart = 0,
    String? orderBy,
  });

  Future<PurchaseInvoiceResponse> getRecentPurchases({
    required String company,
    int page = 1,
    int pageSize = 5,
  });
}
