import 'dart:async';
import 'package:flutter/material.dart';

import 'package:pos/core/dependency.dart';
import 'package:pos/core/services/connectivity_service.dart';
import 'package:pos/data/datasource/local_datasource.dart';
import 'package:pos/domain/models/invoice_model.dart';
import 'package:pos/domain/repository/abstract_sales_repository.dart';
import 'package:pos/domain/repository/crm_repo.dart';
import 'package:pos/domain/responses/crm/loyalty_response.dart';

class SyncPage extends StatefulWidget {
  const SyncPage({super.key});

  @override
  State<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends State<SyncPage> {
  final LocalDataSource _localDataSource = getIt<LocalDataSource>();
  final SalesRepository _salesRepository = getIt<SalesRepository>();
  final CrmRepo _crmRepo = getIt<CrmRepo>();
  final ConnectivityService _connectivityService = getIt<ConnectivityService>();

  List<Map<String, dynamic>> _offlineSales = [];
  List<Map<String, dynamic>> _offlineLoyaltyPoints = [];
  bool _isLoading = false;
  bool _isConnected = false;
  String _statusMessage = "";
  StreamSubscription? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _loadOfflineData();
    _initConnectivity();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> _initConnectivity() async {
    _isConnected = await _connectivityService.checkNow();
    if (mounted) setState(() {});

    _connectivitySubscription = _connectivityService.connectionChange.listen((
      connected,
    ) {
      if (mounted) {
        setState(() {
          _isConnected = connected;
        });
      }
    });
  }

  Future<void> _loadOfflineData() async {
    final sales = _localDataSource.getOfflineSales();
    final loyaltyPoints = _localDataSource.getOfflineLoyaltyPoints();
    if (mounted) {
      setState(() {
        _offlineSales = sales;
        _offlineLoyaltyPoints = loyaltyPoints;
      });
    }
  }

  Future<void> _syncAll() async {
    final isConnected = await _connectivityService.checkNow();

    if (!mounted) return;

    if (!isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No internet connection. Cannot sync.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = "Starting sync...";
    });

    // Sync sales first
    final salesResult = await _syncSales();

    // Then sync loyalty points
    final loyaltyResult = await _syncLoyaltyPoints();

    await _loadOfflineData();

    if (mounted) {
      setState(() {
        _isLoading = false;
        _statusMessage =
            "Sync complete.\nSales: ${salesResult['success']} synced, ${salesResult['failed']} failed\nLoyalty Points: ${loyaltyResult['success']} synced, ${loyaltyResult['failed']} failed";
      });
    }

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_statusMessage)));
    }
  }

  Future<Map<String, int>> _syncSales() async {
    int successCount = 0;
    int failCount = 0;

    final salesToSync = List<Map<String, dynamic>>.from(_offlineSales);
    await _localDataSource.clearAllOfflineSales();
    List<Map<String, dynamic>> failedSales = [];

    for (var i = 0; i < salesToSync.length; i++) {
      final saleJson = salesToSync[i];
      if (mounted) {
        setState(() {
          _statusMessage = "Syncing sale ${i + 1} of ${salesToSync.length}...";
        });
      }

      try {
        final request = InvoiceRequest.fromJson(saleJson);
        await _salesRepository.createInvoice(request: request);
        successCount++;
        debugPrint("Successfully synced sale ${i + 1}");
      } catch (e) {
        final errorMessage = e.toString();

        // Check if the error is a post-creation server error (invoice was created successfully)
        // These errors occur AFTER the invoice is created on the server
        final isPostCreationError =
            errorMessage.contains(
              "cannot access local variable 'enable_discount_accounting'",
            ) ||
            errorMessage.contains('enable_discount_accounting') ||
            errorMessage.contains('where it is not associated with a value') ||
            errorMessage.contains('discount_accounting');

        if (isPostCreationError) {
          // Invoice was created successfully, just log the error and count as success
          successCount++;
          debugPrint("✓ Sale synced successfully (server warning ignored): $e");
        } else {
          // Actual creation failure, re-queue the sale
          failCount++;
          failedSales.add(saleJson);
          debugPrint("✗ Failed to sync sale: $e");
        }
      }
    }

    // Restore only truly failed sales
    for (var sale in failedSales) {
      await _localDataSource.saveOfflineSale(sale);
    }

    return {'success': successCount, 'failed': failCount};
  }

  Future<Map<String, int>> _syncLoyaltyPoints() async {
    int successCount = 0;
    int failCount = 0;

    final loyaltyToSync = List<Map<String, dynamic>>.from(
      _offlineLoyaltyPoints,
    );
    await _localDataSource.clearAllOfflineLoyaltyPoints();
    List<Map<String, dynamic>> failedLoyalty = [];

    for (var i = 0; i < loyaltyToSync.length; i++) {
      final loyaltyJson = loyaltyToSync[i];
      if (mounted) {
        setState(() {
          _statusMessage =
              "Syncing loyalty points ${i + 1} of ${loyaltyToSync.length}...";
        });
      }

      try {
        final request = EarnLoyaltyPointsRequest(
          customerId: loyaltyJson['customer_id'],
          purchaseAmount: (loyaltyJson['purchase_amount'] as num).toDouble(),
        );
        await _crmRepo.earnLoyaltyPoints(request);
        successCount++;
      } catch (e) {
        failCount++;
        failedLoyalty.add(loyaltyJson);
        debugPrint("Failed to sync loyalty points: $e");
      }
    }

    // Restore failed loyalty points
    for (var loyalty in failedLoyalty) {
      await _localDataSource.saveOfflineLoyaltyPoints(loyalty);
    }

    return {'success': successCount, 'failed': failCount};
  }

  Future<void> _clearAllPendingSales() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear All Pending Sales?"),
        content: const Text(
          "This will permanently remove all pending sales from the sync queue. "
          "Only do this if you're sure these sales have already been created on the server.\n\n"
          "Are you sure you want to continue?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Clear All"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _localDataSource.clearAllOfflineSales();
      await _loadOfflineData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("All pending sales cleared")),
        );
      }
    }
  }

  Future<void> _deleteSale(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Pending Sale?"),
        content: const Text(
          "This will remove this sale from the sync queue. "
          "Only do this if you're sure this sale has already been created on the server.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final sales = _localDataSource.getOfflineSales();
      if (index >= 0 && index < sales.length) {
        sales.removeAt(index);
        await _localDataSource.clearAllOfflineSales();
        for (var sale in sales) {
          await _localDataSource.saveOfflineSale(sale);
        }
        await _loadOfflineData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Sale removed from sync queue")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPending = _offlineSales.length + _offlineLoyaltyPoints.length;

    return Scaffold(
      appBar: AppBar(title: const Text("Offline Sync")),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.cloud_upload, color: Colors.blue),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "You have $totalPending pending items to sync.",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _isConnected
                                      ? Colors.green
                                      : Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isConnected ? "Online" : "Offline",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _isConnected
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatChip(
                      icon: Icons.receipt,
                      label: "Sales",
                      count: _offlineSales.length,
                      color: Colors.orange,
                    ),
                    _buildStatChip(
                      icon: Icons.stars,
                      label: "Loyalty Points",
                      count: _offlineLoyaltyPoints.length,
                      color: Colors.purple,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const LinearProgressIndicator(),
                  const SizedBox(height: 8),
                  Text(_statusMessage),
                ],
              ),
            ),
          Expanded(
            child: ListView(
              children: [
                if (_offlineSales.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Pending Sales (${_offlineSales.length})",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _isLoading ? null : _clearAllPendingSales,
                          icon: const Icon(Icons.clear_all, size: 16),
                          label: const Text("Clear All"),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ..._offlineSales.asMap().entries.map(
                    (entry) => _buildSaleItem(entry.value, entry.key),
                  ),
                ],
                if (_offlineLoyaltyPoints.isNotEmpty) ...[
                  _buildSectionHeader(
                    "Pending Loyalty Points (${_offlineLoyaltyPoints.length})",
                  ),
                  ..._offlineLoyaltyPoints.map(
                    (loyalty) => _buildLoyaltyItem(loyalty),
                  ),
                ],
                if (totalPending == 0)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 64,
                            color: Colors.green.shade300,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "All synced!",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "No pending items to sync.",
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading || totalPending == 0 || !_isConnected
                    ? null
                    : _syncAll,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                icon: const Icon(Icons.sync),
                label: const Text("Sync Now"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            "$count $label",
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSaleItem(Map<String, dynamic> sale, int index) {
    final customer = sale['customer'] ?? 'Unknown';
    final total =
        (sale['payments'] as List?)?.fold<double>(
          0,
          (sum, p) => sum + (p['amount'] ?? 0),
        ) ??
        0.0;

    return ListTile(
      leading: const Icon(Icons.receipt, color: Colors.orange),
      title: Text("Sale to $customer"),
      subtitle: Text("Total: ${total.toStringAsFixed(2)}"),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.pending, color: Colors.orange),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
            onPressed: _isLoading ? null : () => _deleteSale(index),
            tooltip: "Delete this sale",
          ),
        ],
      ),
    );
  }

  Widget _buildLoyaltyItem(Map<String, dynamic> loyalty) {
    final customerId = loyalty['customer_id'] ?? 'Unknown';
    final amount = (loyalty['purchase_amount'] ?? 0.0).toDouble();

    return ListTile(
      leading: const Icon(Icons.stars, color: Colors.purple),
      title: Text("Loyalty points for $customerId"),
      subtitle: Text("Purchase: ${amount.toStringAsFixed(2)}"),
      trailing: const Icon(Icons.pending, color: Colors.purple),
    );
  }
}
