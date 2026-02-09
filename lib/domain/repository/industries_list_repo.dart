import 'package:pos/domain/requests/products/seed_item.dart';
import 'package:pos/domain/responses/bulk_upload.dart';
import 'package:pos/domain/responses/industries_list_response.dart';
import 'package:pos/domain/responses/products/seed_items_response.dart';


abstract class IndustriesRepo {
  Future<IndustriesResponse> getIndustriesList();
  Future<ProcessResponse> seedProducts(String industry);
  Future<CreateOrderResponse> seedItems(CreateOrderRequest createOrderRequest);
}
