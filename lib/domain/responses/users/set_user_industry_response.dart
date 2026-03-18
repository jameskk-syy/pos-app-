import 'package:pos/domain/responses/industries_list_response.dart';

class SetUserIndustryResponse {
  final SetUserIndustryMessage message;

  SetUserIndustryResponse({required this.message});

  factory SetUserIndustryResponse.fromJson(Map<String, dynamic> json) {
    return SetUserIndustryResponse(
      message: SetUserIndustryMessage.fromJson(json['message']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message.toJson()};
  }
}

class SetUserIndustryMessage {
  final bool success;
  final Industry? industry;
  final String message;

  SetUserIndustryMessage({
    required this.success,
    this.industry,
    required this.message,
  });

  factory SetUserIndustryMessage.fromJson(Map<String, dynamic> json) {
    return SetUserIndustryMessage(
      success: json['success'] ?? false,
      industry: json['industry'] != null
          ? Industry.fromJson(json['industry'])
          : null,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'industry': industry?.toJson(),
      'message': message,
    };
  }
}
