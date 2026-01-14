import 'package:pos/data/datasource/user_remote_datasource.dart';
import 'package:pos/domain/repository/dashboard_repo.dart';
import 'package:pos/domain/requests/dashboard_request.dart';
import 'package:pos/domain/responses/dashboard_response.dart';

class DashboardRepoImpl implements DashboardRepo {
  final RemoteDataSource remoteDataSource;

  DashboardRepoImpl({required this.remoteDataSource});
  @override
  Future<DashboardResponse> getDashboardStats(
    DashboardRequest dashboardRequest,
  ) async {
    return await remoteDataSource.getDashboardData(dashboardRequest);
  }
}
