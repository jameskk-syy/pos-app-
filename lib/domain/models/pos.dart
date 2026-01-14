class PosIndustry {
  final String name;
  final String industryName;

  PosIndustry({
    required this.name,
    required this.industryName,
  });

  factory PosIndustry.fromJson(Map<String, dynamic> json) {
    return PosIndustry(
      name: json['name'],
      industryName: json['industry_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'industry_name': industryName,
    };
  }
}
