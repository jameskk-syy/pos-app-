import 'package:pos/domain/requests/create_pos_request.dart';
import 'package:pos/domain/responses/pos_create_response.dart';

abstract class PosProfileRepo {
  Future<CompanyProfileResponse> createPosProfile(CompanyProfileRequest posRequest);
}
