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
    final dynamic rawData = json['data'];
    List<BillerProfile> billers = [];
    int totalCount = 0;

    if (rawData is List) {
      billers = rawData.map((e) => BillerProfile.fromJson(e)).toList();
      totalCount = json['total_count'] ?? billers.length;
    } else if (rawData is Map<String, dynamic>) {
      billers = (rawData['billers'] as List<dynamic>?)
              ?.map((e) => BillerProfile.fromJson(e))
              .toList() ??
          [];
      totalCount = rawData['total_count'] ?? json['total_count'] ?? billers.length;
    }

    return ListBillersResponse(
      success: json['success'] ?? false,
      billers: billers,
      totalCount: totalCount,
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
