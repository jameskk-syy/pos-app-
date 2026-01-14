import 'package:flutter/material.dart';

class PaymentsData extends StatefulWidget {
  const PaymentsData({super.key});

  @override
  State<PaymentsData> createState() => _PaymentsDataState();
}

class _PaymentsDataState extends State<PaymentsData> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.blue, width: 0.3),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 220,
            child: PageView(
              controller: _controller,
              onPageChanged: (i) => setState(() => _index = i),
              children: const [
                _Section(title: "Purchases Due"),
                _Section(title: "Other Payments"),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              2,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: _index == i ? 18 : 8,
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha(_index == i ? 1 : 30),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;

  const _Section({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            children: [
              _headerRow(),
              const SizedBox(height: 6),
              const Divider(color: Colors.blue, thickness: 1, height: 1),
              const SizedBox(height: 6),
              _dataRow(),
              _dataRow(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _headerRow() {
    return const SizedBox(
      width: 520,
      child: Row(
        children: [
          _Cell("Supplier", bold: true),
          _Cell("Amount", bold: true),
          _Cell("Due Date", bold: true),
          _Cell("Status", bold: true, width: 120),
        ],
      ),
    );
  }

  Widget _dataRow() {
    return const SizedBox(
      width: 520,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            _Cell("John Doe"),
            _Cell("\$5,200"),
            _Cell("2/15/2026"),
            SizedBox(width: 120, child: _Status()),
          ],
        ),
      ),
    );
  }
}

class _Status extends StatelessWidget {
  const _Status();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Text(
          "Overdue",
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String text;
  final bool bold;
  final double width;

  const _Cell(this.text, {this.bold = false, this.width = 100});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: TextStyle(
          fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}
