import 'package:pos/domain/requests/biller/biller_requests.dart';
import 'package:pos/domain/responses/biller/biller_responses.dart';

abstract class BillerRepo {
  Future<UserContextResponse> getUserContext();
  Future<SetActiveBillerResponse> setActiveBiller(
      SetActiveBillerRequest request);
  Future<BillerDetailsResponse> getBillerDetails(
      GetBillerDetailsRequest request);
  Future<ListBillersResponse> listBillers(ListBillersRequest request);
  Future<CreateBillerResponse> createBiller(CreateBillerRequest request);
}
