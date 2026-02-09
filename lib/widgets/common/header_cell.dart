

import 'package:flutter/material.dart';

class HeaderCell extends StatelessWidget {
  final String text;
  final double width;

  const HeaderCell(this.text, this.width, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }
}

class DataCell extends StatelessWidget {
  final String text;
  final double width;

  const DataCell(this.text, this.width, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: const TextStyle(fontSize: 12),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }
}