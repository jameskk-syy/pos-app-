import 'package:pos/domain/requests/create_grn_request.dart';
import 'package:pos/domain/requests/create_purchase_order_request.dart';
import 'package:pos/domain/requests/submit_purchase_order_request.dart';
import 'package:pos/domain/responses/create_grn_response.dart';
import 'package:pos/domain/responses/create_purchase_order_response.dart';
import 'package:pos/domain/responses/purchase_order_detail_response.dart';
import 'package:pos/domain/responses/purchase_order_response.dart';
import 'package:pos/domain/responses/submit_purchase_order_response.dart';

abstract class PurchaseRepo {
  Future<PurchaseOrderResponse> getPurchaseOrders({
    required String company,
    int limit = 20,
    int offset = 0,
    String? status,
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
}
