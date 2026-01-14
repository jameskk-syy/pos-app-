import 'package:pos/domain/models/invoice_model.dart';
import 'package:pos/domain/models/invoice_model_get.dart';
import 'package:pos/domain/models/payment_method_model.dart';
import 'package:pos/domain/models/pos_session_model.dart';

abstract class SalesRepository {
  Future<List<PaymentMethod>> fetchPaymentMethods({
    required String company,
    bool onlyEnabled = true,
  });

  Future<POSSessionResponse> createPOSSession({
    required POSSessionRequest request,
  });

  Future<CreateInvoiceResponse> createInvoice({
    required InvoiceRequest request,
  });

  Future<GetSalesInvoiceResponse> getSalesInvoice({
    required String invoiceName,
  });

  Future<ClosePOSSessionResponse> closePOSSession({
    required ClosePOSSessionRequest request,
  });
}
