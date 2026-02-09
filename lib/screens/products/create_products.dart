import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pos/presentation/widgets/custom_text_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/requests/products/create_product.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/domain/responses/products/item_brand.dart';
import 'package:pos/domain/responses/products/item_group.dart';
import 'package:pos/domain/responses/uom_response.dart';
import 'package:pos/presentation/products/bloc/products_bloc.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/core/dependency.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController _itemCodeController = TextEditingController();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _standardRateController = TextEditingController(
    text: '0.00',
  );
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();

  String? _selectedItemGroup;
  String? _selectedUom;
  String? _selectedItemType;
  String? _selectedBrand;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoadingData = true;
  bool _isCreatingProduct = false;

  CurrentUserResponse? currentUserResponse;
  bool _isStockItem = true;
  bool _isSalesItem = true;
  bool _isPurchaseItem = false;

  List<ItemGroup> itemGroups = [];
  List<UOM> uoms = [];
  List<Brand> brands = [];
  String? errorMessage;

  bool _itemGroupsLoaded = false;
  bool _uomsLoaded = false;
  bool _brandsLoaded = false;

  Future<CurrentUserResponse?> getSavedCurrentUser() async {
    final storage = getIt<StorageService>();
    final userString = await storage.getString('current_user');

    if (userString == null) return null;

    final Map<String, dynamic> jsonMap = jsonDecode(userString);
    return CurrentUserResponse.fromJson(jsonMap);
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _loadCurrentUser();

    // Safety timeout to prevent infinite spinner
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && _isLoadingData && !_itemGroupsLoaded && !_uomsLoaded) {
        debugPrint('AddProductPage - Loading timeout reached');
        setState(() {
          _isLoadingData = false;
          errorMessage =
              errorMessage ??
              'Loading timed out. Please check your connection.';
        });
      }
    });
  }

  Future<void> _loadCurrentUser() async {
    final savedUser = await getSavedCurrentUser();
    debugPrint("current user ${savedUser?.message.company.name}");

    if (!mounted) return;

    setState(() {
      currentUserResponse = savedUser;
    });
  }

  void _loadInitialData() {
    final productsBloc = context.read<ProductsBloc>();
    productsBloc.add(GetItemGroup());
    productsBloc.add(GetUnitOfMeasure());
    productsBloc.add(GetBrand());
  }

  void _clearForm() {
    _itemCodeController.clear();
    _itemNameController.clear();
    _standardRateController.text = '0.00';
    _descriptionController.clear();
    _barcodeController.clear();

    setState(() {
      _selectedItemGroup = null;
      _selectedUom = null;
      _selectedItemType = null;
      _selectedBrand = 'None';
      _isStockItem = true;
      _isSalesItem = true;
      _isPurchaseItem = false;
    });
  }

  void _createProduct() {
    if (!mounted) return;

    final formState = _formKey.currentState;
    if (formState == null) {
      debugPrint('Form not ready yet');
      return;
    }

    if (formState.validate()) {
      setState(() {
        _isCreatingProduct = true;
      });

      final request = CreateProductRequest(
        itemCode: _itemCodeController.text.trim(),
        itemName: _itemNameController.text.trim(),
        itemGroup: _selectedItemGroup ?? '',
        stockUom: _selectedUom ?? '',
        standardRate:
            double.tryParse(_standardRateController.text.trim()) ?? 0.0,
        description: _descriptionController.text.trim(),
        isStockItem: _isStockItem,
        isSalesItem: _isSalesItem,
        isPurchaseItem: _isPurchaseItem,
        brand: (_selectedBrand == null || _selectedBrand == 'None')
            ? ''
            : _selectedBrand!,
        barcode: _barcodeController.text.trim(),
        etimsCountryOfOriginCode: '',
        productType: _selectedItemType ?? '',
        packagingUnitCode: '',
        unitOfQuantityCode: '',
        itemClassification: '',
        taxationType: '',
        company: currentUserResponse!.message.company.name,
      );

      context.read<ProductsBloc>().add(
        CreateProduct(createProductRequest: request),
      );
    }
  }

  @override
  void dispose() {
    _itemCodeController.dispose();
    _itemNameController.dispose();
    _standardRateController.dispose();
    _descriptionController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductsBloc, ProductsState>(
      listener: (context, state) {
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
        } else if (state is ProductsCreateStateSuccess) {
          // Product created successfully
          setState(() {
            _isCreatingProduct = false;
          });

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product created successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // Clear form fields
          _clearForm();

          // Optionally navigate back or refresh product list
          // context.read<ProductsBloc>().add(GetAllProducts());
          Navigator.pop(context, true);
        } else if (state is ProductsStateFailure) {
          setState(() {
            _isCreatingProduct = false;
            errorMessage = state.error;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.error}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      builder: (context, state) {
        // Handle loading/error states
        if (_isLoadingData && errorMessage == null) {
          return _buildLoadingScreen();
        }

        if (errorMessage != null && itemGroups.isEmpty && uoms.isEmpty) {
          return _buildErrorScreen();
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text(
              'Create New Product',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            elevation: 0,
          ),
          body: _buildContent(),
        );
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Product'),
        centerTitle: true,
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Product'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 50, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading data',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoadingData = true;
                  errorMessage = null;
                });
                _loadInitialData();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First row: Item Code and Item Name
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        controller: _itemCodeController,
                        readOnly: false,
                        label: 'Item Code',
                        hintText: 'Input code',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        controller: _itemNameController,
                        label: 'Item Name*',
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

            // Second row: Item Group and Unit of Measure
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
                      _buildTextField(
                        controller: _standardRateController,
                        label: 'Standard Rate*',
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        hintText: 'Give a description',
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        controller: _barcodeController,
                        label: 'Barcode',
                        hintText: 'Input barcode',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildProductTypeSwitches(),
            const SizedBox(height: 32),

            // Create Product Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_isCreatingProduct) return;
                  _createProduct();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isCreatingProduct
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Create Product',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
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

  Widget _buildProductTypeSwitches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Product Type Options'),
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

  Widget _buildBrandDropdown() {
    List<String> brandNames = ['None'];
    for (var brand in brands) {
      if (brand.brandName.isNotEmpty && brand.brandName != 'None') {
        brandNames.add(brand.brandName);
      }
    }
    if (_selectedBrand != null && !brandNames.contains(_selectedBrand)) {
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
    String? label,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
  }) {
    return CustomTextField(
      controller: controller,
      hint: hintText,
      label: label,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      enabled: !_isCreatingProduct,
      inputFormatters: inputFormatters,
      readOnly: readOnly,
    );
  }

  void _checkDataLoaded() {
    if (_itemGroupsLoaded && _uomsLoaded && _brandsLoaded) {
      setState(() {
        _isLoadingData = false;
      });
    }
  }
}
