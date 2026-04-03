import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  final String title;
  final String errorMessage;

  const ErrorDialog({
    super.key,
    this.title = 'Error',
    required this.errorMessage,
  });

  String _extractCoreErrorMessage(String message) {
    var coreMessage = message;

    if (coreMessage.startsWith('Error: ')) {
      coreMessage = coreMessage.substring(7);
    }
    
    if (coreMessage.contains('Valuation Rate for the Item')) {
      final itemMatch = RegExp(r'Valuation Rate for the Item (.*?), is required').firstMatch(coreMessage);
      if (itemMatch != null) {
        return 'Valuation Rate for Item ${itemMatch.group(1)}, is required,  please manage price at product  level';
      }
    }

    final regex = RegExp(r'\.([A-Z])|\. (Here|If|Please|You|Note)');
    final match = regex.firstMatch(coreMessage);
    
    if (match != null) {
      coreMessage = '${coreMessage.substring(0, match.start).trim()}.';
    }
    
    return coreMessage;
  }

  static Future<void> show(BuildContext context, String message, {String title = 'Error'}) {
    return showDialog(
      context: context,
      builder: (context) => ErrorDialog(
        title: title,
        errorMessage: message,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Text(
                  _extractCoreErrorMessage(errorMessage),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Dismiss',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
