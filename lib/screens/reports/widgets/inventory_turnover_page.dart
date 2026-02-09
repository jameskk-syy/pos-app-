import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/domain/models/reports/stock_movement_model.dart';
import 'package:pos/domain/requests/report_request.dart';
import 'package:pos/presentation/reports/bloc/reports_bloc.dart';
import 'package:pos/presentation/stores/bloc/store_bloc.dart';
import 'package:pos/presentation/categories/bloc/categories_bloc.dart';
import 'package:pos/presentation/categories/bloc/categories_event.dart';
import 'package:pos/presentation/categories/bloc/categories_state.dart';
import 'package:pos/screens/reports/widgets/common_widgets.dart';
import 'package:pos/utils/report_pdf_generator.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/core/services/storage_service.dart';
import 'dart:convert';

class InventoryTurnoverPage extends StatefulWidget {
  const InventoryTurnoverPage({super.key});

  @override
  State<InventoryTurnoverPage> createState() => _InventoryTurnoverPageState();
}

class _InventoryTurnoverPageState extends State<InventoryTurnoverPage> {
  String companyName = '';
  DateTimeRange? selectedDateRange;
  String selectedAnalysisType = 'Monthly';
  String? selectedWarehouse;
  String? selectedItemGroup;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedDateRange = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month + 1, 0),
    );
    _loadUserAndFetch();
  }

  void _fetchFilters(String company) {
    context.read<StoreBloc>().add(GetAllStores(company: company));
    context.read<CategoriesBloc>().add(LoadCategories());
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(3000),
      initialDateRange: selectedDateRange,
    );

    if (picked != null && picked != selectedDateRange) {
      setState(() {
        selectedDateRange = picked;
      });
      _loadUserAndFetch();
    }
  }

  Future<void> _loadUserAndFetch() async {
    final storage = getIt<StorageService>();
    final userString = await storage.getString('current_user');
    if (userString != null) {
      final user = jsonDecode(userString);
      companyName = user['message']['company']['name'] ?? '';
      _fetchFilters(companyName);
      _fetchData();
    }
  }

  void _fetchData() {
    if (mounted && selectedDateRange != null) {
      context.read<ReportsBloc>().add(
        FetchStockMovement(
          ReportRequest(
            company: companyName,
            startDate: selectedDateRange!.start.toIso8601String().split('T')[0],
            endDate: selectedDateRange!.end.toIso8601String().split('T')[0],
            analysisType: selectedAnalysisType.toLowerCase(),
            warehouse: selectedWarehouse,
            itemGroup: selectedItemGroup,
          ),
        ),
      );
    }
  }

  void _resetFilters() {
    final now = DateTime.now();
    setState(() {
      selectedDateRange = DateTimeRange(
        start: DateTime(now.year, now.month, 1),
        end: DateTime(now.year, now.month + 1, 0),
      );
      selectedAnalysisType = 'Monthly';
      selectedWarehouse = null;
      selectedItemGroup = null;
    });
    _fetchData();
  }

  Future<void> _exportPdf(List<InventoryTurnoverData> turnoverData) async {
    try {
      await ReportPdfGenerator().generateStockMovementPdf(
        turnoverData,
        [],
        companyName,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error generating PDF: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Inventory Turnover'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ReportsError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is StockMovementLoaded) {
            final turnoverData = state.turnoverResponse.data;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildModernFilters(turnoverData),
                  const SizedBox(height: 24),
                  ReportSectionCard(
                    title: 'Turnover Details',
                    child: _buildTurnoverList(turnoverData),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('Load Data'));
        },
      ),
    );
  }

  Widget _buildModernFilters(List<InventoryTurnoverData> turnoverData) {
    return CollapsibleReportSection(
      title: 'Filters & Actions',
      actions: [
        IconButton(
          onPressed: () => _exportPdf(turnoverData),
          icon: const Icon(Icons.picture_as_pdf_outlined),
          tooltip: 'Export PDF',
          color: const Color(0xFF64748B),
        ),
        TextButton.icon(
          onPressed: _resetFilters,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Reset'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      ],
      children: [
        ReportDateFilter(
          selectedRange: selectedDateRange,
          onTap: _pickDateRange,
        ),
        _buildWarehouseDropdown(),
        _buildItemGroupDropdown(),
        _buildAnalysisDropdown(),
      ],
    );
  }

  Widget _buildAnalysisDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedAnalysisType,
          items: [
            'Daily',
            'Weekly',
            'Monthly',
          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() => selectedAnalysisType = val);
              _fetchData();
            }
          },
        ),
      ),
    );
  }

  Widget _buildWarehouseDropdown() {
    return BlocBuilder<StoreBloc, StoreState>(
      builder: (context, state) {
        List<String> warehouses = [];
        if (state is StoreStateSuccess) {
          warehouses = state.storeGetResponse.message.data
              .map((e) => e.name)
              .toList();
        }
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              isExpanded: true,
              value: selectedWarehouse,
              hint: const Text("All Warehouses"),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text("All Warehouses"),
                ),
                ...warehouses.map(
                  (e) => DropdownMenuItem<String?>(value: e, child: Text(e)),
                ),
              ],
              onChanged: (val) {
                setState(() => selectedWarehouse = val);
                _fetchData();
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildItemGroupDropdown() {
    return BlocBuilder<CategoriesBloc, CategoriesState>(
      builder: (context, state) {
        List<String> groups = [];
        if (state is CategoriesLoaded) {
          groups = state.allCategories.map((e) => e.name).toList();
        }
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              isExpanded: true,
              value: selectedItemGroup,
              hint: const Text("All Item Groups"),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text("All Item Groups"),
                ),
                ...groups.map(
                  (e) => DropdownMenuItem<String?>(value: e, child: Text(e)),
                ),
              ],
              onChanged: (val) {
                setState(() => selectedItemGroup = val);
                _fetchData();
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildTurnoverList(List<InventoryTurnoverData> data) {
    if (data.isEmpty) return const Center(child: Text('No turnover data'));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width - 64,
        ),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
          columns: const [
            DataColumn(
              label: Text(
                'Item',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Avg Stock',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Turnover Rate',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Days',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: data.map((item) {
            return DataRow(
              cells: [
                DataCell(Text(item.itemName)),
                DataCell(Text(item.averageStock.toStringAsFixed(1))),
                DataCell(Text(item.turnoverRate.toStringAsFixed(2))),
                DataCell(Text(item.turnoverDays.toStringAsFixed(1))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
