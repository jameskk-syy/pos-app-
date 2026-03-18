import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart' as excel hide Border;
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/domain/repository/products_repo.dart';
import 'package:pos/domain/responses/bulk_upload.dart';
import 'package:pos/domain/responses/sales/store_response.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pos/presentation/stores/bloc/store_bloc.dart';

Future<void> showBulkUploadDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => BulkUploadDialog(productsRepo: getIt<ProductsRepo>()),
  );
}

class BulkUploadDialog extends StatefulWidget {
  final ProductsRepo productsRepo;

  const BulkUploadDialog({super.key, required this.productsRepo});

  @override
  State<BulkUploadDialog> createState() => _BulkUploadDialogState();
}

enum _DialogStep { idle, uploading, result }

class _BulkUploadDialogState extends State<BulkUploadDialog> {
  _DialogStep _step = _DialogStep.idle;
  PlatformFile? _pickedFile;
  String? _errorMessage;
  ProcessResponse? _uploadResult;

  // User context
  String _company = '';
  String _industry = '';

  // Warehouse state
  List<Warehouse> _warehouses = [];
  Warehouse? _selectedWarehouse;
  bool _warehousesLoading = true;
  String? _warehouseError;

  @override
  void initState() {
    super.initState();
    _loadUserAndWarehouses();
  }

  Future<void> _loadUserAndWarehouses() async {
    final storage = getIt<StorageService>();
    final userString = await storage.getString('current_user');
    if (userString == null) return;

    final user = CurrentUserResponse.fromJson(jsonDecode(userString));
    if (!mounted) return;

    setState(() {
      _company = user.message.company.name;
      _industry = user.message.posIndustry.industryCode;
    });

    // Trigger warehouse fetch via StoreBloc
    context.read<StoreBloc>().add(GetAllStores(company: _company));
  }

  Future<void> _downloadTemplate() async {
    try {
      final excelFile = excel.Excel.createExcel();
      final sheet = excelFile['Products'];
      excelFile.delete('Sheet1');
      final headerStyle = excel.CellStyle(
        backgroundColorHex: excel.ExcelColor.fromHexString('#1E3A5F'),
        fontColorHex: excel.ExcelColor.fromHexString('#FFFFFF'),
        bold: true,
        horizontalAlign: excel.HorizontalAlign.Center,
      );
      final headers = [
        'item_code',
        'item_name',
        'item_price',
        'buying_price',
        'item_group',
        'uom',
        'qty',
      ];

      for (var i = 0; i < headers.length; i++) {
        final cell = sheet.cell(
          excel.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        );
        cell.value = excel.TextCellValue(headers[i]);
        cell.cellStyle = headerStyle;
        sheet.setColumnWidth(i, 20);
      }
      final exampleStyle = excel.CellStyle(
        fontColorHex: excel.ExcelColor.fromHexString('#555555'),
        italic: true,
      );
      final exampleValues = <excel.CellValue>[
        excel.TextCellValue('ITEM001'),
        excel.TextCellValue('Sample Item'),
        excel.DoubleCellValue(9.99),
        excel.DoubleCellValue(5.50),
        excel.TextCellValue('All Item Groups'),
        excel.TextCellValue('Nos'),
        excel.IntCellValue(10),
      ];
      for (var i = 0; i < exampleValues.length; i++) {
        final cell = sheet.cell(
          excel.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 1),
        );
        cell.value = exampleValues[i];
        cell.cellStyle = exampleStyle;
      }

      // Save to Downloads directory (with fallback to temp)
      Directory? dir;
      try {
        dir = await getDownloadsDirectory();
      } catch (_) {}
      dir ??= await getTemporaryDirectory();

      final filePath = '${dir.path}/bulk_upload_template.xlsx';
      final bytes = excelFile.encode();
      if (bytes == null) throw Exception('Failed to encode Excel file');

      final file = File(filePath);
      await file.writeAsBytes(bytes);

      if (!mounted) return;

      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Product Bulk Upload Template',
        text: 'Excel template for bulk product upload.',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Template saved to: ${dir.path}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate template: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ── File pick ──────────────────────────────────────────────────────────────

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _pickedFile = result.files.first;
        _errorMessage = null;
      });
    }
  }

  // ── Upload ─────────────────────────────────────────────────────────────────

  Future<void> _upload() async {
    if (_pickedFile == null) {
      setState(() => _errorMessage = 'Please select an Excel file first.');
      return;
    }
    if (_selectedWarehouse == null) {
      setState(() => _errorMessage = 'Please select a warehouse first.');
      return;
    }

    final path = _pickedFile!.path;
    if (path == null) {
      setState(() => _errorMessage = 'Could not read file path.');
      return;
    }

    setState(() {
      _step = _DialogStep.uploading;
      _errorMessage = null;
    });

    try {
      final response = await widget.productsRepo.bulkUploadProducts(
        filePath: path,
        warehouse: _selectedWarehouse!.name,
        company: _company,
        industry: _industry,
      );
      if (!mounted) return;
      setState(() {
        _uploadResult = response;
        _step = _DialogStep.result;
      });
    } on DioException catch (e) {
      setState(() {
        _errorMessage =
            e.response?.data?['message']?.toString() ??
            e.message ??
            'Upload failed.';
        _step = _DialogStep.idle;
      });
    } catch (e) {
      String msg = e.toString().replaceFirst('Exception: ', '');
      setState(() {
        _errorMessage = msg;
        _step = _DialogStep.idle;
      });
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth < 600
        ? screenWidth * 0.95
        : screenWidth < 1024
        ? screenWidth * 0.7
        : 640.0;

    return BlocListener<StoreBloc, StoreState>(
      listener: (context, state) {
        if (state is StoreStateSuccess) {
          final warehouses = state.storeGetResponse.message.data;
          Warehouse? defaultWh;
          if (warehouses.isNotEmpty) {
            try {
              defaultWh = warehouses.firstWhere((w) => w.isDefault);
            } catch (_) {
              defaultWh = warehouses.first;
            }
          }
          setState(() {
            _warehouses = warehouses;
            _selectedWarehouse ??= defaultWh;
            _warehousesLoading = false;
            _warehouseError = null;
          });
        } else if (state is StoreStateFailure) {
          setState(() {
            _warehousesLoading = false;
            _warehouseError = state.error;
          });
        } else if (state is StoreStateLoading) {
          setState(() => _warehousesLoading = true);
        }
      },
      child: Dialog(
        shape: const RoundedRectangleBorder(),
        insetPadding: EdgeInsets.symmetric(
          horizontal: screenWidth < 600 ? 12 : 32,
          vertical: 24,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: dialogWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              Flexible(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: Colors.blue,
      child: Row(
        children: [
          const Icon(Icons.upload_file, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bulk Upload Products',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Upload an Excel file to add multiple products at once',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: _step == _DialogStep.uploading
          ? _buildUploadingState()
          : _step == _DialogStep.result && _uploadResult != null
          ? _buildResultState(_uploadResult!)
          : _buildIdleState(),
    );
  }

  Widget _buildIdleState() {
    return SingleChildScrollView(
      key: const ValueKey('idle'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Step 1: Download template
          _buildStepCard(
            stepNumber: '1',
            stepColor: Colors.blue,
            title: 'Download Template',
            subtitle:
                'Get the Excel template with the required column headers.',
            child: ElevatedButton.icon(
              onPressed: _downloadTemplate,
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Download Template'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: const RoundedRectangleBorder(),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Step 2: Select Warehouse
          _buildStepCard(
            stepNumber: '2',
            stepColor: Colors.blue,
            title: 'Select Warehouse',
            subtitle: 'Choose the warehouse where products will be stocked.',
            child: _buildWarehouseSelector(),
          ),

          const SizedBox(height: 16),

          // Step 3: Select file
          _buildStepCard(
            stepNumber: '3',
            stepColor: Colors.orange,
            title: 'Select Your Excel File',
            subtitle: 'Fill in the template and upload the completed file.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: _pickFile,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _pickedFile != null
                          ? Colors.green.shade50
                          : Colors.grey.shade50,
                      border: Border.all(
                        color: _pickedFile != null
                            ? Colors.green.shade300
                            : Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _pickedFile != null
                              ? Icons.description
                              : Icons.upload_file_outlined,
                          color: _pickedFile != null
                              ? Colors.green
                              : Colors.grey.shade500,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _pickedFile != null
                                    ? _pickedFile!.name
                                    : 'Tap to select file',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: _pickedFile != null
                                      ? Colors.green.shade700
                                      : Colors.grey.shade700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (_pickedFile != null)
                                Text(
                                  '${(_pickedFile!.size / 1024).toStringAsFixed(1)} KB',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                )
                              else
                                Text(
                                  'Supported formats: .xlsx, .xls',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (_pickedFile != null)
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.grey,
                            ),
                            onPressed: () => setState(() {
                              _pickedFile = null;
                            }),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 28,
                              minHeight: 28,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.folder_open, size: 18),
                  label: Text(
                    _pickedFile != null ? 'Change File' : 'Browse Files',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange.shade700,
                    side: BorderSide(color: Colors.orange.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: const RoundedRectangleBorder(),
                  ),
                ),
              ],
            ),
          ),

          // Error message
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.red.shade50,
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red.shade400,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: const RoundedRectangleBorder(),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: (_pickedFile != null && _selectedWarehouse != null)
                      ? _upload
                      : null,
                  icon: const Icon(Icons.cloud_upload, size: 18),
                  label: const Text('Upload Products'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade200,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: const RoundedRectangleBorder(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWarehouseSelector() {
    if (_warehousesLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10),
            Text('Loading warehouses...', style: TextStyle(fontSize: 13)),
          ],
        ),
      );
    }

    if (_warehouseError != null && _warehouses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(10),
        color: Colors.red.shade50,
        child: Text(
          'Could not load warehouses: $_warehouseError',
          style: TextStyle(color: Colors.red.shade700, fontSize: 12),
        ),
      );
    }

    if (_warehouses.isEmpty) {
      return Text(
        'No warehouses available.',
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      );
    }

    return DropdownButtonFormField<Warehouse>(
      initialValue: _selectedWarehouse,
      isExpanded: true,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: Colors.blue, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(
          Icons.warehouse_outlined,
          size: 18,
          color: Colors.grey.shade600,
        ),
      ),
      hint: Text(
        'Select warehouse',
        style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
      ),
      items: _warehouses.map((w) {
        return DropdownMenuItem<Warehouse>(
          value: w,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  w.warehouseName,
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (w.isDefault) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  color: Colors.green.shade100,
                  child: Text(
                    'Default',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
      onChanged: (w) => setState(() => _selectedWarehouse = w),
    );
  }

  Widget _buildStepCard({
    required String stepNumber,
    required Color stepColor,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: stepColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  stepNumber,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      subtitle,
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
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildUploadingState() {
    return Padding(
      key: const ValueKey('uploading'),
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 56,
            height: 56,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Uploading Products...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait while your products are being processed.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildResultState(ProcessResponse result) {
    final isSuccess = result.isSuccess;

    return SingleChildScrollView(
      key: const ValueKey('result'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status banner
          Container(
            padding: const EdgeInsets.all(16),
            color: isSuccess ? Colors.green.shade50 : Colors.red.shade50,
            child: Row(
              children: [
                Icon(
                  isSuccess ? Icons.check_circle : Icons.error_outline,
                  color: isSuccess ? Colors.green : Colors.red,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isSuccess
                            ? 'Upload Successful!'
                            : 'Upload Completed with Issues',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: isSuccess
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${result.totalProcessed} items processed',
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
          ),

          const SizedBox(height: 16),

          // Summary stats grid
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.4,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildStatCard(
                label: 'Created',
                value: result.created,
                color: Colors.green,
                icon: Icons.add_circle_outline,
              ),
              _buildStatCard(
                label: 'Skipped',
                value: result.skipped,
                color: Colors.orange,
                icon: Icons.skip_next_outlined,
              ),
              _buildStatCard(
                label: 'Failed',
                value: result.failed,
                color: Colors.red,
                icon: Icons.cancel_outlined,
              ),
            ],
          ),

          // Failed items list
          if (result.failedItems.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    color: Colors.red.shade50,
                    child: Text(
                      'Failed Items (${result.failedItems.length})',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: result.failedItems.length,
                    separatorBuilder: (_, _) =>
                        Divider(height: 1, color: Colors.red.shade100),
                    itemBuilder: (context, index) {
                      final item = result.failedItems[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Text(
                          item.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade700,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: const RoundedRectangleBorder(),
                  ),
                  child: const Text('Close'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => setState(() {
                    _step = _DialogStep.idle;
                    _pickedFile = null;
                    _uploadResult = null;
                    _errorMessage = null;
                  }),
                  icon: const Icon(Icons.upload_file, size: 18),
                  label: const Text('Upload Another'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: const RoundedRectangleBorder(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required int value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
