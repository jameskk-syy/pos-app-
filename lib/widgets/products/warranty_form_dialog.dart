import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/responses/products/product_response.dart';
import 'package:pos/presentation/warranties/bloc/warranties_bloc.dart';
import 'package:pos/presentation/warranties/bloc/warranties_event.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/core/services/storage_service.dart';

class WarrantyFormDialog extends StatefulWidget {
  final ProductItem product;
  const WarrantyFormDialog({super.key, required this.product});

  @override
  State<WarrantyFormDialog> createState() => _WarrantyFormDialogState();
}

class _WarrantyFormDialogState extends State<WarrantyFormDialog> {
  final TextEditingController _periodController = TextEditingController();
  String _selectedUnit = 'Days';
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final List<String> _units = ['Days', 'Months', 'Years'];

  @override
  void initState() {
    super.initState();
    if (widget.product.warrantyPeriod != null &&
        widget.product.warrantyPeriod! > 0) {
      _periodController.text = widget.product.warrantyPeriod.toString();
    }
    if (widget.product.warrantyPeriodUnit != null &&
        _units.contains(widget.product.warrantyPeriodUnit)) {
      _selectedUnit = widget.product.warrantyPeriodUnit!;
    }
  }

  Future<String?> _getCompany() async {
    final storage = getIt<StorageService>();
    final userString = await storage.getString('current_user');
    if (userString == null) return null;
    final userMap = jsonDecode(userString);
    if (userMap['message'] != null && userMap['message']['company'] != null) {
      return userMap['message']['company']['name'];
    }
    return null;
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final company = await _getCompany();
      if (!mounted) return;

      if (company != null) {
        context.read<WarrantiesBloc>().add(
          SetWarrantyEvent(
            company: company,
            itemCode: widget.product.itemCode,
            warrantyPeriod: int.parse(_periodController.text.trim()),
            warrantyPeriodUnit: _selectedUnit,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not determine company')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final width = isTablet ? 400.0 : MediaQuery.of(context).size.width * 0.85;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        widget.product.warrantyPeriod != null &&
                widget.product.warrantyPeriod! > 0
            ? 'Update Warranty'
            : 'Set Warranty',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: width,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Product: ${widget.product.itemName}",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _periodController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Warranty Period',
                  hintText: 'Enter duration',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.timer_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Required';
                  if (int.tryParse(value) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedUnit,
                decoration: InputDecoration(
                  labelText: 'Unit',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                ),
                items: _units.map((unit) {
                  return DropdownMenuItem(value: unit, child: Text(unit));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedUnit = val);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
