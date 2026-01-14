import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/domain/models/cart_item.dart';
import 'package:pos/domain/models/invoice_model.dart';
import 'package:pos/domain/requests/get_customer_request.dart';
import 'package:pos/domain/responses/crm_customer.dart';
import 'package:pos/domain/responses/get_current_user.dart';
import 'package:pos/presentation/sales/bloc/sales_bloc.dart';
import 'package:pos/presentation/crm/bloc/crm_bloc.dart';
import 'package:pos/utils/cart_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class CheckoutWizardPage extends StatefulWidget {
  final double total;

  const CheckoutWizardPage({super.key, required this.total});

  @override
  State<CheckoutWizardPage> createState() => _CheckoutWizardPageState();
}

class _CheckoutWizardPageState extends State<CheckoutWizardPage> {
  int _currentStep = 0;
  String selectedPayment = '';
  String? selectedCustomerId;
  String? selectedCustomerName;
  bool _receiptPrinted = false;
  CurrentUserResponse? currentUserResponse;
  late SalesBloc salesBloc;
  late CrmBloc crmBloc;
  final TextEditingController _notesController = TextEditingController();
  CreateInvoiceResponse? createdInvoice;
  bool isCreatingInvoice = false;

  final TextEditingController _customerSearchController =
      TextEditingController();
  List<Customer> allCustomers = [];
  List<Customer> filteredCustomers = [];
  bool isLoadingCustomers = false;
  bool showCustomerResults = false;

  List<Map<String, dynamic>> paymentMethodsFromApi = [];
  bool isLoadingPaymentMethods = false;
  late CustomerRequest _searchRequest;

  @override
  void initState() {
    super.initState();
    salesBloc = getIt<SalesBloc>();
    crmBloc = getIt<CrmBloc>();
    allCustomers = [];
    filteredCustomers = [];
    _loadCurrentUser().then((_) {
      if (mounted && currentUserResponse != null) {
        _listenToPaymentMethods();
        _listenToCustomers();
        _listenToInvoiceCreation();
        _loadCustomers();
      }
    });
  }

  void _listenToCustomers() {
    crmBloc.stream.listen((state) {
      if (state is CrmStateSuccess) {
        final walkInCustomer = Customer(
          name: 'Walk-in Customer',
          customerName: 'Walk-in Customer',
          customerType: 'Individual',
          customerGroup: 'Walk-in',
          territory: null,
          taxId: null,
          mobileNo: null,
          emailId: null,
          disabled: 0,
          defaultCurrency: null,
          defaultPriceList: null,
          creditLimit: 0.0,
          outstandingAmount: 0.0,
          availableCredit: 0.0,
          creditUtilizationPercent: 0.0,
          isOverLimit: false,
        );

        setState(() {
          allCustomers = [
            walkInCustomer,
            ...state.customerResponse.message.data,
          ];
          filteredCustomers = allCustomers;
          isLoadingCustomers = false;
          if (selectedCustomerId == null) {
            selectedCustomerId = walkInCustomer.name;
            selectedCustomerName = walkInCustomer.customerName;
          }
        });
      } else if (state is CrmStateFailure) {
        setState(() {
          isLoadingCustomers = false;

          if (allCustomers.isEmpty) {
            final walkInCustomer = Customer(
              name: 'Walk-in Customer',
              customerName: 'Walk-in Customer',
              customerType: 'Individual',
              customerGroup: 'Walk-in',
              territory: null,
              taxId: null,
              mobileNo: null,
              emailId: null,
              disabled: 0,
              defaultCurrency: null,
              defaultPriceList: null,
              creditLimit: 0.0,
              outstandingAmount: 0.0,
              availableCredit: 0.0,
              creditUtilizationPercent: 0.0,
              isOverLimit: false,
            );

            allCustomers = [walkInCustomer];
            filteredCustomers = [walkInCustomer];
            selectedCustomerId = walkInCustomer.name;
            selectedCustomerName = walkInCustomer.customerName;
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading customers: ${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else if (state is CrmStateLoading) {
        setState(() {
          isLoadingCustomers = true;
        });
      }
    });
  }

  void _listenToInvoiceCreation() {
    salesBloc.stream.listen((state) {
      if (state is InvoiceCreated) {
        setState(() {
          isCreatingInvoice = false;
          createdInvoice = state.invoiceResponse;
        });

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _goToStep(3);
        });
      } else if (state is InvoiceError) {
        setState(() {
          isCreatingInvoice = false;
        });
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  void _listenToPaymentMethods() {
    salesBloc.stream.listen((state) {
      if (state is PaymentMethodsLoaded) {
        setState(() {
          paymentMethodsFromApi = state.paymentMethods
              .map(
                (pm) => {
                  'name': pm.name,
                  'type': pm.type,
                  'enabled': pm.enabled ? 1 : 0,
                  'accounts': (pm.accounts)
                      .map(
                        (acc) => {
                          'company': acc.company,
                          'default_account': acc.defaultAccount,
                        },
                      )
                      .toList(),
                },
              )
              .toList();
          isLoadingPaymentMethods = false;
        });
      } else if (state is PaymentMethodsError) {
        setState(() {
          isLoadingPaymentMethods = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading payment methods: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });
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
      currentUserResponse = savedUser;
    });

    salesBloc.add(
      GetPaymentMethod(
        company: savedUser.message.company.name,
        onlyEnabled: false,
      ),
    );
  }

  void _loadCustomers() {
    setState(() {
      isLoadingCustomers = true;
    });
    _searchRequest = CustomerRequest(
      searchTerm: '',
      customerGroup: '',
      territory: '',
      customerType: '',
      disabled: false,
      filterByCompanyTransactions: false,
      company: currentUserResponse!.message.company.name,
      limit: 20,
      offset: 0,
    );
    crmBloc.add(GetAllCustomers(custmoerRequest: _searchRequest));
  }

  void _searchCustomers(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredCustomers = allCustomers;
      } else {
        filteredCustomers = allCustomers.where((customer) {
          final name = customer.name.toLowerCase();
          final email = customer.emailId?.toLowerCase() ?? '';
          final searchQuery = query.toLowerCase();
          return name.contains(searchQuery) || email.contains(searchQuery);
        }).toList();
      }
    });
  }

  void _selectCustomer(Customer customer) {
    setState(() {
      selectedCustomerId = customer.name;
      selectedCustomerName = customer.name;
      showCustomerResults = false;
      _customerSearchController.clear();
    });
  }

  void _clearCustomerSelection() {
    setState(() {
      selectedCustomerId = null;
      selectedCustomerName = null;
    });
  }

  Future<void> _createInvoice() async {
    try {
      setState(() {
        isCreatingInvoice = true;
      });

      final cartItems = await CartManager.getCart();
      if (cartItems.isEmpty) {
        throw Exception('Cart is empty');
      }

      debugPrint(cartItems.first.product.id);

      final invoiceItems = cartItems.map((item) {
        return InvoiceItem(
          itemCode: item.product.id,
          qty: item.quantity.toInt(),
          rate: item.product.price,
          uom: 'Nos',
          warehouse:
              currentUserResponse?.message.defaultWarehouse ??
              'Default Warehouse',
        );
      }).toList();

      final request = InvoiceRequest(
        customer: selectedCustomerId ?? 'Walk-in Customer',
        company: currentUserResponse?.message.company.name ?? 'Default Company',
        warehouse:
            currentUserResponse?.message.defaultWarehouse ??
            'Default Warehouse',
        updateStock: true,
        items: invoiceItems,
        postingDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        posProfile: currentUserResponse!.message.posProfile.name,
        payments: [
          InvoicePayment(
            modeOfPayment: selectedPayment,
            amount: widget.total,
            baseAmount: widget.total,
          ),
        ],
        doNotSubmit: false,
        isPos: 1,
        invoiceType: 'POS Invoice',
      );

      salesBloc.add(CreateInvoice(request: request));
    } catch (e) {
      setState(() {
        isCreatingInvoice = false;
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating invoice: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  List<Step> get _steps => [
    Step(
      title: const Text('Review Order', style: TextStyle(fontSize: 14)),
      content: _buildReviewStep(),
      isActive: _currentStep == 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
    ),
    Step(
      title: const Text('Customer', style: TextStyle(fontSize: 14)),
      content: _buildCustomerStep(),
      isActive: _currentStep == 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
    ),
    Step(
      title: const Text('Payment', style: TextStyle(fontSize: 14)),
      content: _buildPaymentStep(),
      isActive: _currentStep == 2,
      state: StepState.indexed,
    ),
    Step(
      title: const Text('Complete', style: TextStyle(fontSize: 14)),
      content: _buildCompleteStep(),
      isActive: _currentStep == 3,
      state: StepState.indexed,
    ),
  ];

  @override
  void dispose() {
    _notesController.dispose();
    _customerSearchController.dispose();
    super.dispose();
  }

  Widget _buildReviewStep() {
    return FutureBuilder<List<CartItem>>(
      future: CartManager.getCart(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final cartItems = snapshot.data ?? [];

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Order Summary',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                color: Colors.grey[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey[200]!),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      for (var item in cartItems)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Center(
                                  child: Text(
                                    item.product.image,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${item.quantity} × ${item.product.price.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                item.totalPrice.toStringAsFixed(2),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Subtotal',
                            style: TextStyle(fontSize: 14),
                          ),
                          Text(
                            widget.total.toStringAsFixed(2),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const Divider(height: 1),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            widget.total.toStringAsFixed(2),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCustomerStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Customer',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose an existing customer or add a new one',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          if (selectedCustomerId != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[100]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, color: Colors.green, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedCustomerName ?? 'Unknown Customer',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'ID: $selectedCustomerId',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: _clearCustomerSelection,
                    tooltip: 'Change customer',
                  ),
                ],
              ),
            ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: _customerSearchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name, email, or phone...',
                      border: InputBorder.none,
                      suffixIcon: isLoadingCustomers
                          ? const Padding(
                              padding: EdgeInsets.all(10),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.search),
                              onPressed: () {
                                _searchCustomers(
                                  _customerSearchController.text,
                                );
                                setState(() {
                                  showCustomerResults = true;
                                });
                              },
                            ),
                    ),
                    onChanged: (value) {
                      _searchCustomers(value);
                    },
                    onTap: () {
                      setState(() {
                        showCustomerResults = true;
                      });
                    },
                    onSubmitted: (value) {
                      _searchCustomers(value);
                      setState(() {
                        showCustomerResults = true;
                      });
                    },
                  ),
                ),
                if (showCustomerResults)
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredCustomers.length,
                      itemBuilder: (context, index) {
                        final customer = filteredCustomers[index];
                        return ListTile(
                          leading: const Icon(Icons.person_outline),
                          title: Text(customer.name),
                          subtitle: customer.emailId != null
                              ? Text(customer.emailId!)
                              : null,
                          trailing: selectedCustomerId == customer.name
                              ? const Icon(Icons.check, color: Colors.green)
                              : null,
                          onTap: () => _selectCustomer(customer),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (selectedCustomerId != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Customer Information',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'This customer has no previous orders.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selectedCustomerId != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, color: Colors.blue, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Customer',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          selectedCustomerName ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const Text(
            'Select Payment Method',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose your preferred payment method',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          if (isLoadingPaymentMethods)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text(
                      'Loading payment methods...',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            )
          else if (paymentMethodsFromApi.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'No payment methods available',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: DropdownButton<String>(
                value: selectedPayment.isEmpty ? null : selectedPayment,
                hint: const Text(
                  'Select a payment method',
                  style: TextStyle(fontSize: 14),
                ),
                isExpanded: true,
                underline: const SizedBox(),
                icon: const Icon(Icons.arrow_drop_down, size: 24),
                borderRadius: BorderRadius.circular(8),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedPayment = newValue ?? '';
                  });
                },
                items: paymentMethodsFromApi
                    .where((method) => method['enabled'] == 1)
                    .map<DropdownMenuItem<String>>((method) {
                      return DropdownMenuItem<String>(
                        value: method['name'] as String,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              method['name'] as String,
                              style: const TextStyle(fontSize: 14),
                            ),
                            if (method['type'] != null)
                              Text(
                                'Type: ${method['type']}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      );
                    })
                    .toList(),
              ),
            ),
          const SizedBox(height: 16),
          if (selectedPayment.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selected Payment:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Builder(
                    builder: (context) {
                      Map<String, dynamic>? selectedMethod;
                      try {
                        selectedMethod = paymentMethodsFromApi.firstWhere(
                          (method) => method['name'] == selectedPayment,
                        );
                      } catch (e) {
                        selectedMethod = null;
                      }

                      if (selectedMethod == null || selectedMethod.isEmpty) {
                        return const Text(
                          'No details available',
                          style: TextStyle(fontSize: 12),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Method: ',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                selectedMethod['name']?.toString() ?? 'N/A',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                'Type: ',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                selectedMethod['type']?.toString() ?? 'N/A',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                          if (selectedMethod['accounts'] != null &&
                              (selectedMethod['accounts'] as List).isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Text(
                                  'Accounts:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                ...(selectedMethod['accounts'] as List)
                                    .where(
                                      (account) =>
                                          account != null &&
                                          (account['company']
                                                      ?.toString()
                                                      .isNotEmpty ==
                                                  true ||
                                              account['default_account']
                                                      ?.toString()
                                                      .isNotEmpty ==
                                                  true),
                                    )
                                    .map<Widget>((account) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          top: 4,
                                          left: 8,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (account['company']
                                                    ?.toString()
                                                    .isNotEmpty ==
                                                true)
                                              Text(
                                                '• ${account['company']}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            if (account['default_account']
                                                    ?.toString()
                                                    .isNotEmpty ==
                                                true)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 8,
                                                ),
                                                child: Text(
                                                  account['default_account']
                                                      .toString(),
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      );
                                    }),
                              ],
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                const Text(
                  'Payment Summary',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal:', style: TextStyle(fontSize: 13)),
                    Text(
                      widget.total.toStringAsFixed(2),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      widget.total.toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteStep() {
    final totalWithTax = widget.total;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: (createdInvoice?.success == true
                    ? Colors.green.shade50
                    : Colors.red.shade50),
                shape: BoxShape.circle,
                border: Border.all(
                  color: createdInvoice?.success == true
                      ? Colors.green.shade200
                      : Colors.red.shade200,
                  width: 3,
                ),
              ),
              child: Center(
                child: Icon(
                  createdInvoice?.success == true
                      ? Icons.check_circle
                      : Icons.error_outline,
                  color: createdInvoice?.success == true
                      ? Colors.green
                      : Colors.red,
                  size: 48,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              createdInvoice?.success == true
                  ? 'Order Completed Successfully!'
                  : 'Order Processing Failed',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: createdInvoice?.success == true
                    ? Colors.green.shade800
                    : Colors.red.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              createdInvoice?.success == true
                  ? 'Thank you for your purchase'
                  : 'Please try again or contact support',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (createdInvoice?.success == true && createdInvoice?.data != null)
              _buildInvoiceDetailsCard(),
            const SizedBox(height: 16),
            if (selectedCustomerId != null) _buildCustomerInfoCard(),
            const SizedBox(height: 16),
            if (selectedPayment.isNotEmpty) _buildPaymentInfoCard(),
            const SizedBox(height: 16),
            _buildTotalAmountDisplay(totalWithTax),
            const SizedBox(height: 24),
            _buildReceiptActionsCard(),
            const SizedBox(height: 20),
            _buildNextStepsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceDetailsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long, color: Colors.blue.shade700, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Invoice Details',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Invoice Number',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              createdInvoice!.data!.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 40,
                        width: 1,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Grand Total',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              createdInvoice!.data!.grandTotal.toStringAsFixed(
                                2,
                              ),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified, color: Colors.green.shade700, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Invoice Created Successfully',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.person,
                  color: Colors.blue.shade700,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Customer',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selectedCustomerName ?? 'Unknown Customer',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'ID: $selectedCustomerId',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfoCard() {
    Map<String, dynamic>? selectedMethod;
    try {
      selectedMethod = paymentMethodsFromApi.firstWhere(
        (method) => method['name'] == selectedPayment,
      );
    } catch (e) {
      selectedMethod = null;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.payment,
                      color: Colors.green.shade700,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Payment Method',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedPayment,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (selectedMethod != null &&
                          selectedMethod['type'] != null)
                        Text(
                          'Type: ${selectedMethod['type']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (selectedMethod != null &&
                selectedMethod['accounts'] != null &&
                (selectedMethod['accounts'] as List).isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 24),
                  const Text(
                    'Linked Accounts:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...(selectedMethod['accounts'] as List)
                      .where(
                        (account) =>
                            account != null &&
                            (account['company']?.toString().isNotEmpty ==
                                    true ||
                                account['default_account']
                                        ?.toString()
                                        .isNotEmpty ==
                                    true),
                      )
                      .map<Widget>((account) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.account_balance,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (account['company']
                                            ?.toString()
                                            .isNotEmpty ==
                                        true)
                                      Text(
                                        account['company'].toString(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                    if (account['default_account']
                                            ?.toString()
                                            .isNotEmpty ==
                                        true)
                                      Text(
                                        account['default_account'].toString(),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalAmountDisplay(double totalWithTax) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade50, Colors.blue.shade100],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Total Amount Paid',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            '\${totalWithTax.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptActionsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Text(
                  'RECEIPT',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'Order #${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Date: ${DateFormat('MMM dd, yyyy - HH:mm').format(DateTime.now())}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _receiptPrinted = true;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Receipt sent to printer',
                            style: TextStyle(fontSize: 13),
                          ),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.print,
                      color: _receiptPrinted ? Colors.white : Colors.blue,
                    ),
                    label: Text(
                      _receiptPrinted ? 'Printed' : 'Print Receipt',
                      style: TextStyle(
                        color: _receiptPrinted ? Colors.white : Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _receiptPrinted
                          ? Colors.green
                          : Colors.white,
                      foregroundColor: _receiptPrinted
                          ? Colors.white
                          : Colors.blue,
                      side: BorderSide(
                        color: _receiptPrinted ? Colors.green : Colors.blue,
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Receipt sent via email',
                            style: TextStyle(fontSize: 13),
                          ),
                          backgroundColor: Colors.orange,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.email_outlined),
                    label: const Text(
                      'Email Receipt',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextStepsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What\'s Next?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            _buildNextStepItem(
              icon: Icons.local_shipping,
              iconColor: Colors.blue.shade700,
              title: 'Order Processing',
              subtitle: 'Your order is being prepared for shipping',
              time: '2-3 business days',
            ),
            const SizedBox(height: 12),
            _buildNextStepItem(
              icon: Icons.track_changes,
              iconColor: Colors.green.shade700,
              title: 'Track Your Order',
              subtitle: 'Use the tracking ID sent to your email',
              time: 'Available within 24 hours',
            ),
            const SizedBox(height: 12),
            _buildNextStepItem(
              icon: Icons.support_agent,
              iconColor: Colors.orange.shade700,
              title: 'Need Help?',
              subtitle: 'Our customer support is available 24/7',
              time: 'support@yourstore.com',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextStepItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withAlpha(10),
              shape: BoxShape.circle,
            ),
            child: Center(child: Icon(icon, color: iconColor, size: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _goToStep(int step) {
    setState(() {
      _currentStep = step;
    });
  }

  Future<void> _completeOrder() async {
    if (_currentStep == 1 && selectedCustomerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a customer',
            style: TextStyle(fontSize: 13),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_currentStep == 2 && selectedPayment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a payment method',
            style: TextStyle(fontSize: 13),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_currentStep == 2) {
      await _createInvoice();
      return;
    }

    if (_currentStep == 3 && createdInvoice?.success == true) {
      await CartManager.clearCart();
    }

    if (_currentStep < _steps.length - 1) {
      _goToStep(_currentStep + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 22),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() {
                _currentStep--;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: Colors.grey[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStepIndicator(0, 'Review'),
                Expanded(
                  child: Divider(
                    height: 2,
                    color: _currentStep > 0 ? Colors.green : Colors.grey[300],
                  ),
                ),
                _buildStepIndicator(1, 'Customer'),
                Expanded(
                  child: Divider(
                    height: 2,
                    color: _currentStep > 1 ? Colors.green : Colors.grey[300],
                  ),
                ),
                _buildStepIndicator(2, 'Payment'),
                Expanded(
                  child: Divider(
                    height: 2,
                    color: _currentStep > 2 ? Colors.green : Colors.grey[300],
                  ),
                ),
                _buildStepIndicator(3, 'Complete'),
              ],
            ),
          ),
          Expanded(
            child: Stepper(
              currentStep: _currentStep,
              onStepContinue: _completeOrder,
              onStepCancel: () {
                if (_currentStep > 0) {
                  _goToStep(_currentStep - 1);
                } else {
                  Navigator.pop(context);
                }
              },
              onStepTapped: (step) {
                if (step <= _currentStep) {
                  _goToStep(step);
                }
              },
              steps: _steps,
              controlsBuilder: (context, details) {
                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentStep > 0)
                        SizedBox(
                          width: 100,
                          child: ElevatedButton(
                            onPressed: details.onStepCancel,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[200],
                              foregroundColor: Colors.grey[800],
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              textStyle: const TextStyle(fontSize: 13),
                            ),
                            child: const Text('Back'),
                          ),
                        )
                      else
                        const SizedBox(width: 100),
                      SizedBox(
                        width: 100,
                        child: ElevatedButton(
                          onPressed: isCreatingInvoice
                              ? null
                              : details.onStepContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isCreatingInvoice
                                ? Colors.grey
                                : Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            textStyle: const TextStyle(fontSize: 13),
                          ),
                          child: isCreatingInvoice
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _currentStep == _steps.length - 1
                                      ? 'Finish'
                                      : 'Continue',
                                ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (_currentStep < 3)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(5),
                    blurRadius: 8,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    if (selectedCustomerId != null && _currentStep >= 1)
                      Container(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person,
                              size: 16,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                selectedCustomerName ?? 'Unknown',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _currentStep == 0
                              ? 'Order Total:'
                              : _currentStep == 1
                              ? 'Customer Total:'
                              : 'Amount to Pay:',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          widget.total.toStringAsFixed(2),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    if (isCreatingInvoice)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Creating invoice...',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int stepNumber, String title) {
    final isActive = _currentStep == stepNumber;
    final isCompleted = _currentStep > stepNumber;

    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isCompleted
                ? Colors.green
                : (isActive ? Colors.blue : Colors.grey[300]),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text(
                    '${stepNumber + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isActive ? Colors.white : Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? Colors.blue : Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
