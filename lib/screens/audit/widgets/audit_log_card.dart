import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos/domain/models/audit_log.dart';

class AuditLogCard extends StatelessWidget {
  final AuditLog log;

  const AuditLogCard({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(log.creation);
    final formattedDate = date != null
        ? DateFormat('MMM d, yyyy HH:mm').format(date)
        : log.creation;

    final isSuccess = log.status == 'Success';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          leading: Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: _getActivityColor(log.activityType).withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getActivityIcon(log.activityType),
              color: _getActivityColor(log.activityType),
              size: 18,
            ),
          ),
          title: Text(
            log.activityDescription,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _infoChip(Icons.person_outline, log.user, Colors.grey),
                _infoChip(
                  Icons.access_time_outlined,
                  formattedDate,
                  Colors.grey,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSuccess ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isSuccess
                          ? Colors.green.withAlpha(80)
                          : Colors.red.withAlpha(80),
                    ),
                  ),
                  child: Text(
                    log.status,
                    style: TextStyle(
                      color: isSuccess ? Colors.green[700] : Colors.red[700],
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 16),
                  _buildDetailRow('Log ID', log.name),
                  if (log.referenceDoctype != null || log.referenceName != null)
                    _buildDetailRow(
                      'Reference',
                      '${log.referenceDoctype ?? 'N/A'}: ${log.referenceName ?? 'N/A'}',
                    ),
                  if (log.ipAddress != null)
                    _buildDetailRow('IP Address', log.ipAddress!),
                  _buildDetailRow(
                    'Exec Time',
                    '${log.executionTime?.toStringAsFixed(3) ?? '0'}s',
                  ),
                  if (log.metadata != null) ...[
                    const SizedBox(height: 4),
                    _buildDetailRow(
                      'Endpoint',
                      log.metadata!['endpoint']?.toString() ?? 'N/A',
                    ),
                    _buildDetailRow(
                      'Method',
                      log.metadata!['method']?.toString() ?? 'N/A',
                    ),
                  ],
                  if (log.errorMessage != null)
                    _buildDetailRow('Error', log.errorMessage!, isError: true),
                  if (log.requestData != null) ...[
                    const SizedBox(height: 6),
                    const Text(
                      'Request Data:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Text(
                        const JsonEncoder.withIndent(
                          '  ',
                        ).convert(log.requestData),
                        style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 3),
        Text(text, style: TextStyle(color: color, fontSize: 11)),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isError ? Colors.red : Colors.black87,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'Create':
        return Icons.add_circle_outline;
      case 'Update':
        return Icons.edit_note;
      case 'Delete':
        return Icons.delete_outline;
      case 'Submit':
        return Icons.send;
      case 'API Call':
        return Icons.api;
      default:
        return Icons.history;
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'Create':
        return Colors.green;
      case 'Update':
        return Colors.orange;
      case 'Delete':
        return Colors.red;
      case 'Submit':
        return Colors.blue;
      case 'API Call':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
