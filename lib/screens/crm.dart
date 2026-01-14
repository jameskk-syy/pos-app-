import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/requests/get_customer_request.dart';
import 'package:pos/domain/responses/crm_customer.dart';
import 'package:pos/domain/responses/get_current_user.dart';
import 'package:pos/presentation/crm/bloc/crm_bloc.dart';
import 'package:pos/widgets/customer_form_view.dart';
import 'package:pos/widgets/customer_list_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CRMHomePage extends StatefulWidget {
  const CRMHomePage({super.key});

  @override
  State<CRMHomePage> createState() => _CRMHomePageState();
}

class _CRMHomePageState extends State<CRMHomePage> {
  String _currentView = 'list';
  Customer? _editingCustomer;
  late CustomerRequest _searchRequest;
  CurrentUserResponse? currentUserResponse;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentUser();
    });
  }

  void _switchView(String view, {Customer? customer}) {
    if (view == 'list') {
      _editingCustomer = null;
      context.read<CrmBloc>().add(
        GetAllCustomers(custmoerRequest: _searchRequest),
      );
    } else {
      _editingCustomer = customer;
    }
    setState(() {
      _currentView = view;
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
    context.read<CrmBloc>().add(
      GetAllCustomers(custmoerRequest: _searchRequest),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<CrmBloc, CrmState>(
        listener: (context, state) {
          if ((state is CrmStateSuccessful || state is UpdateCustomerSuccess) &&
              _currentView == 'customer') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _editingCustomer == null
                      ? 'Customer created successfully!'
                      : 'Customer updated successfully!',
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );

            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted && _currentView == 'customer') {
                _switchView('list');
              }
            });
          }

          if (state is CrmStateFailure && _currentView == 'customer') {
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
          return _currentView == 'list'
              ? CustomerListView(
                  onAddCustomer: () => _switchView('customer'),
                  onEditCustomer: (customer) =>
                      _switchView('customer', customer: customer),
                )
              : CustomerFormView(
                  customer: _editingCustomer,
                  onCancel: () => _switchView('list'),
                  onSave: (request) {
                    if (_editingCustomer == null) {
                      context.read<CrmBloc>().add(
                        CreateCustomer(completeCustomerequest: request),
                      );
                    }
                  },
                  onUpdate: (request, customerId) {
                    context.read<CrmBloc>().add(
                      UpdateCustomer(
                        updateRequest: request,
                        customerId: customerId,
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}
