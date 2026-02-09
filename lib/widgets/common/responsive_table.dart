import 'package:flutter/material.dart';

class ResponsiveTable extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final double? columnSpacing;
  final double? dataRowHeight;
  final double? headingRowHeight;
  final double? horizontalMargin;

  const ResponsiveTable({
    super.key,
    required this.columns,
    required this.rows,
    this.columnSpacing,
    this.dataRowHeight,
    this.headingRowHeight,
    this.horizontalMargin,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              columns: columns,
              rows: rows,
              columnSpacing: columnSpacing ?? 24,
              dataRowMinHeight: dataRowHeight ?? 56,
              dataRowMaxHeight: dataRowHeight ?? 56,
              headingRowHeight: headingRowHeight ?? 56,
              horizontalMargin: horizontalMargin ?? 24,
              showCheckboxColumn: false,
              headingTextStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        );
      },
    );
  }
}
