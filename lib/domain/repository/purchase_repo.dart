import 'package:pos/domain/requests/purchase/create_grn_request.dart';
import 'package:pos/domain/requests/purchase/create_purchase_order_request.dart';
import 'package:pos/domain/requests/purchase/submit_purchase_order_request.dart';
import 'package:pos/domain/responses/purchase/create_grn_response.dart';
import 'package:pos/domain/responses/purchase/create_purchase_order_response.dart';
import 'package:pos/domain/responses/purchase/purchase_order_detail_response.dart';
import 'package:pos/domain/responses/purchase/purchase_order_response.dart';
import 'package:pos/domain/responses/purchase/purchase_invoice_detail_response.dart';
import 'package:pos/domain/responses/purchase/purchase_invoice_response.dart';
import 'package:pos/domain/responses/purchase/submit_purchase_order_response.dart';
import 'package:pos/domain/responses/purchase/grn_response.dart';
import 'package:pos/domain/responses/purchase/grn_detail_response.dart';
import 'package:pos/domain/requests/purchase/pay_purchase_invoice_request.dart';
import 'package:pos/domain/responses/purchase/pay_purchase_invoice_response.dart';

abstract class PurchaseRepo {
  Future<PurchaseOrderResponse> getPurchaseOrders({
    required String company,
    int limit = 20,
    int offset = 0,
    String? status,
    String? searchTerm,
    Map<String, dynamic>? filters,
  });
  Future<CreatePurchaseOrderResponse> createPurchaseOrder({
    required CreatePurchaseOrderRequest request,
  });
  Future<SubmitPurchaseOrderResponse> submitPurchaseOrder({
    required SubmitPurchaseOrderRequest request,
  });
  Future<CreateGrnResponse> createGrn({required CreateGrnRequest request});
  Future<PurchaseOrderDetailResponse> getPurchaseOrderDetail({
    required String poName,
  });
  Future<PurchaseInvoiceResponse> getPurchaseInvoices({
    int page = 1,
    int pageSize = 20,
    String? company,
    String? status,
    String? supplier,
  });
  Future<PurchaseInvoiceDetailResponse> getPurchaseInvoiceDetails({
    required String invoiceNo,
  });

  Future<GrnListResponse> getGrnList({
    int page = 1,
    int pageSize = 20,
    String? company,
    String? supplier,
    String? searchTerm,
  });

  Future<GrnDetailResponse> getGrnDetails(String grnNo);

  Future<void> createPurchaseInvoiceFromGrn({
    required String grnNo,
    required bool doNotSubmit,
    required String billDate,
    String? fileBase64,
    String? fileName,
  });

  Future<PayPurchaseInvoiceResponse> payPurchaseInvoice({
    required PayPurchaseInvoiceRequest request,
  });
}
