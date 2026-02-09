import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/responses/price_list_response.dart';
import 'package:pos/presentation/price_list/bloc/price_list_bloc.dart';
import 'package:pos/presentation/price_list/bloc/price_list_event.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/core/services/storage_service.dart';

class PriceListFormDialog extends StatefulWidget {
  final PriceList? priceList;
  const PriceListFormDialog({super.key, this.priceList});

  @override
  State<PriceListFormDialog> createState() => _PriceListFormDialogState();
}

class _PriceListFormDialogState extends State<PriceListFormDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _currencyController = TextEditingController(
    text: 'KES',
  );
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isEnabled = true;
  bool _isBuying = false;
  bool _isSelling = true;

  @override
  void initState() {
    super.initState();
    if (widget.priceList != null) {
      _nameController.text = widget.priceList!.priceListName;
      _currencyController.text = widget.priceList!.currency;
      _isEnabled = widget.priceList!.isEnabled;
      _isBuying = widget.priceList!.isBuying;
      _isSelling = widget.priceList!.isSelling;
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
        if (widget.priceList == null) {
          context.read<PriceListBloc>().add(
            CreatePriceList(
              company: company,
              priceListName: _nameController.text.trim(),
              currency: _currencyController.text.trim(),
              enabled: _isEnabled,
              buying: _isBuying,
              selling: _isSelling,
            ),
          );
        } else {
          context.read<PriceListBloc>().add(
            UpdatePriceListEvent(
              name: widget.priceList!.name,
              newPriceListName: _nameController.text.trim(),
              currency: _currencyController.text.trim(),
              enabled: _isEnabled,
              buying: _isBuying,
              selling: _isSelling,
            ),
          );
        }
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = MediaQuery.of(context).size.width >= 600;
        final width = isTablet
            ? 500.0
            : MediaQuery.of(context).size.width * 0.9;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            widget.priceList == null ? 'Create Price List' : 'Edit Price List',
            style: TextStyle(
              fontSize: isTablet ? 24 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: width,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Price List Name',
                        hintText: 'Enter price list name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _currencyController,
                      decoration: InputDecoration(
                        labelText: 'Currency',
                        hintText: 'e.g. KES, USD',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a currency';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Enabled'),
                      value: _isEnabled,
                      onChanged: (val) => setState(() => _isEnabled = val),
                      secondary: const Icon(Icons.check_circle_outline),
                    ),
                    SwitchListTile(
                      title: const Text('Buying'),
                      value: _isBuying,
                      onChanged: (val) => setState(() => _isBuying = val),
                      secondary: const Icon(Icons.shopping_cart_outlined),
                    ),
                    SwitchListTile(
                      title: const Text('Selling'),
                      value: _isSelling,
                      onChanged: (val) => setState(() => _isSelling = val),
                      secondary: const Icon(Icons.sell_outlined),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
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
                  : Text(widget.priceList == null ? 'Submit' : 'Update'),
            ),
          ],
        );
      },
    );
  }
}
