class DashboardRequest {
  final String? period;
  final String? warehouse;
  final String? staff;
  final String? company;
  final String? fromDate;
  final String? toDate;

  DashboardRequest({
    this.period,
    this.warehouse,
    this.staff,
    this.company,
    this.fromDate,
    this.toDate,
  });

  factory DashboardRequest.fromJson(Map<String, dynamic>? json) {
    if (json == null) return DashboardRequest();
    
    return DashboardRequest(
      period: json['period'],
      warehouse: json['warehouse'],
      staff: json['staff'],
      company: json['company'],
      fromDate: json['from_date'],
      toDate: json['to_date'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (period != null) data['period'] = period;
    if (warehouse != null) data['warehouse'] = warehouse;
    if (staff != null) data['staff'] = staff;
    if (company != null) data['company'] = company;
    if (fromDate != null) data['from_date'] = fromDate;
    if (toDate != null) data['to_date'] = toDate;
    
    return data;
  }

  Map<String, String> toQueryParameters() {
    final Map<String, String> params = {};
    
    if (period != null) params['period'] = period!;
    if (warehouse != null) params['warehouse'] = warehouse!;
    if (staff != null) params['staff'] = staff!;
    if (company != null) params['company'] = company!;
    if (fromDate != null) params['from_date'] = fromDate!;
    if (toDate != null) params['to_date'] = toDate!;
    
    return params;
  }
  DashboardRequest copyWith({
    String? period,
    String? warehouse,
    String? staff,
    String? company,
    String? fromDate,
    String? toDate,
    bool clearPeriod = false,
    bool clearWarehouse = false,
    bool clearStaff = false,
    bool clearCompany = false,
    bool clearFromDate = false,
    bool clearToDate = false,
  }) {
    return DashboardRequest(
      period: clearPeriod ? null : (period ?? this.period),
      warehouse: clearWarehouse ? null : (warehouse ?? this.warehouse),
      staff: clearStaff ? null : (staff ?? this.staff),
      company: clearCompany ? null : (company ?? this.company),
      fromDate: clearFromDate ? null : (fromDate ?? this.fromDate),
      toDate: clearToDate ? null : (toDate ?? this.toDate),
    );
  }
  DashboardRequest merge(DashboardRequest? other) {
    if (other == null) return this;
    
    return DashboardRequest(
      period: other.period ?? period,
      warehouse: other.warehouse ?? warehouse,
      staff: other.staff ?? staff,
      company: other.company ?? company,
      fromDate: other.fromDate ?? fromDate,
      toDate: other.toDate ?? toDate,
    );
  }
  bool get isEmpty {
    return period == null &&
        warehouse == null &&
        staff == null &&
        company == null &&
        fromDate == null &&
        toDate == null;
  }

  bool get isNotEmpty => !isEmpty;
  int get fieldCount {
    int count = 0;
    if (period != null) count++;
    if (warehouse != null) count++;
    if (staff != null) count++;
    if (company != null) count++;
    if (fromDate != null) count++;
    if (toDate != null) count++;
    return count;
  }

  @override
  String toString() {
    return 'DashboardRequest(period: $period, warehouse: $warehouse, staff: $staff, company: $company, fromDate: $fromDate, toDate: $toDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DashboardRequest &&
        other.period == period &&
        other.warehouse == warehouse &&
        other.staff == staff &&
        other.company == company &&
        other.fromDate == fromDate &&
        other.toDate == toDate;
  }

  @override
  int get hashCode {
    return Object.hash(
      period,
      warehouse,
      staff,
      company,
      fromDate,
      toDate,
    );
  }
}