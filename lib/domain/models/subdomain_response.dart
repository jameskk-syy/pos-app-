class SubdomainResponse {
  final String tenantId;
  final String status;
  final String siteUrl;
  final String companyName;

  SubdomainResponse({
    required this.tenantId,
    required this.status,
    required this.siteUrl,
    required this.companyName,
  });

  factory SubdomainResponse.fromJson(Map<String, dynamic> json) {
    return SubdomainResponse(
      tenantId: json['tenantId'] ?? '',
      status: json['status'] ?? '',
      siteUrl: json['siteUrl'] ?? '',
      companyName: json['companyName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tenantId': tenantId,
      'status': status,
      'siteUrl': siteUrl,
      'companyName': companyName,
    };
  }
}
