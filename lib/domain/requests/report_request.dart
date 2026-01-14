class ReportRequest {
  final String company;
  final String? startDate;
  final String? endDate;
  final String? warehouse;
  final String? itemGroup;
  final String? customer;
  final String? groupBy; // for sales analytics
  final String? period; // for trends

  ReportRequest({
    required this.company,
    this.startDate,
    this.endDate,
    this.warehouse,
    this.itemGroup,
    this.customer,
    this.groupBy,
    this.period,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'company': company};
    if (startDate != null) data['start_date'] = startDate;
    if (endDate != null) data['end_date'] = endDate;
    if (warehouse != null) data['warehouse'] = warehouse;
    if (itemGroup != null) data['item_group'] = itemGroup;
    if (customer != null) data['customer'] = customer;
    if (groupBy != null) data['group_by'] = groupBy;
    if (period != null) data['period'] = period;
    return data;
  }
}
