import 'package:pos/domain/requests/sales/dashboard_request.dart';
import 'package:pos/domain/responses/sales/dashboard_response.dart';

abstract class DashboardRepo {
  Future<DashboardResponse> getDashboardStats(DashboardRequest dashboardRequest);
}
