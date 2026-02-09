import 'package:pos/domain/requests/sales/create_pos_request.dart';
import 'package:pos/domain/responses/sales/pos_create_response.dart';

abstract class PosProfileRepo {
  Future<CompanyProfileResponse> createPosProfile(CompanyProfileRequest posRequest);
}
