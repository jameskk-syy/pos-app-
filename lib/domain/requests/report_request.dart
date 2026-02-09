class ReportRequest {
  final String company;
  final String? startDate;
  final String? endDate;
  final String? fromDate;
  final String? toDate;
  final String? warehouse;
  final String? itemGroup;
  final String? customer;
  final String? groupBy; // for sales analytics
  final String? period; // for trends (daily, weekly, monthly)
  final String? format; // for exports (csv, excel, pdf)
  final List<String>? costMethods; // for cost method comparison
  final int? periodDays; // for days on hand
  final String? analysisType; // for moving patterns (seasonal, trend, forecast)
  final double? slowMovingThreshold; // for stock aging
  final String? riskLevel; // for obsolescence risk
  final double? varianceThreshold; // for variance report
  final String? fromWarehouse; // for transfer efficiency
  final String? toWarehouse; // for transfer efficiency
  final String? adjustmentType; // for adjustment trends
  final String? periodicity;
  final String? costCenter;
  final String? financeBook;
  final String? project;
  final String? presentationCurrency;
  final int? accumulatedValues;
  final int? showZeroRows;
  final int? includeDefaultBookEntries;
  final bool? withDrilldown;
  final String? searchTerm;
  final Map<String, dynamic>? filters; // Generic filters

  ReportRequest({
    required this.company,
    this.startDate,
    this.endDate,
    this.fromDate,
    this.toDate,
    this.warehouse,
    this.itemGroup,
    this.customer,
    this.groupBy,
    this.period,
    this.format,
    this.costMethods,
    this.periodDays,
    this.analysisType,
    this.slowMovingThreshold,
    this.riskLevel,
    this.varianceThreshold,
    this.fromWarehouse,
    this.toWarehouse,
    this.adjustmentType,
    this.periodicity,
    this.costCenter,
    this.financeBook,
    this.project,
    this.presentationCurrency,
    this.accumulatedValues,
    this.showZeroRows,
    this.includeDefaultBookEntries,
    this.withDrilldown,
    this.searchTerm,
    this.filters,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'company': company};
    if (startDate != null) data['start_date'] = startDate;
    if (endDate != null) data['end_date'] = endDate;
    if (fromDate != null) data['from_date'] = fromDate;
    if (toDate != null) data['to_date'] = toDate;
    if (warehouse != null) data['warehouse'] = warehouse;
    if (itemGroup != null) data['item_group'] = itemGroup;
    if (customer != null) data['customer'] = customer;
    if (groupBy != null) data['group_by'] = groupBy;
    if (period != null) data['period'] = period;
    if (format != null) data['format'] = format;
    if (costMethods != null) data['cost_methods'] = costMethods;
    if (periodDays != null) data['period_days'] = periodDays;
    if (analysisType != null) data['analysis_type'] = analysisType;
    if (slowMovingThreshold != null) {
      data['slow_moving_threshold'] = slowMovingThreshold;
    }
    if (riskLevel != null) data['risk_level'] = riskLevel;
    if (varianceThreshold != null) {
      data['variance_threshold'] = varianceThreshold;
    }
    if (fromWarehouse != null) data['from_warehouse'] = fromWarehouse;
    if (toWarehouse != null) data['to_warehouse'] = toWarehouse;
    if (adjustmentType != null) data['adjustment_type'] = adjustmentType;
    if (periodicity != null) data['periodicity'] = periodicity;
    if (costCenter != null) data['cost_center'] = costCenter;
    if (financeBook != null) data['finance_book'] = financeBook;
    if (project != null) data['project'] = project;
    if (presentationCurrency != null) {
      data['presentation_currency'] = presentationCurrency;
    }
    if (accumulatedValues != null) {
      data['accumulated_values'] = accumulatedValues;
    }
    if (showZeroRows != null) data['show_zero_rows'] = showZeroRows;
    if (includeDefaultBookEntries != null) {
      data['include_default_book_entries'] = includeDefaultBookEntries;
    }
    if (withDrilldown != null) data['with_drilldown'] = withDrilldown;
    if (searchTerm != null) data['search_term'] = searchTerm;

    // Add generic filters to the map if they exist
    if (filters != null) {
      data.addAll(filters!);
    }

    return data;
  }
}
