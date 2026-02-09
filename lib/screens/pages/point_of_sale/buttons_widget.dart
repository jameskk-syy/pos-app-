import 'package:flutter/material.dart';
import 'package:pos/screens/pages/point_of_sale/app_bar.dart';

class POSActionButtons extends StatelessWidget {
  final VoidCallback? onCloseSession;
  final VoidCallback? onSaveDraft;
  final VoidCallback? onInvoicesPressed;
  final bool showCloseSession;
  final bool showSaveDraft;

  const POSActionButtons({
    super.key,
    this.onCloseSession,
    this.onSaveDraft,
    this.onInvoicesPressed,
    this.showCloseSession = true,
    this.showSaveDraft = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (showCloseSession) ...[
            OutlinedButton.icon(
              onPressed: onCloseSession ?? () {},
              icon: const Icon(Icons.close, color: Colors.red, size: 14),
              label: const Text(
                'Close Session',
                style: TextStyle(color: Colors.red, fontSize: 11),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red, width: 1),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            if (showSaveDraft) const SizedBox(width: 8),
          ],
          OutlinedButton.icon(
            onPressed: onInvoicesPressed ?? () {},
            icon: const Icon(Icons.description, color: Colors.blue, size: 14),
            label: const Text(
              'Invoices',
              style: TextStyle(color: Colors.blue, fontSize: 11),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.blue, width: 1),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // if (showSaveDraft)
          //   OutlinedButton.icon(
          //     onPressed: onSaveDraft ?? () {},
          //     icon: const Icon(Icons.save, color: Colors.black, size: 14),
          //     label: const Text(
          //       'Save Draft',
          //       style: TextStyle(color: Colors.black, fontSize: 11),
          //     ),
          //     style: OutlinedButton.styleFrom(
          //       side: BorderSide(color: Colors.grey.shade400, width: 1),
          //       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          //       minimumSize: Size.zero,
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(4),
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }
}

class SaleSummaryPageExample extends StatelessWidget {
  const SaleSummaryPageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: POSAppBar(
        statusText: 'Connected to Printer',
        statusColor: Colors.green,
        onBackPressed: () => Navigator.pop(context),
        onStatusPressed: () {},
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          POSActionButtons(onCloseSession: () {}, onSaveDraft: () {}),
          Expanded(child: Center(child: Text('Page Content'))),
        ],
      ),
    );
  }
}
