import 'package:flutter/material.dart';
import 'package:pos/domain/responses/products/product_response.dart';
import 'package:pos/domain/responses/price_list_response.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/presentation/price/bloc/price_bloc.dart';
import 'package:pos/presentation/price/bloc/price_event.dart';
import 'package:pos/presentation/price/bloc/price_state.dart';

class ManagePriceSheet extends StatefulWidget {
  final ProductItem product;
  final String company;

  const ManagePriceSheet({
    super.key,
    required this.product,
    required this.company,
  });

  @override
  State<ManagePriceSheet> createState() => _ManagePriceSheetState();
}

class _ManagePriceSheetState extends State<ManagePriceSheet> {
  late TextEditingController _priceController;
  late TextEditingController _priceListController;
  List<PriceList> _priceLists = [];

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.product.price.toString(),
    );
    _priceListController = TextEditingController(
      text: widget.product.priceList.isEmpty
          ? 'Standard Selling'
          : widget.product.priceList,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 768;

    return BlocProvider(
      create: (context) => getIt<PriceBloc>()
        ..add(LoadPriceListsForPriceEvent(company: widget.company))
        ..add(
          GetProductPriceEvent(
            itemCode: widget.product.itemCode,
            company: widget.company,
          ),
        ),
      child: BlocConsumer<PriceBloc, PriceState>(
        listener: (context, state) {
          if (state is PriceSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.pop(context, true);
          } else if (state is ProductPriceLoaded) {
            _priceController.text = state.priceDetails.price.toString();
            if (state.priceDetails.priceList.isNotEmpty) {
              _priceListController.text = state.priceDetails.priceList;
            }
          } else if (state is PriceListsLoaded) {
            setState(() {
              _priceLists = state.priceLists;
              // If current price list is not in the loaded lists (rare), or empty,
              // we can keep the default or set to first available.
            });
          } else if (state is PriceFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 32.0 : 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(isTablet),
                    const SizedBox(height: 24),
                    _buildPriceListDropdown(context, isTablet),
                    const SizedBox(height: 16),
                    _buildPriceField(
                      controller: _priceController,
                      label: 'Price (${widget.product.priceCurrency})',
                      icon: Icons.payments,
                      required: true,
                    ),
                    const SizedBox(height: 32),
                    _buildFooter(isTablet, state),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPriceListDropdown(BuildContext context, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Price List',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue:
              _priceLists.any(
                (pl) => pl.priceListName == _priceListController.text,
              )
              ? _priceListController.text
              : null,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.list_alt, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: _priceLists.map((PriceList pl) {
            return DropdownMenuItem<String>(
              value: pl.priceListName,
              child: Text(pl.priceListName),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _priceListController.text = newValue;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildHeader(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Item Code: ${widget.product.itemCode}',
          style: TextStyle(
            fontSize: isTablet ? 14 : 12,
            color: Colors.blueGrey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(bool isTablet, PriceState state) {
    final isLoading = state is PriceLoading;
    final buttonStyle = isTablet
        ? ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
          )
        : ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          );

    final cancelStyle = isTablet
        ? OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 20),
            side: BorderSide(color: Colors.blueGrey[200]!),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
          )
        : OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: BorderSide(color: Colors.blueGrey[200]!),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          );

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isLoading ? null : () => Navigator.pop(context),
            style: cancelStyle,
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.blueGrey[700],
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Builder(
          builder: (context) => Expanded(
            child: ElevatedButton(
              onPressed: isLoading ? null : () => _savePrices(context),
              style: buttonStyle.copyWith(
                backgroundColor: WidgetStateProperty.all(
                  isLoading ? Colors.grey : const Color(0xFF2563EB),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Update Price',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = false,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (required)
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              children: const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          )
        else
          Text(
            label,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          readOnly: readOnly,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20),
            prefixText: label.contains('Price')
                ? '${widget.product.priceCurrency} '
                : null,
            fillColor: readOnly ? Colors.grey[50] : Colors.white,
            filled: readOnly,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  void _savePrices(BuildContext context) {
    if (_priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Price is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final price = double.tryParse(_priceController.text);
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid price'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<PriceBloc>().add(
      SetProductPriceEvent(
        itemCode: widget.product.itemCode,
        price: price,
        priceList: _priceListController.text,
        currency: widget.product.priceCurrency,
      ),
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    _priceListController.dispose();
    super.dispose();
  }
}
