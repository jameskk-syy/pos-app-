import 'package:flutter/material.dart';

class MaterialIssuesPage extends StatelessWidget {
  const MaterialIssuesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        title: const Text(
          'Material Issues',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(30),
          child: Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'View all material issue transactions',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('Create Issue'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1677FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFBBD4FF)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filters',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _twoRow(
                    context,
                    _dropdown('Warehouse'),
                    _dropdown('Item Code'),
                  ),
                  const SizedBox(height: 12),
                  _twoRow(
                    context,
                    _dropdown('Status'),
                    _dateField('From Date'),
                  ),
                  const SizedBox(height: 12),
                  _twoRow(context, _dateField('To Date'), const SizedBox()),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.close, color: Colors.red),
                        label: const Text(
                          'Reset Filters',
                          style: TextStyle(color: Colors.red),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1677FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Apply Filters'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFBBD4FF)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    const Color(0xFFF1F6FF),
                  ),
                  columns: const [
                    DataColumn(label: Text('Document Name')),
                    DataColumn(label: Text('Posting Date')),
                    DataColumn(label: Text('Source Warehouse')),
                    DataColumn(label: Text('Count')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: List.generate(
                    6,
                    (index) => const DataRow(
                      cells: [
                        DataCell(Text('Fruits')),
                        DataCell(Text('16/12/2025')),
                        DataCell(Text('Main Warehouse')),
                        DataCell(Text('200')),
                        DataCell(Icon(Icons.remove_red_eye)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _twoRow(BuildContext context, Widget a, Widget b) {
    final w = MediaQuery.of(context).size.width;
    if (w < 600) {
      return Column(children: [a, const SizedBox(height: 12), b]);
    }
    return Row(
      children: [
        Expanded(child: a),
        const SizedBox(width: 12),
        Expanded(child: b),
      ],
    );
  }

  Widget _dropdown(String label) {
    return DropdownButtonFormField(
      items: const [],
      onChanged: (_) {},
      decoration: _inputDecoration(label),
    );
  }

  Widget _dateField(String label) {
    return TextFormField(
      readOnly: true,
      decoration: _inputDecoration(
        label,
      ).copyWith(suffixIcon: const Icon(Icons.calendar_today)),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFBBD4FF)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFBBD4FF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1677FF)),
      ),
    );
  }
}
