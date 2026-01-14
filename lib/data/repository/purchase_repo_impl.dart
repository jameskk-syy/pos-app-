import 'package:pos/data/datasource/user_remote_datasource.dart';
import 'package:pos/domain/repository/purchase_repo.dart';
import 'package:pos/domain/requests/create_grn_request.dart';
import 'package:pos/domain/requests/create_purchase_order_request.dart';
import 'package:pos/domain/requests/submit_purchase_order_request.dart';
import 'package:pos/domain/responses/create_grn_response.dart';
import 'package:pos/domain/responses/create_purchase_order_response.dart';
import 'package:pos/domain/responses/purchase_order_detail_response.dart';
import 'package:pos/domain/responses/purchase_order_response.dart';
import 'package:pos/domain/responses/submit_purchase_order_response.dart';

class PurchaseRepoImpl implements PurchaseRepo {
  final RemoteDataSource remoteDataSource;

  PurchaseRepoImpl({required this.remoteDataSource});

  @override
  Future<PurchaseOrderResponse> getPurchaseOrders({
    required String company,
    int limit = 20,
    int offset = 0,
    String? status,
    Map<String, dynamic>? filters,
  }) async {
    return await remoteDataSource.getPurchaseOrders(
      company: company,
      limit: limit,
      offset: offset,
      status: status,
    );
  }
  @override
Future<CreatePurchaseOrderResponse> createPurchaseOrder({
  required CreatePurchaseOrderRequest request,
}) async {
  return await remoteDataSource.createPurchaseOrder(request: request);
}
 @override
  Future<SubmitPurchaseOrderResponse> submitPurchaseOrder({
    required SubmitPurchaseOrderRequest request,
  }) async {
    return await remoteDataSource.submitPurchaseOrder(request: request);
  }
  @override
Future<CreateGrnResponse> createGrn({
  required CreateGrnRequest request,
}) async {
  return await remoteDataSource.createGrn(request: request);
}
@override
Future<PurchaseOrderDetailResponse> getPurchaseOrderDetail({
  required String poName,
}) async {
  return await remoteDataSource.getPurchaseOrderDetail(poName: poName);
}
}
