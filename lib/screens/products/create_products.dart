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

  // ─── Searchable picker bottom sheet ──────────────────────────────────────

  /// Opens a bottom sheet with a search field and a filterable list.
  /// Returns the selected value or null if dismissed.
  Future<T?> _showSearchableBottomSheet<T>({
    required BuildContext context,
    required String title,
    required List<T> items,
    required String Function(T) displayLabel,
    required T? currentValue,
  }) async {
    final searchController = TextEditingController();
    List<T> filtered = List.from(items);

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              builder: (_, scrollController) {
                return Column(
                  children: [
                    // Handle bar
                    const SizedBox(height: 8),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Search field
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: searchController,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          suffixIcon: searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    searchController.clear();
                                    setModalState(() {
                                      filtered = List.from(items);
                                    });
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (query) {
                          setModalState(() {
                            filtered = items
                                .where(
                                  (item) => displayLabel(
                                    item,
                                  ).toLowerCase().contains(query.toLowerCase()),
                                )
                                .toList();
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    // List
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(
                              child: Text(
                                'No results found',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: filtered.length,
                              itemBuilder: (_, index) {
                                final item = filtered[index];
                                final label = displayLabel(item);
                                final isSelected =
                                    currentValue != null &&
                                    displayLabel(currentValue) == label;
                                return ListTile(
                                  title: Text(
                                    label,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? const Color(0xFF2563EB)
                                          : Colors.black87,
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          color: Color(0xFF2563EB),
                                          size: 18,
                                        )
                                      : null,
                                  onTap: () => Navigator.pop(ctx, item),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  // ─── Picker field widget ──────────────────────────────────────────────────

  /// A tappable field that looks like the existing dropdowns but opens the
  /// searchable bottom-sheet on tap.
  Widget _buildPickerField({
    required String hint,
    required String? selectedLabel,
    required VoidCallback onTap,
    String? Function(String?)? validator,
  }) {
    return FormField<String>(
      initialValue: selectedLabel,
      validator: validator,
      builder: (fieldState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: fieldState.hasError ? Colors.red : Colors.grey[300]!,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedLabel ?? hint,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 14,
                          color: selectedLabel != null
                              ? Colors.black87
                              : Colors.grey[500],
                        ),
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            if (fieldState.hasError) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  fieldState.errorText!,
                  style: const TextStyle(fontSize: 12, color: Colors.red),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  // ─── Dropdown builders ────────────────────────────────────────────────────

  Widget _buildItemGroupDropdown() {
    final selectedGroup = itemGroups
        .where((g) => g.name == _selectedItemGroup)
        .firstOrNull;

    return _buildPickerField(
      hint: itemGroups.isEmpty ? 'No groups available' : 'Select group',
      selectedLabel: selectedGroup?.itemGroupName,
      validator: (_) {
        if (_selectedItemGroup == null || _selectedItemGroup!.isEmpty) {
          return 'Item group is required';
        }
        return null;
      },
      onTap: () async {
        final result = await _showSearchableBottomSheet<ItemGroup>(
          context: context,
          title: 'Select Item Group',
          items: itemGroups,
          displayLabel: (g) => g.itemGroupName,
          currentValue: selectedGroup,
        );
        if (result != null) {
          setState(() => _selectedItemGroup = result.name);
          _formKey.currentState?.validate();
        }
      },
    );
  }

  Widget _buildUomDropdown() {
    final selectedUom = uoms.where((u) => u.name == _selectedUom).firstOrNull;

    return _buildPickerField(
      hint: uoms.isEmpty ? 'No UOMs available' : 'Choose a unit',
      selectedLabel: selectedUom?.uomName,
      validator: (_) {
        if (_selectedUom == null || _selectedUom!.isEmpty) {
          return 'Unit of measure is required';
        }
        return null;
      },
      onTap: () async {
        final result = await _showSearchableBottomSheet<UOM>(
          context: context,
          title: 'Select Unit of Measure',
          items: uoms,
          displayLabel: (u) => u.uomName,
          currentValue: selectedUom,
        );
        if (result != null) {
          setState(() => _selectedUom = result.name);
          _formKey.currentState?.validate();
        }
      },
    );
  }

  Widget _buildBrandDropdown() {
    // Build a list that always starts with a "None" sentinel
    final brandItems = [
      Brand(name: 'None', brandName: 'None'),
      ...brands.where((b) => b.brandName.isNotEmpty && b.brandName != 'None'),
    ];

    final selectedBrand = brandItems
        .where((b) => b.brandName == (_selectedBrand ?? 'None'))
        .firstOrNull;

    return _buildPickerField(
      hint: brands.isEmpty ? 'No brands available' : 'Select brand',
      selectedLabel: selectedBrand?.brandName,
      onTap: () async {
        final result = await _showSearchableBottomSheet<Brand>(
          context: context,
          title: 'Select Brand',
          items: brandItems,
          displayLabel: (b) => b.brandName,
          currentValue: selectedBrand,
        );
        if (result != null) {
          setState(() => _selectedBrand = result.brandName);
        }
      },
    );
  }

  // ─── Two-column row helper ─────────────────────────────────────────────────

  Widget _buildTwoColumnRow({required Widget left, required Widget right}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 16),
        Expanded(child: right),
      ],
    );
  }

  // ─── Screens ──────────────────────────────────────────────────────────────

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
          setState(() {
            _isCreatingProduct = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product created successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          _clearForm();
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
            // Row 1: Item Code & Item Name
            _buildTwoColumnRow(
              left: _buildTextField(
                controller: _itemCodeController,
                readOnly: false,
                label: 'Item Code',
                hintText: 'Input code',
              ),
              right: _buildTextField(
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
            ),
            const SizedBox(height: 24),

            // Row 2: Item Group & Unit of Measure
            _buildTwoColumnRow(
              left: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Item Group*'),
                  const SizedBox(height: 8),
                  _buildItemGroupDropdown(),
                ],
              ),
              right: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Unit of Measure*'),
                  const SizedBox(height: 8),
                  _buildUomDropdown(),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Row 3: Standard Rate & Brand
            _buildTwoColumnRow(
              left: _buildTextField(
                controller: _standardRateController,
                label: 'Standard Rate*',
                hintText: '0.00',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
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
              right: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Brand'),
                  const SizedBox(height: 8),
                  _buildBrandDropdown(),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Row 4: Description & Barcode
            _buildTwoColumnRow(
              left: _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                hintText: 'Give a description',
                maxLines: 3,
              ),
              right: _buildTextField(
                controller: _barcodeController,
                label: 'Barcode',
                hintText: 'Input barcode',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
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
