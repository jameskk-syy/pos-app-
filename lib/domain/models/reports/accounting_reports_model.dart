class ProfitAndLossResponse {
  final bool success;
  final List<ProfitAndLossColumn> columns;
  final List<ProfitAndLossRow> data;
  final List<ProfitAndLossSummary> reportSummary;
  final ProfitAndLossChart? chart;

  ProfitAndLossResponse({
    required this.success,
    required this.columns,
    required this.data,
    required this.reportSummary,
    this.chart,
  });

  factory ProfitAndLossResponse.fromJson(Map<String, dynamic> json) {
    // Note: The datasource already extracts 'message', so json IS the message content
    final success =
        (json['status'] ?? json['success']) == 'success' ||
        (json['success'] == true);

    List<ProfitAndLossRow> rows = [];
    final rawData = json['data'];
    if (rawData is List) {
      rows = rawData
          .where((e) => e is Map && e.isNotEmpty)
          .map((e) => ProfitAndLossRow.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return ProfitAndLossResponse(
      success: success,
      columns: (json['columns'] as List? ?? [])
          .map((e) => ProfitAndLossColumn.fromJson(e))
          .toList(),
      data: rows,
      reportSummary: (json['report_summary'] as List? ?? [])
          .map((e) => ProfitAndLossSummary.fromJson(e))
          .toList(),
      chart: json['chart'] != null
          ? ProfitAndLossChart.fromJson(json['chart'])
          : null,
    );
  }
}

class ProfitAndLossColumn {
  final String fieldname;
  final String label;
  final String fieldtype;
  final bool hidden;

  ProfitAndLossColumn({
    required this.fieldname,
    required this.label,
    required this.fieldtype,
    this.hidden = false,
  });

  factory ProfitAndLossColumn.fromJson(Map<String, dynamic> json) {
    return ProfitAndLossColumn(
      fieldname: json['fieldname'] ?? '',
      label: json['label'] ?? '',
      fieldtype: json['fieldtype'] ?? '',
      hidden: json['hidden'] == 1 || json['hidden'] == true,
    );
  }
}

class ProfitAndLossRow {
  final String account;
  final String? accountName;
  final String? parentAccount;
  final int indent;
  final bool isGroup;
  final double total;
  final Map<String, dynamic> dynamicValues;

  ProfitAndLossRow({
    required this.account,
    this.accountName,
    this.parentAccount,
    this.indent = 0,
    this.isGroup = false,
    this.total = 0.0,
    required this.dynamicValues,
  });

  factory ProfitAndLossRow.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> dyn = {};
    json.forEach((key, value) {
      // Keep everything in dynamicValues for easier access by fieldname
      dyn[key] = value;
    });

    return ProfitAndLossRow(
      account: json['account'] ?? json['account_name'] ?? '',
      accountName: json['account_name'],
      parentAccount: json['parent_account'],
      indent: (json['indent'] as num?)?.toInt() ?? 0,
      isGroup: json['is_group'] == 1 || json['is_group'] == true,
      total: _parseAmount(json['total'] ?? 0.0),
      dynamicValues: dyn,
    );
  }

  static double _parseAmount(dynamic val) {
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }
}

class ProfitAndLossSummary {
  final String label;
  final dynamic value; // Can be String or num
  final String? indicator;
  final String? type;

  ProfitAndLossSummary({
    required this.label,
    required this.value,
    this.indicator,
    this.type,
  });

  factory ProfitAndLossSummary.fromJson(Map<String, dynamic> json) {
    return ProfitAndLossSummary(
      label: json['label'] ?? '',
      value: json['value'] ?? 0.0,
      indicator: json['indicator'],
      type: json['type'],
    );
  }
}

class ProfitAndLossChart {
  final Map<String, dynamic> data;
  ProfitAndLossChart({required this.data});
  factory ProfitAndLossChart.fromJson(Map<String, dynamic> json) {
    return ProfitAndLossChart(data: json['data'] ?? {});
  }
}
