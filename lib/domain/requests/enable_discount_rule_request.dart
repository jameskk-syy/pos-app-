class EnableDiscountRuleRequest {
  final String name;

  EnableDiscountRuleRequest({required this.name});

  Map<String, dynamic> toJson() => {"name": name};
}
