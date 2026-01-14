import 'dart:convert';

class CompanyProfileResponse {
  final MessageData message;
  final String serverMessages;

  CompanyProfileResponse({
    required this.message,
    required this.serverMessages,
  });

  factory CompanyProfileResponse.fromJson(Map<String, dynamic> json) {
    return CompanyProfileResponse(
      message: MessageData.fromJson(json['message']),
      serverMessages: json['_server_messages'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message.toJson(),
      '_server_messages': serverMessages,
    };
  }

  // Helper method to parse server messages
  List<ServerMessage> get parsedServerMessages {
    try {
      final serverMessagesList = json.decode(serverMessages) as List;
      return serverMessagesList.map((msg) {
        final messageString = msg as String;
        final messageJson = json.decode(messageString);
        return ServerMessage.fromJson(messageJson);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  String toString() {
    return 'CompanyProfileResponse(message: $message, serverMessages: $serverMessages)';
  }
}

class MessageData {
  final PosProfile posProfile;
  final String message;

  MessageData({
    required this.posProfile,
    required this.message,
  });

  factory MessageData.fromJson(Map<String, dynamic> json) {
    return MessageData(
      posProfile: PosProfile.fromJson(json['pos_profile']),
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pos_profile': posProfile.toJson(),
      'message': message,
    };
  }

  @override
  String toString() {
    return 'MessageData(posProfile: $posProfile, message: $message)';
  }
}

class PosProfile {
  final String name;
  final String company;
  final String warehouse;
  final String currency;

  PosProfile({
    required this.name,
    required this.company,
    required this.warehouse,
    required this.currency,
  });

  factory PosProfile.fromJson(Map<String, dynamic> json) {
    return PosProfile(
      name: json['name'] as String,
      company: json['company'] as String,
      warehouse: json['warehouse'] as String,
      currency: json['currency'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'company': company,
      'warehouse': warehouse,
      'currency': currency,
    };
  }

  @override
  String toString() {
    return 'PosProfile(name: $name, company: $company, warehouse: $warehouse, currency: $currency)';
  }
}

// ServerMessage class for parsing nested server messages
class ServerMessage {
  final String message;
  final String title;

  ServerMessage({
    required this.message,
    required this.title,
  });

  factory ServerMessage.fromJson(Map<String, dynamic> json) {
    return ServerMessage(
      message: json['message'] as String,
      title: json['title'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'title': title,
    };
  }

  @override
  String toString() {
    return 'ServerMessage(message: $message, title: $title)';
  }
}