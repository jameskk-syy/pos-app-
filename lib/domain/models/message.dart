import 'package:pos/domain/models/pos.dart';
import 'package:pos/domain/models/user.dart';

class Message {
  final User user;
  final String? apiKey;
  final String apiSecret;
  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final String expiresAt;
  final String refreshToken;
  final bool emailVerified;
  final bool? phoneVerified;
  final String message;
  final PosIndustry posIndustry;

  Message({
    required this.user,
    this.apiKey,
    required this.apiSecret,
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.expiresAt,
    required this.refreshToken,
    required this.emailVerified,
    this.phoneVerified,
    required this.message,
    required this.posIndustry,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      user: User.fromJson(json['user']),
      apiKey: json['api_key'],
      apiSecret: json['api_secret'],
      accessToken: json['access_token'],
      tokenType: json['token_type'],
      expiresIn: json['expires_in'],
      expiresAt: json['expires_at'],
      refreshToken: json['refresh_token'],
      emailVerified: json['email_verified'],
      phoneVerified: json['phone_verified'],
      message: json['message'],
      posIndustry: PosIndustry.fromJson(json['pos_industry']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'api_key': apiKey,
      'api_secret': apiSecret,
      'access_token': accessToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
      'expires_at': expiresAt,
      'refresh_token': refreshToken,
      'email_verified': emailVerified,
      'phone_verified': phoneVerified,
      'message': message,
      'pos_industry': posIndustry.toJson(),
    };
  }
}
