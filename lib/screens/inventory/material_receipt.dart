import 'package:flutter/material.dart';

class MaterialReceiptPage extends StatefulWidget {
  const MaterialReceiptPage({super.key});

  @override
  State<MaterialReceiptPage> createState() => _MaterialReceiptPageState();
}

class _MaterialReceiptPageState extends State<MaterialReceiptPage> {
  final List<StockItem> items = [StockItem()];

  @override
  void dispose() {
    for (var item in items) {
      item.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Material Receipt",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: () {},
              child: const Text(
                "",
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  _twoColumnRow(
                    left: _fieldLabel(
                      "Target Warehouse*",
                      DropdownButtonFormField<String>(
                        items: const [],
                        onChanged: (v) {},
                        decoration: const InputDecoration(
                          hintText: "Choose a warehouse",
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    right: _fieldLabel(
                      "Posting Date*",
                      TextFormField(
                        readOnly: true,
                        decoration: const InputDecoration(
                          hintText: "16/12/2025",
                          suffixIcon: Icon(
                            Icons.calendar_today_outlined,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _twoColumnRow(
                    left: _fieldLabel(
                      "Posting Time",
                      TextFormField(
                        readOnly: true,
                        decoration: const InputDecoration(
                          hintText: "08:00:00",
                          suffixIcon: Icon(Icons.access_time, size: 18),
                        ),
                      ),
                    ),
                    right: const SizedBox(),
                  ),
                  const SizedBox(height: 24),
                  _itemsSection(),
                ],
              ),
            ),
            _bottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  Widget _twoColumnRow({required Widget left, required Widget right}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }

  Widget _itemsSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Items",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    _Header("Item Code*", 180),
                    _Header("Qty*", 80),
                    _Header("Rate*", 100),
                    _Header("", 50),
                  ],
                ),
                const SizedBox(height: 8),
                ...items.asMap().entries.map((e) => _itemRow(e.value, e.key)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () {
              setState(() {
                items.add(StockItem());
              });
            },
            icon: const Icon(Icons.add),
            label: const Text("Add Item"),
          ),
        ],
      ),
    );
  }

  Widget _itemRow(StockItem item, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 180,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: DropdownButtonFormField<String>(
                isDense: true,
                items: const [],
                onChanged: (v) {},
                decoration: const InputDecoration(
                  hintText: "Select",
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
                ),
                style: const TextStyle(fontSize: 12, color: Colors.black),
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextFormField(
                controller: item.qtyController,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextFormField(
                controller: item.rateController,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 50,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  items[index].dispose();
                  items.removeAt(index);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[700],
                side: BorderSide(color: Colors.grey[300]!),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Cancel"),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Create Receipt",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String text;
  final double width;
  const _Header(this.text, this.width);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
        ),
      ),
    );
  }
}

class StockItem {
  final TextEditingController qtyController;
  final TextEditingController rateController;

  StockItem()
    : qtyController = TextEditingController(text: "1"),
      rateController = TextEditingController(text: "0");

  void dispose() {
    qtyController.dispose();
    rateController.dispose();
  }
}
