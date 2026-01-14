import 'package:pos/data/datasource/user_remote_datasource.dart';
import 'package:pos/domain/models/invoice_model.dart';
import 'package:pos/domain/models/invoice_model_get.dart';
import 'package:pos/domain/models/payment_method_model.dart';
import 'package:pos/domain/models/pos_session_model.dart';
import 'package:pos/domain/repository/abstract_sales_repository.dart';

class SalesRepositoryImpl implements SalesRepository {
  final RemoteDataSource dataSource;

  SalesRepositoryImpl({required this.dataSource});

  @override
  Future<List<PaymentMethod>> fetchPaymentMethods({
    required String company,
    bool onlyEnabled = true,
  }) async {
    try {
      final response = await dataSource.getPaymentMethods(
        company: company,
        onlyEnabled: onlyEnabled,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to fetch payment methods: $e');
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
    try {
      final response = await dataSource.createInvoice(request);
      return response;
    } catch (e) {
      rethrow;
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
}
