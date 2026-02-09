import 'package:pos/data/datasource/products_remote_datasource.dart';
import 'package:pos/domain/repository/industries_list_repo.dart';
import 'package:pos/domain/requests/products/seed_item.dart';
import 'package:pos/domain/responses/bulk_upload.dart';
import 'package:pos/domain/responses/industries_list_response.dart';
import 'package:pos/domain/responses/products/seed_items_response.dart';

class IndustriesListRepoImpl implements IndustriesRepo {
  final ProductsRemoteDataSource remoteDataSource;

  IndustriesListRepoImpl({required this.remoteDataSource});

  @override
  Future<IndustriesResponse> getIndustriesList() async {
    return await remoteDataSource.getIndustriesList();
  }

  @override
  Future<ProcessResponse> seedProducts(String industry) async {
    return await remoteDataSource.seedProducts(industry);
  }

  @override
  Future<CreateOrderResponse> seedItems(
    CreateOrderRequest createOrderRequest,
  ) async {
    return await remoteDataSource.seedItems(createOrderRequest);
  }
}
