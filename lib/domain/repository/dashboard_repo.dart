import 'package:pos/domain/requests/dashboard_request.dart';
import 'package:pos/domain/responses/dashboard_response.dart';

abstract class DashboardRepo {
  Future<DashboardResponse> getDashboardStats(DashboardRequest dashboardRequest);
}
