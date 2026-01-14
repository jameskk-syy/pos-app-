import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pos/domain/requests/stock_entry.dart';
import 'package:pos/domain/responses/get_current_user.dart';
import 'package:pos/domain/responses/product_response.dart';
import 'package:pos/domain/responses/store_response.dart';
import 'package:pos/presentation/products/bloc/products_bloc.dart';
import 'package:pos/presentation/stores/bloc/store_bloc.dart';
import 'package:pos/presentation/inventory/bloc/inventory_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StockEntryPage extends StatefulWidget {
  const StockEntryPage({super.key});

  @override
  State<StockEntryPage> createState() => _StockEntryPageState();
}

class _StockEntryPageState extends State<StockEntryPage> {
  String? selectedStockType;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String? selectedWarehouse;
  final TextEditingController purposeController = TextEditingController();
  List<StockItemEntry> items = [];

  List<Warehouse> warehouses = [];
  List<ProductItem> products = [];
  bool isLoadingWarehouses = false;
  bool isLoadingProducts = false;
  String? companyName;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<CurrentUserResponse?> _getSavedCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('current_user');
    if (userString == null) return null;
    return CurrentUserResponse.fromJson(jsonDecode(userString));
  }

  Future<void> _loadCurrentUser() async {
    final savedUser = await _getSavedCurrentUser();
    if (!mounted || savedUser == null) return;

    setState(() {
      companyName = savedUser.message.company.name;
    });

    context.read<StoreBloc>().add(
      GetAllStores(company: savedUser.message.company.name),
    );
    context.read<ProductsBloc>().add(
      GetAllProducts(company: savedUser.message.company.name),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return MultiBlocListener(
      listeners: [
        BlocListener<StoreBloc, StoreState>(
          listener: (context, state) {
            if (state is StoreStateLoading) {
              setState(() => isLoadingWarehouses = true);
            } else if (state is StoreStateSuccess) {
              setState(() {
                warehouses = state.storeGetResponse.message.data;
                isLoadingWarehouses = false;
              });
            } else if (state is StoreStateFailure) {
              setState(() => isLoadingWarehouses = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error loading warehouses: ${state.error}'),
                ),
              );
            }
          },
        ),
        BlocListener<ProductsBloc, ProductsState>(
          listener: (context, state) {
            if (state is ProductsStateLoading) {
              setState(() => isLoadingProducts = true);
            } else if (state is ProductsStateSuccess) {
              setState(() {
                products = state.productResponseSimple.products;
                isLoadingProducts = false;
              });
            } else if (state is ProductsStateFailure) {
              setState(() => isLoadingProducts = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error loading products: ${state.error}'),
                ),
              );
            }
          },
        ),
        BlocListener<InventoryBloc, InventoryState>(
          listener: (context, state) {
            if (state is CreateStockEntryLoading) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    const Center(child: CircularProgressIndicator()),
              );
            } else if (state is CreateStockEntrySuccess) {
              Navigator.pop(context); // Close loading dialog

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Stock entry ${state.response.message.data.name} created successfully',
                  ),
                  backgroundColor: Colors.green,
                ),
              );

              Navigator.pop(context); // Close the page
            } else if (state is CreateStockEntryError) {
              Navigator.pop(context); // Close loading dialog

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text(
            'Stock Entry',
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          actions: [
            TextButton(
              onPressed: () {},
              child: const Text(
                'View History',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isTablet ? 24 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDropdownField(
                      label: 'Stock Entry Type',
                      required: true,
                      hint: 'Choose a type',
                      value: selectedStockType,
                      items: [
                        'Material Receipt',
                        'Material Issue',
                        'Material Transfer',
                        'Manufacture',
                        'Repack',
                        'Material Transfer for Manufacture',
                        'Material Consumption for Manufacture',
                        'Material Transfer for Repack',
                        'Subcontract',
                      ],
                      onChanged: (v) => setState(() => selectedStockType = v),
                    ),
                    const SizedBox(height: 20),
                    _buildDateField(
                      label: 'Posting Date',
                      required: true,
                      date: selectedDate,
                    ),
                    const SizedBox(height: 20),
                    _buildTimeField(label: 'Posting Time', time: selectedTime),
                    const SizedBox(height: 4),
                    Text(
                      'Optional: uses HH:MM:SS',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: 'Purpose',
                      controller: purposeController,
                      hint: 'Add a purpose',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Optional: auto-determined from type',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 20),
                    _buildDropdownField(
                      label: 'Default Target Warehouse',
                      required: false,
                      hint: isLoadingWarehouses
                          ? 'Loading warehouses...'
                          : 'Choose a warehouse',
                      value: selectedWarehouse,
                      items: warehouses.map((w) => w.name).toList(),
                      onChanged: (v) => setState(() => selectedWarehouse = v),
                    ),
                    const SizedBox(height: 24),
                    _buildItemsSection(isTablet),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required bool required,
    required String hint,
    String? value,
    List<String>? items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            if (required) const Text('*', style: TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            isDense: true,
          ),
          items:
              items?.map((String item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList() ??
              [],
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required bool required,
    required DateTime date,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            if (required) const Text('*', style: TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (picked != null) setState(() => selectedDate = picked);
          },
          child: _box(
            DateFormat('yyyy-MM-dd').format(date),
            Icons.calendar_today,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField({required String label, required TimeOfDay time}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: time,
            );
            if (picked != null) setState(() => selectedTime = picked);
          },
          child: _box(
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00',
            Icons.access_time,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemsSection(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Items',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        _buildItemsTable(),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => setState(() => items.add(StockItemEntry())),
          icon: const Icon(Icons.add),
          label: const Text('Add Item'),
        ),
      ],
    );
  }

  Widget _buildItemsTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: 900,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.grey[100],
              child: Row(
                children: const [
                  _Header('Item Code*', 200),
                  _Header('Qty*', 120),
                  _Header('Warehouse', 220),
                  _Header('Rate*', 120),
                  _Header('Actions', 80),
                ],
              ),
            ),
            if (items.isEmpty)
              _itemRow(null, -1)
            else
              ...items.asMap().entries.map((e) => _itemRow(e.value, e.key)),
          ],
        ),
      ),
    );
  }

  Widget _itemRow(StockItemEntry? item, int index) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          _itemCodeDropdown(item, index, 200),
          _quantityField(item, index, 120),
          _warehouseDropdown(item, index, 220),
          _cell(item?.product?.standardRate.toStringAsFixed(2) ?? '0.00', 120),
          SizedBox(
            width: 80,
            child: index >= 0
                ? IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => setState(() => items.removeAt(index)),
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _itemCodeDropdown(StockItemEntry? item, int index, double width) {
    if (index < 0) {
      return _cell('Select Items', width);
    }

    return SizedBox(
      width: width,
      child: DropdownButtonFormField<String>(
        initialValue: item?.product?.itemCode,
        isExpanded: true,
        decoration: InputDecoration(
          hintText: 'Select Items',
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 12),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
        style: const TextStyle(fontSize: 12, color: Colors.black),
        items: products.map((product) {
          return DropdownMenuItem<String>(
            value: product.itemCode,
            child: Text(
              product.itemName.length > 25
                  ? '${product.itemName.substring(0, 25)}...'
                  : product.itemName,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            final selectedProduct = products.firstWhere(
              (p) => p.itemCode == value,
            );
            setState(() {
              items[index].product = selectedProduct;
            });
          }
        },
      ),
    );
  }

  Widget _quantityField(StockItemEntry? item, int index, double width) {
    if (index < 0) {
      return _cell('1', width);
    }

    return SizedBox(
      width: width,
      child: TextField(
        controller: item?.qtyController,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 12),
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          isDense: true,
        ),
        onChanged: (value) {
          final qty = int.tryParse(value) ?? 1;
          setState(() {
            items[index].quantity = qty;
          });
        },
      ),
    );
  }

  Widget _warehouseDropdown(StockItemEntry? item, int index, double width) {
    if (index < 0) {
      return _cell('Choose Warehouse', width);
    }

    return SizedBox(
      width: width,
      child: DropdownButtonFormField<String>(
        initialValue: item?.warehouse,
        isExpanded: true,
        decoration: InputDecoration(
          hintText: 'Choose Warehouse',
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 12),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          isDense: true,
        ),
        style: const TextStyle(fontSize: 12, color: Colors.black),
        items: warehouses.map((warehouse) {
          return DropdownMenuItem<String>(
            value: warehouse.name,
            child: Text(
              warehouse.warehouseName.length > 30
                  ? '${warehouse.warehouseName.substring(0, 30)}...'
                  : warehouse.warehouseName,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            items[index].warehouse = value;
          });
        },
      ),
    );
  }

  Widget _cell(String text, double width) {
    return SizedBox(
      width: width,
      child: InputDecorator(
        decoration: const InputDecoration(contentPadding: EdgeInsets.all(12)),
        child: Text(
          text,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ),
    );
  }

  Widget _box(String text, IconData icon) {
    return InputDecorator(
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text),
          Icon(icon, size: 18, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(10),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                _handleCreateStockEntry();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Create',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleCreateStockEntry() {
    // Validate required fields
    if (selectedStockType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a stock entry type')),
      );
      return;
    }

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }

    for (var item in items) {
      if (item.product == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an item for all rows')),
        );
        return;
      }

      if (item.warehouse == null || item.warehouse!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a warehouse for all items'),
          ),
        );
        return;
      }
    }

    if (companyName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Company information not available')),
      );
      return;
    }

    final postingDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    final postingTime =
        '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}:00';

    final requestItems = items.map((item) {
      return StockEntryItem(
        itemCode: item.product!.itemCode,
        qty: item.quantity,
        tWarehouse: item.warehouse!,
        basicRate: item.product!.standardRate,
      );
    }).toList();

    final request = CreateStockEntryRequest(
      stockEntryType: selectedStockType!,
      items: requestItems,
      postingDate: postingDate,
      postingTime: postingTime,
      toWarehouse: selectedWarehouse,
      company: companyName!,
      purpose: purposeController.text.trim().isNotEmpty
          ? purposeController.text.trim()
          : null,
    );
    context.read<InventoryBloc>().add(CreateStockEntry(request: request));
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
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}

class StockItemEntry {
  ProductItem? product;
  int quantity;
  String? warehouse;
  final TextEditingController qtyController;

  StockItemEntry({this.product, this.quantity = 1, this.warehouse})
    : qtyController = TextEditingController(text: quantity.toString());

  void dispose() {
    qtyController.dispose();
  }
}
