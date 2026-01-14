class AssignWarehousesRequest {
  final String userEmail;
  final List<String> warehouses;
  final bool replaceExisting;

  AssignWarehousesRequest({
    required this.userEmail,
    required this.warehouses,
    required this.replaceExisting,
  });

  factory AssignWarehousesRequest.fromJson(Map<String, dynamic> json) {
    return AssignWarehousesRequest(
      userEmail: json['user_email'] as String,
      warehouses: List<String>.from(json['warehouses'] ?? []),
      replaceExisting: json['replace_existing'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_email': userEmail,
      'warehouses': warehouses,
      'replace_existing': replaceExisting,
    };
  }
}
