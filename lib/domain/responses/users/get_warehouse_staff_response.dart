class GetWarehouseStaffResponse {
  final Message message;

  GetWarehouseStaffResponse({required this.message});

  factory GetWarehouseStaffResponse.fromJson(Map<String, dynamic> json) {
    return GetWarehouseStaffResponse(
      message: json['message'] != null
          ? Message.fromJson(json['message'])
          : Message.empty(),
    );
  }
}

class Message {
  final bool success;
  final List<WarehouseStaff> data;
  final int count;
  final String warehouse;

  Message({
    required this.success,
    required this.data,
    required this.count,
    required this.warehouse,
  });

  factory Message.empty() =>
      Message(success: false, data: [], count: 0, warehouse: "");

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      success: json['success'] ?? false,
      data: json['data'] != null && json['data'] is List
          ? (json['data'] as List)
                .map((i) => WarehouseStaff.fromJson(i))
                .toList()
          : [],
      count: json['count'] ?? 0,
      warehouse: json['warehouse'] ?? "",
    );
  }
}

class WarehouseStaff {
  final String name;
  final String email;
  final String firstName;
  final String lastName;
  final String fullName;
  final int enabled;

  WarehouseStaff({
    required this.name,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.enabled,
  });

  factory WarehouseStaff.fromJson(Map<String, dynamic> json) {
    return WarehouseStaff(
      name: json['name'] ?? "",
      email: json['email'] ?? "",
      firstName: json['first_name'] ?? "",
      lastName: json['last_name'] ?? "",
      fullName: json['full_name'] ?? "",
      enabled: json['enabled'] ?? 0,
    );
  }
}
