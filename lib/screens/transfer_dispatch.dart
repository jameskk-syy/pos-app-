import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/requests/dispatch_stock_transfer_request.dart';
import 'package:pos/domain/responses/get_current_user.dart';
import 'package:pos/domain/responses/get_stock_transfer_response.dart';
import 'package:pos/presentation/inventory/bloc/inventory_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StockTransferDispatchScreen extends StatefulWidget {
  final String requestId;

  const StockTransferDispatchScreen({super.key, required this.requestId});

  @override
  State<StockTransferDispatchScreen> createState() =>
      _StockTransferDispatchScreenState();
}

class _StockTransferDispatchScreenState
    extends State<StockTransferDispatchScreen> {
  final TextEditingController _noteController = TextEditingController();
  List<Map<String, dynamic>> _items = [];
  final List<TextEditingController> _qtyControllers = [];
  bool _isDispatching = false;
  String currentUserId = '';

  StockTransferData? _loadedData;
  bool _hasLoadedOnce = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    context.read<InventoryBloc>().add(
      GetStockTransferRequest(requestId: widget.requestId),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    for (var controller in _qtyControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateDispatchedQty(int index, double qty, double maxQty) {
    final validQty = qty > maxQty ? maxQty : qty;
    _items[index]['dispatched_qty'] = validQty;
  }

  Future<CurrentUserResponse?> _getSavedCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('current_user');
    if (userString == null) return null;
    return CurrentUserResponse.fromJson(jsonDecode(userString));
  }

  Future<void> _loadCurrentUser() async {
    final savedUser = await _getSavedCurrentUser();
    if (savedUser == null) return;

    setState(() {
      currentUserId = savedUser.message.user.name;
    });
  }

  void _initializeItems(StockTransferData data) {
    if (_items.isEmpty) {
      _items = data.items.map((item) {
        final controller = TextEditingController(
          text: item.requestedQty.toString(),
        );
        _qtyControllers.add(controller);
        return <String, dynamic>{
          'item_code': item.itemCode,
          'requested_qty': item.requestedQty,
          'dispatched_qty': item.requestedQty,
          'received_qty': item.receivedQty,
        };
      }).toList();
    }
  }

  Future<void> _handleDispatch(String requestId, String originWarehouse) async {
    bool hasInvalidQty = _items.any(
      (item) => item['dispatched_qty'] == null || item['dispatched_qty'] <= 0,
    );

    if (hasInvalidQty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please set valid quantities for all items'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    bool hasExceededQty = _items.any(
      (item) => item['dispatched_qty'] > item['requested_qty'],
    );

    if (hasExceededQty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot dispatch more than requested quantity'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isDispatching = true;
    });

    final dispatchRequest = DispatchStockTransferRequest(
      requestId: requestId,
      originWarehouse: originWarehouse,
      items: _items
          .map(
            (item) => DispatchItem(
              itemCode: item['item_code'],
              dispatchedQty: item['dispatched_qty'],
            ),
          )
          .toList(),
      dispatchedBy: currentUserId,
      dispatchNotes: _noteController.text.trim().isEmpty
          ? ""
          : _noteController.text.trim(),
    );

    context.read<InventoryBloc>().add(
      DispatchStockTransfer(request: dispatchRequest),
    );
  }

  bool _isDispatchDisabled() {
    return _items.any(
      (item) =>
          item['dispatched_qty'] > item['requested_qty'] ||
          item['dispatched_qty'] <= 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final buttonFontSize = isSmallScreen ? 14.0 : 16.0;
    final padding = isSmallScreen ? 12.0 : 16.0;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Text(
          'Dispatch Stock Transfer',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: isSmallScreen ? 16 : 18,
          ),
        ),
      ),
      body: BlocConsumer<InventoryBloc, InventoryState>(
        listener: (context, state) {
          if (state is StockTransferRequestLoaded) {
            // Store the loaded data
            setState(() {
              _loadedData = state.response.message.data;
              _hasLoadedOnce = true;
            });

            // Initialize items
            _initializeItems(state.response.message.data);
          } else if (state is DispatchStockTransferSuccess) {
            setState(() {
              _isDispatching = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Stock dispatched successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          } else if (state is DispatchStockTransferError) {
            setState(() {
              _isDispatching = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          // Show loading only for initial request load
          if (state is StockTransferRequestLoading && !_hasLoadedOnce) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show error only if no data has been loaded yet
          if (state is StockTransferRequestError && !_hasLoadedOnce) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: isSmallScreen ? 48 : 64,
                      color: Colors.red[300],
                    ),
                    SizedBox(height: isSmallScreen ? 12 : 16),
                    Text(
                      'Error loading request',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 6 : 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: isSmallScreen ? 13 : 14,
                        ),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 18 : 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<InventoryBloc>().add(
                          GetStockTransferRequest(requestId: widget.requestId),
                        );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 16 : 24,
                          vertical: isSmallScreen ? 10 : 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // If we have loaded data, show the content regardless of current state
          if (_loadedData != null) {
            final data = _loadedData!;

            return Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.all(padding),
                  padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(5),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              data.name,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 15 : 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          SizedBox(width: isSmallScreen ? 8 : 12),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 10 : 12,
                              vertical: isSmallScreen ? 4 : 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.orange[200]!),
                            ),
                            child: Text(
                              data.status,
                              style: TextStyle(
                                color: Colors.orange[900],
                                fontWeight: FontWeight.w600,
                                fontSize: isSmallScreen ? 11 : 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      _buildInfoRow(
                        Icons.warehouse_outlined,
                        'From',
                        data.originWarehouse,
                        isSmallScreen,
                      ),
                      SizedBox(height: isSmallScreen ? 6 : 8),
                      _buildInfoRow(
                        Icons.location_on_outlined,
                        'To',
                        data.destinationWarehouse,
                        isSmallScreen,
                      ),
                      SizedBox(height: isSmallScreen ? 6 : 8),
                      _buildInfoRow(
                        Icons.person_outline,
                        'Requested by',
                        data.requestedBy,
                        isSmallScreen,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: padding),
                    padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(5),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Items to Dispatch',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 12 : 16),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              child: DataTable(
                                headingRowHeight: isSmallScreen ? 48 : 56,
                                dataRowMinHeight: isSmallScreen ? 56 : 64,
                                dataRowMaxHeight: isSmallScreen ? 64 : 72,
                                columnSpacing: isSmallScreen ? 16 : 24,
                                headingRowColor: WidgetStateProperty.all(
                                  Colors.blue[50],
                                ),
                                columns: [
                                  DataColumn(
                                    label: Text(
                                      'Item Code',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: isSmallScreen ? 12 : 14,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Requested Qty',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: isSmallScreen ? 12 : 14,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Dispatch Qty',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: isSmallScreen ? 12 : 14,
                                      ),
                                    ),
                                  ),
                                ],
                                rows: List<DataRow>.generate(_items.length, (
                                  index,
                                ) {
                                  final requestedQty =
                                      _items[index]['requested_qty'];
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Text(
                                          _items[index]['item_code'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: isSmallScreen ? 12 : 13,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          requestedQty.toString(),
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: isSmallScreen ? 12 : 13,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: isSmallScreen ? 100 : 110,
                                          child: TextFormField(
                                            controller: _qtyControllers[index],
                                            keyboardType:
                                                const TextInputType.numberWithOptions(
                                                  decimal: true,
                                                ),
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                RegExp(r'^\d*\.?\d*'),
                                              ),
                                            ],
                                            style: TextStyle(
                                              fontSize: isSmallScreen ? 13 : 14,
                                            ),
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    horizontal: isSmallScreen
                                                        ? 10
                                                        : 12,
                                                    vertical: isSmallScreen
                                                        ? 14
                                                        : 16,
                                                  ),
                                              hintText: 'Max: $requestedQty',
                                              hintStyle: TextStyle(
                                                fontSize: isSmallScreen
                                                    ? 11
                                                    : 12,
                                                color: Colors.grey[400],
                                              ),
                                            ),
                                            onChanged: (value) {
                                              final qty =
                                                  double.tryParse(value) ?? 0;
                                              _updateDispatchedQty(
                                                index,
                                                qty,
                                                requestedQty,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(padding),
                  padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(5),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dispatch Note',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 10 : 12),
                      TextField(
                        controller: _noteController,
                        maxLines: isSmallScreen ? 2 : 3,
                        style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                        decoration: InputDecoration(
                          hintText: 'Add any notes about this dispatch...',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: isSmallScreen ? 12 : 13,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 12 : 16,
                            vertical: isSmallScreen ? 10 : 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(padding),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(5),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isDispatching || _isDispatchDisabled()
                        ? null
                        : () =>
                              _handleDispatch(data.name, data.originWarehouse),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                      padding: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 14 : 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isDispatching
                        ? SizedBox(
                            height: isSmallScreen ? 18 : 20,
                            width: isSmallScreen ? 18 : 20,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'Dispatch Stock',
                            style: TextStyle(
                              fontSize: buttonFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    bool isSmallScreen,
  ) {
    return Row(
      children: [
        Icon(icon, size: isSmallScreen ? 18 : 20, color: Colors.grey[600]),
        SizedBox(width: isSmallScreen ? 6 : 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: isSmallScreen ? 12 : 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.black87,
              fontSize: isSmallScreen ? 12 : 14,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
