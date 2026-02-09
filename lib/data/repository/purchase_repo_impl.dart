import 'package:pos/data/datasource/purchase_remote_datasource.dart';
import 'package:pos/domain/repository/purchase_repo.dart';
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

class PurchaseRepoImpl implements PurchaseRepo {
  final PurchaseRemoteDataSource purchaseRemoteDataSource;

  PurchaseRepoImpl({required this.purchaseRemoteDataSource});

  @override
  Future<PurchaseOrderResponse> getPurchaseOrders({
    required String company,
    int limit = 20,
    int offset = 0,
    String? status,
    String? searchTerm,
    Map<String, dynamic>? filters,
  }) async {
    return await purchaseRemoteDataSource.getPurchaseOrders(
      company: company,
      limit: limit,
      offset: offset,
      status: status,
      searchTerm: searchTerm,
      filters: filters,
    );
  }

  @override
  Future<CreatePurchaseOrderResponse> createPurchaseOrder({
    required CreatePurchaseOrderRequest request,
  }) async {
    return await purchaseRemoteDataSource.createPurchaseOrder(request: request);
  }

  @override
  Future<SubmitPurchaseOrderResponse> submitPurchaseOrder({
    required SubmitPurchaseOrderRequest request,
  }) async {
    return await purchaseRemoteDataSource.submitPurchaseOrder(request: request);
  }

  @override
  Future<CreateGrnResponse> createGrn({
    required CreateGrnRequest request,
  }) async {
    return await purchaseRemoteDataSource.createGrn(request: request);
  }

  @override
  Future<PurchaseOrderDetailResponse> getPurchaseOrderDetail({
    required String poName,
  }) async {
    return await purchaseRemoteDataSource.getPurchaseOrderDetail(
      poName: poName,
    );
  }

  @override
  Future<PurchaseInvoiceResponse> getPurchaseInvoices({
    int page = 1,
    int pageSize = 20,
    String? company,
    String? status,
    String? supplier,
  }) async {
    return await purchaseRemoteDataSource.getPurchaseInvoices(
      page: page,
      pageSize: pageSize,
      company: company,
      status: status,
      supplier: supplier,
    );
  }

  @override
  Future<PurchaseInvoiceDetailResponse> getPurchaseInvoiceDetails({
    required String invoiceNo,
  }) async {
    return await purchaseRemoteDataSource.getPurchaseInvoiceDetails(invoiceNo);
  }

  @override
  Future<GrnListResponse> getGrnList({
    int page = 1,
    int pageSize = 20,
    String? company,
    String? supplier,
    String? searchTerm,
  }) async {
    return await purchaseRemoteDataSource.getGrnList(
      page: page,
      pageSize: pageSize,
      company: company,
      supplier: supplier,
      searchTerm: searchTerm,
    );
  }

  @override
  Future<GrnDetailResponse> getGrnDetails(String grnNo) async {
    return await purchaseRemoteDataSource.getGrnDetails(grnNo);
  }

  @override
  Future<void> createPurchaseInvoiceFromGrn({
    required String grnNo,
    required bool doNotSubmit,
    required String billDate,
    String? fileBase64,
    String? fileName,
  }) async {
    return await purchaseRemoteDataSource.createPurchaseInvoiceFromGrn(
      grnNo: grnNo,
      doNotSubmit: doNotSubmit,
      billDate: billDate,
      fileBase64: fileBase64,
      fileName: fileName,
    );
  }

  @override
  Future<PayPurchaseInvoiceResponse> payPurchaseInvoice({
    required PayPurchaseInvoiceRequest request,
  }) async {
    return await purchaseRemoteDataSource.payPurchaseInvoice(request: request);
  }
}
