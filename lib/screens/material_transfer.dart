import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/domain/responses/get_current_user.dart';
import 'package:pos/presentation/stores/bloc/store_bloc.dart';
import 'package:pos/screens/create_material_transfer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MaterialTransferPage extends StatefulWidget {
  const MaterialTransferPage({super.key});

  @override
  State<MaterialTransferPage> createState() => _MaterialTransferPageState();
}

class _MaterialTransferPageState extends State<MaterialTransferPage> {
  CurrentUserResponse? currentUserResponse;
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
      currentUserResponse = savedUser;
    });

    context.read<StoreBloc>().add(GetAllStores(company: currentUserResponse!.message.company.name ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<StoreBloc>()..add(GetAllStores(company: currentUserResponse!.message.company.name)),
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FB),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Material Transfers",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "View all material transfer transactions",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: ElevatedButton.icon(
                onPressed: () {
                  _showCreateTransferForm(context);
                },
                icon: const Icon(Icons.add),
                label: const Text("Create Transfer"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976F3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _filtersCard(),
              const SizedBox(height: 16),
              _tableCard(),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateTransferForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => BlocProvider.value(
        value: BlocProvider.of<StoreBloc>(context),
        child: const CreateTransferForm(),
      ),
    );
  }
  Widget _filtersCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text("Filters", style: TextStyle(fontWeight: FontWeight.bold)),
              Spacer(),
              Icon(Icons.keyboard_arrow_down),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(child: _dropdown("Warehouse")),
              const SizedBox(width: 12),
              Expanded(child: _dropdown("Item Code")),
            ],
          ),
          const SizedBox(height: 12),

          Row(children: [Expanded(child: _dropdown("Status"))]),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.close, color: Colors.red),
                  label: const Text(
                    "Reset Filters",
                    style: TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976F3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Apply Filters"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tableCard() {
    return Container(
      decoration: _cardDecoration(),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
          columns: const [
            DataColumn(label: Text("Document Name")),
            DataColumn(label: Text("Posting Date")),
            DataColumn(label: Text("Source")),
            DataColumn(label: Text("Target")),
            DataColumn(label: Text("Actions")),
          ],
          rows: List.generate(
            7,
            (index) => DataRow(
              cells: const [
                DataCell(Text("")),
                DataCell(Text("")),
                DataCell(Text("")),
                DataCell(Text("")),
                DataCell(Icon(Icons.remove_red_eye)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dropdown(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: _inputDecoration(),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          hint: Text(hint),
          isExpanded: true,
          items: const [],
          onChanged: (_) {},
        ),
      ),
    );
  }

  BoxDecoration _inputDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFF1976F3), width: 0.6),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFF1976F3), width: 0.4),
    );
  }
}
