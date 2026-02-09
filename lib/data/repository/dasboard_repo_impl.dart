import 'package:pos/core/services/connectivity_service.dart';
import 'package:pos/data/datasource/local_datasource.dart';
import 'package:pos/data/datasource/sales_remote_datasource.dart';
import 'package:pos/domain/repository/dashboard_repo.dart';
import 'package:pos/domain/requests/sales/dashboard_request.dart';
import 'package:pos/domain/responses/sales/dashboard_response.dart';

class DashboardRepoImpl implements DashboardRepo {
  final SalesRemoteDataSource remoteDataSource;
  final ConnectivityService connectivityService;
  final LocalDataSource localDataSource;

  DashboardRepoImpl({
    required this.remoteDataSource,
    required this.connectivityService,
    required this.localDataSource,
  });

  @override
  Future<DashboardResponse> getDashboardStats(
    DashboardRequest dashboardRequest,
  ) async {
    final isConnected = await connectivityService.checkNow();

    if (isConnected) {
      try {
        // Fetch from API
        final response = await remoteDataSource.getDashboardData(
          dashboardRequest,
        );

        // Cache the response for offline use
        if (response.success && response.data != null) {
          await localDataSource.cacheDashboardData(response.toJson());
        }

        return response;
      } catch (e) {
        // If API fails but we're online, try cache as fallback
        final cached = localDataSource.getCachedDashboardData();
        if (cached != null) {
          return DashboardResponse.fromJson(cached);
        }
        rethrow;
      }
    } else {
      // Offline: Return cached data
      final cached = localDataSource.getCachedDashboardData();
      if (cached != null) {
        return DashboardResponse.fromJson(cached);
      } else {
        throw Exception(
          'No internet connection and no cached dashboard data available.',
        );
      }
    }
  }
}
