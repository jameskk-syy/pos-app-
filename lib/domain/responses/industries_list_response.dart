class IndustriesResponse {
  final IndustriesMessage message;

  IndustriesResponse({required this.message});

  factory IndustriesResponse.fromJson(Map<String, dynamic> json) {
    return IndustriesResponse(
      message: IndustriesMessage.fromJson(json['message']),
    );
  }
}

class IndustriesMessage {
  final bool success;
  final List<Industry> industries;
  final int count;
  final String message;

  IndustriesMessage({
    required this.success,
    required this.industries,
    required this.count,
    required this.message,
  });

  factory IndustriesMessage.fromJson(Map<String, dynamic> json) {
    return IndustriesMessage(
      success: json['success'] ?? false,
      industries: json['industries'] != null
          ? List<Industry>.from(
              json['industries'].map((x) => Industry.fromJson(x)),
            )
          : [],
      count: _parseToInt(json['count']),
      message: json['message'] ?? '',
    );
  }

  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

class Industry {
  final String name;
  final String industryCode;
  final String industryName;
  final String description;
  final String servingLocation;
  final int isActive;
  final int sortOrder;

  Industry({
    required this.name,
    required this.industryCode,
    required this.industryName,
    required this.description,
    required this.servingLocation,
    required this.isActive,
    required this.sortOrder,
  });

  factory Industry.fromJson(Map<String, dynamic> json) {
    return Industry(
      name: json['name'] ?? '',
      industryCode: json['industry_code'] ?? '',
      industryName: json['industry_name'] ?? '',
      description: json['description'] ?? '',
      servingLocation: json['serving_location'] ?? '',
      isActive: _parseToInt(json['is_active']),
      sortOrder: _parseToInt(json['sort_order']),
    );
  }

  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}