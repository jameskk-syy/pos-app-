import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/responses/product_response.dart';
import 'package:pos/domain/responses/item_brand.dart';
import 'package:pos/domain/responses/item_group.dart';
import 'package:pos/domain/responses/uom_response.dart';
import 'package:pos/presentation/products/bloc/products_bloc.dart';
import 'package:pos/domain/requests/create_product.dart';

class EditProductSheet extends StatefulWidget {
  final ProductItem product;
  final Function(ProductItem) onSave;

  const EditProductSheet({
    super.key,
    required this.product,
    required this.onSave,
  });

  @override
  State<EditProductSheet> createState() => _EditProductSheetState();
}

class _EditProductSheetState extends State<EditProductSheet> {
  late TextEditingController _itemNameController;
  late TextEditingController _itemCodeController;
  late TextEditingController _standardRateController;
  // late TextEditingController _descriptionController;
  // late TextEditingController _barcodeController;
  // late TextEditingController _brandController;

  late String? _selectedItemGroup;
  late String? _selectedUom;
  late String? _selectedBrand;
  late bool _isStockItem;
  late bool _isSalesItem;
  late bool _isPurchaseItem;

  List<ItemGroup> itemGroups = [];
  List<UOM> uoms = [];
  List<Brand> brands = [];

  bool _isLoading = true;
  bool _itemGroupsLoaded = false;
  bool _uomsLoaded = false;
  bool _brandsLoaded = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _itemNameController = TextEditingController(text: widget.product.itemName);
    _itemCodeController = TextEditingController(text: widget.product.itemCode);
    _standardRateController = TextEditingController(
      text: widget.product.standardRate.toString(),
    );
    // _brandController = TextEditingController(
    //   text: widget.product.brand ?? '',
    // );

    _selectedItemGroup = widget.product.itemGroup;
    _selectedUom = widget.product.stockUom;
    _selectedBrand =
        (widget.product.brand == null || widget.product.brand!.isEmpty)
        ? 'None'
        : widget.product.brand;
    _isStockItem = widget.product.isStockItem == 1;
    _isSalesItem = widget.product.isSalesItem == 1;
    _isPurchaseItem = widget.product.isPurchaseItem == 1;

    _loadInitialData();

    // Safety timeout to prevent infinite spinner
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && _isLoading && !_itemGroupsLoaded && !_uomsLoaded) {
        debugPrint('EditProductSheet - Loading timeout reached');
        setState(() {
          _isLoading = false;
          _errorMessage =
              _errorMessage ??
              'Loading timed out. Please check your connection.';
        });
      }
    });
  }

  void _loadInitialData() {
    final productsBloc = context.read<ProductsBloc>();
    productsBloc.add(GetItemGroup());
    productsBloc.add(GetUnitOfMeasure());
    productsBloc.add(GetBrand());
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _itemCodeController.dispose();
    _standardRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductsBloc, ProductsState>(
      listener: (context, state) {
        debugPrint('EditProductSheet listener - state: ${state.runtimeType}');
        if (state is ProductsItemGroupsStateSuccess) {
          setState(() {
            itemGroups = state.itemGroupResponse.message.itemGroups;
            _itemGroupsLoaded = true;
            _checkDataLoaded();
          });
        } else if (state is ProductsUomStateSuccess) {
          setState(() {
            uoms = state.uomResponse.uoms;
            _uomsLoaded = true;
            _checkDataLoaded();
          });
        } else if (state is ProductsBrandStateSuccess) {
          setState(() {
            brands = state.brandResponse.brands;
            _brandsLoaded = true;
            _checkDataLoaded();
          });
        } else if (state is ProductsUpdateStateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else if (state is ProductsStateFailure) {
          debugPrint('EditProductSheet listener - FAILURE: ${state.error}');
          setState(() {
            _errorMessage = state.error;
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading data: ${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (_isLoading) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [const Center(child: CircularProgressIndicator())],
            ),
          );
        }

        if (_errorMessage != null && itemGroups.isEmpty && uoms.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Failed to load required data',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage ?? 'Unknown error occurred',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                          _errorMessage = null;
                        });
                        _loadInitialData();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // First row: Item Code and Item Name
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle('Item Code*'),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  controller: _itemCodeController,
                                  hintText: 'Input code',
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Item code is required';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle('Item Name*'),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  controller: _itemNameController,
                                  hintText: 'Enter item name',
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Item name is required';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle('Item Group*'),
                                const SizedBox(height: 8),
                                _buildItemGroupDropdown(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle('Unit of Measure*'),
                                const SizedBox(height: 8),
                                _buildUomDropdown(),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Third row: Standard Rate and Brand
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle('Standard Rate*'),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  controller: _standardRateController,
                                  hintText: '0.00',
                                  keyboardType: TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Standard rate is required';
                                    }
                                    if (double.tryParse(value) == null) {
                                      return 'Enter a valid number';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle('Brand'),
                                const SizedBox(height: 8),
                                _buildBrandDropdown(),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Fourth row: Description and Barcode
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // _buildSectionTitle('Description'),
                                const SizedBox(height: 8),
                                // _buildTextField(
                                //   hintText: 'Give a description',
                                //   maxLines: 3,
                                // ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // _buildSectionTitle('Barcode'),
                                const SizedBox(height: 8),
                                // _buildTextField(
                                //   controller: _barcodeController,
                                //   hintText: 'Input barcode',
                                // ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      _buildProductTypeSwitches(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: state is ProductsStateLoading
                          ? null
                          : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: state is ProductsStateLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItemGroupDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedItemGroup,
      decoration: InputDecoration(
        hintText: itemGroups.isEmpty ? 'No groups available' : 'Select group',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
        isDense: true,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Item group is required';
        }
        return null;
      },
      isExpanded: true,
      style: const TextStyle(fontSize: 14, overflow: TextOverflow.ellipsis),
      items: itemGroups.map((item) {
        return DropdownMenuItem<String>(
          value: item.name,
          child: Text(
            item.itemGroupName,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedItemGroup = value;
        });
      },
    );
  }

  Widget _buildBrandDropdown() {
    List<String> brandNames = ['None'];
    for (var brand in brands) {
      if (brand.brandName.isNotEmpty && brand.brandName != 'None') {
        brandNames.add(brand.brandName);
      }
    }

    if (_selectedBrand != null &&
        _selectedBrand != 'None' &&
        !brandNames.contains(_selectedBrand)) {
      brandNames.add(_selectedBrand!);
    }

    return DropdownButtonFormField<String>(
      initialValue: _selectedBrand ?? 'None',
      decoration: InputDecoration(
        hintText: brands.isEmpty ? 'No brands available' : 'Select brand',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
        isDense: true,
      ),
      isExpanded: true,
      style: const TextStyle(fontSize: 14, overflow: TextOverflow.ellipsis),
      items: brandNames.map((name) {
        return DropdownMenuItem<String>(
          value: name,
          child: Text(
            name,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedBrand = value;
        });
      },
    );
  }

  Widget _buildUomDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedUom,
      decoration: InputDecoration(
        hintText: uoms.isEmpty ? 'No UOMs available' : 'Choose a unit',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
        isDense: true,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Unit of measure is required';
        }
        return null;
      },
      isExpanded: true,
      style: const TextStyle(fontSize: 14, overflow: TextOverflow.ellipsis),
      items: uoms.map((uom) {
        return DropdownMenuItem<String>(
          value: uom.name,
          child: Text(
            uom.uomName,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedUom = value;
        });
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.grey[700],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildProductTypeSwitches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Product Type Options',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              SwitchListTile(
                title: const Text(
                  'Is Stock Item',
                  style: TextStyle(fontSize: 14),
                ),
                subtitle: const Text(
                  'Maintain inventory for this item',
                  style: TextStyle(fontSize: 12),
                ),
                value: _isStockItem,
                onChanged: (val) => setState(() => _isStockItem = val),
                activeThumbColor: const Color(0xFF2563EB),
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text(
                  'Is Sales Item',
                  style: TextStyle(fontSize: 14),
                ),
                subtitle: const Text(
                  'Allow this item to be sold',
                  style: TextStyle(fontSize: 12),
                ),
                value: _isSalesItem,
                onChanged: (val) => setState(() => _isSalesItem = val),
                activeThumbColor: const Color(0xFF2563EB),
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text(
                  'Is Purchase Item',
                  style: TextStyle(fontSize: 14),
                ),
                subtitle: const Text(
                  'Allow this item to be purchased',
                  style: TextStyle(fontSize: 12),
                ),
                value: _isPurchaseItem,
                onChanged: (val) => setState(() => _isPurchaseItem = val),
                activeThumbColor: const Color(0xFF2563EB),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _checkDataLoaded() {
    if (_itemGroupsLoaded && _uomsLoaded && _brandsLoaded) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _saveChanges() {
    // Validate required fields
    if (_itemNameController.text.isEmpty ||
        _itemCodeController.text.isEmpty ||
        _standardRateController.text.isEmpty ||
        _selectedItemGroup == null ||
        _selectedUom == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate price
    double? price;
    try {
      price = double.tryParse(_standardRateController.text);
      if (price == null) {
        throw FormatException('Invalid price format');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid price'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final updatedProductRequest = CreateProductRequest(
      itemCode: _itemCodeController.text.trim(),
      itemName: _itemNameController.text.trim(),
      itemGroup: _selectedItemGroup!,
      stockUom: _selectedUom!,
      standardRate: price,
      description: '', // Not in ProductItem
      isStockItem: _isStockItem,
      isSalesItem: _isSalesItem,
      isPurchaseItem: _isPurchaseItem,
      brand: (_selectedBrand == null || _selectedBrand == 'None')
          ? ''
          : _selectedBrand!,
      barcode: '', // Not in ProductItem
      etimsCountryOfOriginCode: '', // Not in ProductItem
      productType: '', // Not in ProductItem
      packagingUnitCode: '', // Not in ProductItem
      unitOfQuantityCode: '', // Not in ProductItem
      itemClassification: '', // Not in ProductItem
      taxationType: '', // Not in ProductItem
      company: '', // Not in ProductItem, maybe we can get it from somewhere?
    );

    context.read<ProductsBloc>().add(
      UpdateProduct(updateProductRequest: updatedProductRequest),
    );
  }
}
