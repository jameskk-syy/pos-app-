import 'package:pos/data/datasource/biller_remote_datasource.dart';
import 'package:pos/domain/repository/biller_repo.dart';
import 'package:pos/domain/requests/biller/biller_requests.dart';
import 'package:pos/domain/responses/biller/biller_responses.dart';

class BillerRepoImpl implements BillerRepo {
  final BillerRemoteDatasource remoteDataSource;

  BillerRepoImpl({required this.remoteDataSource});

  @override
  Future<UserContextResponse> getUserContext() async {
    return await remoteDataSource.getUserContext();
  }

  @override
  Future<SetActiveBillerResponse> setActiveBiller(
      SetActiveBillerRequest request) async {
    return await remoteDataSource.setActiveBiller(request);
  }

  @override
  Future<BillerDetailsResponse> getBillerDetails(
      GetBillerDetailsRequest request) async {
    return await remoteDataSource.getBillerDetails(request);
  }

  @override
  Future<ListBillersResponse> listBillers(ListBillersRequest request) async {
    return await remoteDataSource.listBillers(request);
  }

  @override
  Future<CreateBillerResponse> createBiller(CreateBillerRequest request) async {
    return await remoteDataSource.createBiller(request);
  }
}
