import 'package:pos/core/services/connectivity_service.dart';
import 'package:pos/data/datasource/local_datasource.dart';
import 'package:pos/data/datasource/sales_remote_datasource.dart';
import 'package:pos/domain/repository/dashboard_repo.dart';
import 'package:pos/domain/requests/sales/dashboard_request.dart';
import 'package:pos/domain/responses/sales/dashboard_response.dart';
import 'package:pos/domain/models/top_selling_item_model.dart';
import 'package:pos/domain/models/invoice_list_model.dart';
import 'package:pos/domain/responses/purchase/purchase_invoice_response.dart';
import 'package:pos/data/datasource/purchase_remote_datasource.dart';

class DashboardRepoImpl implements DashboardRepo {
  final SalesRemoteDataSource remoteDataSource;
  final PurchaseRemoteDataSource purchaseRemoteDataSource;
  final ConnectivityService connectivityService;
  final LocalDataSource localDataSource;

  DashboardRepoImpl({
    required this.remoteDataSource,
    required this.purchaseRemoteDataSource,
    required this.connectivityService,
    required this.localDataSource,
  });

  @override
  Future<DashboardResponse> getDashboardStats(
    DashboardRequest dashboardRequest,
  ) async {
    final isConnected = await connectivityService.checkNow();

    if (isConnected) {
      try {
        final response = await remoteDataSource.getDashboardData(
          dashboardRequest,
        );

        if (response.success && response.data != null) {
          await localDataSource.cacheDashboardData(response.toJson());
        }

        return response;
      } catch (e) {
        final cached = localDataSource.getCachedDashboardData();
        if (cached != null) {
          return DashboardResponse.fromJson(cached);
        }
        rethrow;
      }
    } else {
      final cached = localDataSource.getCachedDashboardData();
      if (cached != null) {
        return DashboardResponse.fromJson(cached);
      } else {
        throw Exception(
          'No internet connection and no cached dashboard data available.',
        );
      }
    }
  }

  @override
  Future<TopSellingItemResponse> getTopSellingItems({
    required String company,
    String? warehouse,
    String? period,
    int limit = 10,
  }) async {
    final isConnected = await connectivityService.checkNow();
    if (isConnected) {
      return await remoteDataSource.getTopSellingItems(
        company: company,
        warehouse: warehouse,
        period: period,
        limit: limit,
      );
    } else {
      throw Exception('No internet connection');
    }
  }

  @override
  Future<InvoiceListResponse> getLatestOrders({
    required String company,
    int limit = 5,
    int limitStart = 0,
    String? orderBy,
  }) async {
    final isConnected = await connectivityService.checkNow();
    if (isConnected) {
      return await remoteDataSource.listSalesInvoices(
        company: company,
        limit: limit,
        offset: limitStart,
        orderBy: orderBy,
      );
    } else {
      throw Exception('No internet connection');
    }
  }

  @override
  Future<PurchaseInvoiceResponse> getRecentPurchases({
    required String company,
    int page = 1,
    int pageSize = 5,
  }) async {
    final isConnected = await connectivityService.checkNow();
    if (isConnected) {
      return await purchaseRemoteDataSource.getPurchaseInvoices(
        company: company,
        page: page,
        pageSize: pageSize,
      );
    } else {
      throw Exception('No internet connection');
    }
  }
}
