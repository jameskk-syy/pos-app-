import 'package:flutter/material.dart';
import 'package:pos/domain/models/invoice_model.dart'; 
import 'package:pos/domain/responses/sales/crm_customer.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:pos/presentation/sales/bloc/sales_bloc.dart';
import 'package:pos/presentation/crm/bloc/crm_bloc.dart';
import 'package:pos/screens/sales/checkout_wizard_page.dart';

mixin CheckoutWizardLogic on State<CheckoutWizardPage> {
  int get currentStep;
  set currentStep(int value);
  String? get selectedCustomerId;
  set selectedCustomerId(String? value);
  String? get selectedCustomerName;
  set selectedCustomerName(String? value);
  Customer? get selectedCustomer;
  set selectedCustomer(Customer? value);
  List<Customer> get allCustomers;
  set allCustomers(List<Customer> value);
  List<Customer> get filteredCustomers;
  set filteredCustomers(List<Customer> value);
  bool get isLoadingCustomers;
  set isLoadingCustomers(bool value);
  List<Map<String, dynamic>> get paymentMethodsFromApi;
  set paymentMethodsFromApi(List<Map<String, dynamic>> value);
  bool get isLoadingPaymentMethods;
  set isLoadingPaymentMethods(bool value);
  bool get isCreatingInvoice;
  set isCreatingInvoice(bool value);
  CreateInvoiceResponse? get createdInvoice;
  set createdInvoice(CreateInvoiceResponse? value);
  
  SalesBloc get salesBloc;
  CrmBloc get crmBloc;
  CurrentUserResponse? get currentUserResponse;

  void setupListeners() {
    _listenToCustomers();
    _listenToPaymentMethods();
    _listenToInvoiceCreation();
  }

  void _listenToCustomers() {
    crmBloc.stream.listen((state) {
      if (!mounted) return;
      if (state is CrmStateSuccess) {
        final walkIn = _getWalkInCustomer();
        setState(() {
          allCustomers = [walkIn, ...state.customerResponse.message.data];
          filteredCustomers = allCustomers;
          isLoadingCustomers = false;
          if (selectedCustomerId == null) {
            selectedCustomerId = walkIn.name;
            selectedCustomerName = walkIn.customerName;
            selectedCustomer = walkIn;
          }
        });
      } else if (state is CrmStateFailure) {
        setState(() => isLoadingCustomers = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${state.error}'), backgroundColor: Colors.red));
      } else if (state is CrmStateLoading) {
        setState(() => isLoadingCustomers = true);
      }
    });
  }

  void _listenToInvoiceCreation() {
    salesBloc.stream.listen((state) {
      if (!mounted) return;
      if (state is InvoiceCreated) {
        setState(() {
          isCreatingInvoice = false;
          createdInvoice = state.invoiceResponse;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.green));
        WidgetsBinding.instance.addPostFrameCallback((_) => goToStep(3));
      } else if (state is InvoiceError) {
        setState(() => isCreatingInvoice = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
      }
    });
  }

  void _listenToPaymentMethods() {
    salesBloc.stream.listen((state) {
      if (!mounted) return;
      if (state is PaymentMethodsLoaded) {
        setState(() {
          paymentMethodsFromApi = state.paymentMethods.map((pm) => {
            'name': pm.name, 'type': pm.type, 'enabled': pm.enabled ? 1 : 0,
            'accounts': pm.accounts.map((acc) => {'company': acc.company, 'default_account': acc.defaultAccount}).toList(),
          }).toList();
          isLoadingPaymentMethods = false;
        });
      } else if (state is PaymentMethodsError) {
        setState(() => isLoadingPaymentMethods = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${state.message}'), backgroundColor: Colors.red));
      }
    });
  }

  Customer _getWalkInCustomer() => Customer(
    name: 'Walk-in Customer', customerName: 'Walk-in Customer', customerType: 'Individual',
    customerGroup: 'Walk-in', territory: null, taxId: null, mobileNo: null, emailId: null,
    disabled: 0, defaultCurrency: null, defaultPriceList: null, creditLimit: 0.0,
    outstandingAmount: 0.0, availableCredit: 0.0, creditUtilizationPercent: 0.0, isOverLimit: false,
  );

  void goToStep(int step) {
    setState(() => currentStep = step);
  }
}
