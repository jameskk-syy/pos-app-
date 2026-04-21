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
import 'package:pos/presentation/stores/bloc/store_bloc.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pos/screens/products/widgets/bulk_upload_widgets.dart';

Future<void> showBulkUploadDialog(BuildContext context) {
  return showDialog(context: context, barrierDismissible: false, builder: (_) => BulkUploadDialog(productsRepo: getIt<ProductsRepo>()));
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
  String _company = '', _industry = '';
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
    setState(() { _company = user.message.company.name; _industry = user.message.posIndustry.industryCode; });
    context.read<StoreBloc>().add(GetAllStores(company: _company));
  }

  Future<void> _downloadTemplate() async {
    try {
      final excelFile = excel.Excel.createExcel();
      final sheet = excelFile['Products'];
      excelFile.delete('Sheet1');
      final headerStyle = excel.CellStyle(backgroundColorHex: excel.ExcelColor.fromHexString('#1E3A5F'), fontColorHex: excel.ExcelColor.fromHexString('#FFFFFF'), bold: true, horizontalAlign: excel.HorizontalAlign.Center);
      final headers = ['item_code', 'item_name', 'item_price', 'buying_price', 'item_group', 'uom', 'qty'];
      for (var i = 0; i < headers.length; i++) {
        final cell = sheet.cell(excel.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = excel.TextCellValue(headers[i]); cell.cellStyle = headerStyle; sheet.setColumnWidth(i, 20);
      }
      final exampleValues = <excel.CellValue>[excel.TextCellValue('ITEM001'), excel.TextCellValue('Sample Item'), excel.DoubleCellValue(9.99), excel.DoubleCellValue(5.50), excel.TextCellValue('All Item Groups'), excel.TextCellValue('Nos'), excel.IntCellValue(10)];
      final exampleStyle = excel.CellStyle(fontColorHex: excel.ExcelColor.fromHexString('#555555'), italic: true);
      for (var i = 0; i < exampleValues.length; i++) {
        final cell = sheet.cell(excel.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 1));
        cell.value = exampleValues[i]; cell.cellStyle = exampleStyle;
      }
      Directory? dir; try { dir = await getDownloadsDirectory(); } catch (_) {} dir ??= await getTemporaryDirectory();
      final filePath = '${dir.path}/bulk_upload_template.xlsx';
      final bytes = excelFile.encode(); if (bytes == null) throw Exception('Failed to encode Excel file');
      await File(filePath).writeAsBytes(bytes);
      if (!mounted) return;
      await Share.shareXFiles([XFile(filePath)], subject: 'Product Bulk Upload Template', text: 'Excel template for bulk product upload.');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Template saved to: ${dir.path}'), backgroundColor: Colors.green));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to generate template: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['xlsx', 'xls']);
    if (result != null && result.files.isNotEmpty) setState(() { _pickedFile = result.files.first; _errorMessage = null; });
  }

  Future<void> _upload() async {
    if (_pickedFile == null || _selectedWarehouse == null) { setState(() => _errorMessage = 'Please select a file and warehouse first.'); return; }
    final path = _pickedFile!.path; if (path == null) { setState(() => _errorMessage = 'Could not read file path.'); return; }
    setState(() { _step = _DialogStep.uploading; _errorMessage = null; });
    try {
      final response = await widget.productsRepo.bulkUploadProducts(filePath: path, warehouse: _selectedWarehouse!.name, company: _company, industry: _industry);
      if (!mounted) return;
      setState(() { _uploadResult = response; _step = _DialogStep.result; });
    } on DioException catch (e) {
      setState(() { _errorMessage = e.response?.data?['message']?.toString() ?? e.message ?? 'Upload failed.'; _step = _DialogStep.idle; });
    } catch (e) {
      setState(() { _errorMessage = e.toString().replaceFirst('Exception: ', ''); _step = _DialogStep.idle; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth < 600 ? screenWidth * 0.95 : (screenWidth < 1024 ? screenWidth * 0.7 : 640.0);

    return BlocListener<StoreBloc, StoreState>(
      listener: (context, state) {
        if (state is StoreStateSuccess) {
          final warehouses = state.storeGetResponse.message.data;
          Warehouse? defaultWh; if (warehouses.isNotEmpty) { try { defaultWh = warehouses.firstWhere((w) => w.isDefault); } catch (_) { defaultWh = warehouses.first; } }
          setState(() { _warehouses = warehouses; _selectedWarehouse ??= defaultWh; _warehousesLoading = false; _warehouseError = null; });
        } else if (state is StoreStateFailure) { setState(() { _warehousesLoading = false; _warehouseError = state.error; }); }
        else if (state is StoreStateLoading) { setState(() => _warehousesLoading = true); }
      },
      child: Dialog(
        shape: const RoundedRectangleBorder(),
        insetPadding: EdgeInsets.symmetric(horizontal: screenWidth < 600 ? 12 : 32, vertical: 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: dialogWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BulkUploadHeader(onClose: () => Navigator.of(context).pop()),
              Flexible(child: AnimatedSwitcher(duration: const Duration(milliseconds: 250), child: _buildBodyContent())),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBodyContent() {
    switch (_step) {
      case _DialogStep.idle:
        return BulkUploadIdleView(
          onDownloadTemplate: _downloadTemplate,
          onPickFile: _pickFile,
          onUpload: _upload,
          onCancel: () => Navigator.of(context).pop(),
          pickedFile: _pickedFile,
          onRemoveFile: () => setState(() => _pickedFile = null),
          warehouses: _warehouses,
          selectedWarehouse: _selectedWarehouse,
          onWarehouseChanged: (w) => setState(() => _selectedWarehouse = w),
          warehousesLoading: _warehousesLoading,
          warehouseError: _warehouseError,
          errorMessage: _errorMessage,
        );
      case _DialogStep.uploading:
        return const BulkUploadUploadingView();
      case _DialogStep.result:
        return BulkUploadResultView(
          result: _uploadResult!,
          onUploadAnother: () => setState(() { _step = _DialogStep.idle; _pickedFile = null; _uploadResult = null; _errorMessage = null; }),
          onClose: () => Navigator.of(context).pop(),
        );
    }
  }
}
