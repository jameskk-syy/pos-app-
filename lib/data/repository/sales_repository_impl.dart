import 'package:pos/core/services/connectivity_service.dart';
import 'package:pos/data/datasource/local_datasource.dart';
import 'package:pos/data/datasource/sales_remote_datasource.dart';
import 'package:pos/domain/models/invoice_model.dart';
import 'package:pos/domain/models/invoice_model_get.dart';
import 'package:pos/domain/models/payment_method_model.dart';
import 'package:pos/domain/models/pos_session_model.dart';
import 'package:pos/domain/repository/abstract_sales_repository.dart';

class SalesRepositoryImpl implements SalesRepository {
  final SalesRemoteDataSource dataSource;

  final ConnectivityService connectivityService;
  final LocalDataSource localDataSource;

  SalesRepositoryImpl({
    required this.dataSource,
    required this.connectivityService,
    required this.localDataSource,
  });

  @override
  @override
  Future<List<PaymentMethod>> fetchPaymentMethods({
    required String company,
    bool onlyEnabled = true,
  }) async {
    final isConnected = await connectivityService.checkNow();
    if (isConnected) {
      try {
        final response = await dataSource.getPaymentMethods(
          company: company,
          onlyEnabled: onlyEnabled,
        );
        // Cache them
        await localDataSource.cachePaymentMethods(
          response.map((e) => e.toJson()).toList(),
        );
        return response;
      } catch (e) {
        throw Exception('Failed to fetch payment methods: $e');
      }
    } else {
      // Offline fallback
      final cached = localDataSource.getCachedPaymentMethods();
      if (cached.isNotEmpty) {
        return cached.map((e) => PaymentMethod.fromJson(e)).toList();
      } else {
        throw Exception(
          'No internet connection and no cached payment methods.',
        );
      }
    }
  }

  @override
  Future<POSSessionResponse> createPOSSession({
    required POSSessionRequest request,
  }) async {
    try {
      final response = await dataSource.createPOSSession(request);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CreateInvoiceResponse> createInvoice({
    required InvoiceRequest request,
  }) async {
    final isConnected = await connectivityService.checkNow();
    if (isConnected) {
      try {
        final response = await dataSource.createInvoice(request);
        return response;
      } catch (e) {
        rethrow;
      }
    } else {
      // Offline: Save to Hive
      try {
        await localDataSource.saveOfflineSale(request.toJson());

        // Return a mock success response
        return CreateInvoiceResponse(
          success: true,
          message: "Sale saved offline. Please sync when online.",
          data: InvoiceResponse(
            name: "OFFLINE-${DateTime.now().millisecondsSinceEpoch}",
            customer: request.customer,
            company: request.company,
            postingDate: request.postingDate,
            grandTotal: request.payments.fold(0, (sum, p) => sum + p.amount),
            roundedTotal: request.payments.fold(0, (sum, p) => sum + p.amount),
            outstandingAmount: 0,
            docstatus: 0,
          ),
        );
      } catch (e) {
        throw Exception('Failed to save offline sale: $e');
      }
    }
  }

  @override
  Future<GetSalesInvoiceResponse> getSalesInvoice({
    required String invoiceName,
  }) async {
    try {
      final response = await dataSource.getSalesInvoice(
        invoiceName: invoiceName,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to fetch sales invoice: $e');
    }
  }

  @override
  Future<ClosePOSSessionResponse> closePOSSession({
    required ClosePOSSessionRequest request,
  }) async {
    try {
      final response = await dataSource.closePOSSession(request);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> createCreditModeOfPayment({
    required Map<String, dynamic> request,
  }) async {
    try {
      final response = await dataSource.createCreditModeOfPayment(
        request: request,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getReceivableAccount({
    required String customer,
    required String company,
  }) async {
    try {
      final response = await dataSource.getReceivableAccount(
        customer: customer,
        company: company,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
