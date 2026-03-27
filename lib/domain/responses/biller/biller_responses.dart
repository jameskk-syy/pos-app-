import 'package:pos/domain/models/biller_models.dart';

class UserContextResponse {
  final bool success;
  final UserContextData data;

  UserContextResponse({required this.success, required this.data});

  factory UserContextResponse.fromJson(Map<String, dynamic> json) {
    return UserContextResponse(
      success: json['success'] ?? false,
      data: UserContextData.fromJson(json['data'] ?? {}),
    );
  }
}

class SetActiveBillerResponse {
  final bool success;
  final String? message;

  SetActiveBillerResponse({required this.success, this.message});

  factory SetActiveBillerResponse.fromJson(Map<String, dynamic> json) {
    return SetActiveBillerResponse(
      success: json['success'] ?? false,
      message: json['message'],
    );
  }
}

class BillerDetailsResponse {
  final bool success;
  final BillerDetailsData data;

  BillerDetailsResponse({required this.success, required this.data});

  factory BillerDetailsResponse.fromJson(Map<String, dynamic> json) {
    return BillerDetailsResponse(
      success: json['success'] ?? false,
      data: BillerDetailsData.fromJson(json['data'] ?? {}),
    );
  }
}

class ListBillersResponse {
  final bool success;
  final List<BillerProfile> billers;
  final int totalCount;

  ListBillersResponse({
    required this.success,
    required this.billers,
    required this.totalCount,
  });

  factory ListBillersResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return ListBillersResponse(
      success: json['success'] ?? false,
      billers: (data['billers'] as List<dynamic>?)
              ?.map((e) => BillerProfile.fromJson(e))
              .toList() ??
          [],
      totalCount: data['total_count'] ?? 0,
    );
  }
}

class CreateBillerResponse {
  final bool success;
  final String? message;
  final BillerDetailsData? data;

  CreateBillerResponse({required this.success, this.message, this.data});

  factory CreateBillerResponse.fromJson(Map<String, dynamic> json) {
    return CreateBillerResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null
          ? BillerDetailsData.fromJson(json['data'])
          : null,
    );
  }
}
