import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pos/domain/responses/bulk_upload.dart';
import 'package:pos/domain/responses/sales/store_response.dart';

class BulkUploadHeader extends StatelessWidget {
  final VoidCallback onClose;

  const BulkUploadHeader({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
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
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.2),
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
            onPressed: onClose,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }
}

class BulkUploadIdleView extends StatelessWidget {
  final VoidCallback onDownloadTemplate;
  final VoidCallback onPickFile;
  final VoidCallback onUpload;
  final VoidCallback onCancel;
  final PlatformFile? pickedFile;
  final VoidCallback onRemoveFile;
  final List<Warehouse> warehouses;
  final Warehouse? selectedWarehouse;
  final Function(Warehouse?) onWarehouseChanged;
  final bool warehousesLoading;
  final String? warehouseError;
  final String? errorMessage;

  const BulkUploadIdleView({
    super.key,
    required this.onDownloadTemplate,
    required this.onPickFile,
    required this.onUpload,
    required this.onCancel,
    this.pickedFile,
    required this.onRemoveFile,
    required this.warehouses,
    this.selectedWarehouse,
    required this.onWarehouseChanged,
    this.warehousesLoading = false,
    this.warehouseError,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BulkUploadStepCard(
            stepNumber: '1',
            stepColor: Colors.blue,
            title: 'Download Template',
            subtitle: 'Get the Excel template with the required column headers.',
            child: ElevatedButton.icon(
              onPressed: onDownloadTemplate,
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Download Template'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: const RoundedRectangleBorder(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          BulkUploadStepCard(
            stepNumber: '2',
            stepColor: Colors.blue,
            title: 'Select Warehouse',
            subtitle: 'Choose the warehouse where products will be stocked.',
            child: _buildWarehouseSelector(),
          ),
          const SizedBox(height: 16),
          BulkUploadStepCard(
            stepNumber: '3',
            stepColor: Colors.orange,
            title: 'Select Your Excel File',
            subtitle: 'Fill in the template and upload the completed file.',
            child: _buildFileSelector(),
          ),
          if (errorMessage != null) _buildErrorMessage(),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel,
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
                  onPressed: (pickedFile != null && selectedWarehouse != null) ? onUpload : null,
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
    if (warehousesLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 10),
            Text('Loading warehouses...', style: TextStyle(fontSize: 13)),
          ],
        ),
      );
    }
    if (warehouseError != null && warehouses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(10),
        color: Colors.red.shade50,
        child: Text('Could not load warehouses: $warehouseError', style: TextStyle(color: Colors.red.shade700, fontSize: 12)),
      );
    }
    if (warehouses.isEmpty) return Text('No warehouses available.', style: TextStyle(color: Colors.grey.shade600, fontSize: 13));

    return DropdownButtonFormField<Warehouse>(
      initialValue: selectedWarehouse,
      isExpanded: true,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(Icons.warehouse_outlined, size: 18, color: Colors.grey.shade600),
      ),
      hint: Text('Select warehouse', style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
      items: warehouses.map((w) => DropdownMenuItem<Warehouse>(
        value: w,
        child: Row(
          children: [
            Expanded(child: Text(w.warehouseName, style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis)),
            if (w.isDefault) ...[
              const SizedBox(width: 6),
              Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1), color: Colors.green.shade100, child: Text('Default', style: TextStyle(fontSize: 9, color: Colors.green.shade800, fontWeight: FontWeight.w600))),
            ],
          ],
        ),
      )).toList(),
      onChanged: onWarehouseChanged,
    );
  }

  Widget _buildFileSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: onPickFile,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: pickedFile != null ? Colors.green.shade50 : Colors.grey.shade50,
              border: Border.all(color: pickedFile != null ? Colors.green.shade300 : Colors.grey.shade300, width: 1.5),
            ),
            child: Row(
              children: [
                Icon(pickedFile != null ? Icons.description : Icons.upload_file_outlined, color: pickedFile != null ? Colors.green : Colors.grey.shade500, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pickedFile != null ? pickedFile!.name : 'Tap to select file', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: pickedFile != null ? Colors.green.shade700 : Colors.grey.shade700), maxLines: 1, overflow: TextOverflow.ellipsis),
                      if (pickedFile != null) Text('${(pickedFile!.size / 1024).toStringAsFixed(1)} KB', style: TextStyle(fontSize: 12, color: Colors.grey.shade600))
                      else Text('Supported formats: .xlsx, .xls', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
                if (pickedFile != null) IconButton(icon: const Icon(Icons.close, size: 18, color: Colors.grey), onPressed: onRemoveFile, padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 28, minHeight: 28)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onPickFile,
          icon: const Icon(Icons.folder_open, size: 18),
          label: Text(pickedFile != null ? 'Change File' : 'Browse Files'),
          style: OutlinedButton.styleFrom(foregroundColor: Colors.orange.shade700, side: BorderSide(color: Colors.orange.shade300), padding: const EdgeInsets.symmetric(vertical: 10), shape: const RoundedRectangleBorder()),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        color: Colors.red.shade50,
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(errorMessage!, style: TextStyle(color: Colors.red.shade700, fontSize: 13))),
          ],
        ),
      ),
    );
  }
}

class BulkUploadUploadingView extends StatelessWidget {
  const BulkUploadUploadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 56, height: 56, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.blue)),
          SizedBox(height: 20),
          Text('Uploading Products...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blue)),
          SizedBox(height: 8),
          Text('Please wait while your products are being processed.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }
}

class BulkUploadResultView extends StatelessWidget {
  final ProcessResponse result;
  final VoidCallback onUploadAnother;
  final VoidCallback onClose;

  const BulkUploadResultView({super.key, required this.result, required this.onUploadAnother, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final isSuccess = result.isSuccess;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BulkUploadStatusBanner(isSuccess: isSuccess, totalProcessed: result.totalProcessed),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.4,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              BulkUploadStatCard(label: 'Created', value: result.created, color: Colors.green, icon: Icons.add_circle_outline),
              BulkUploadStatCard(label: 'Skipped', value: result.skipped, color: Colors.orange, icon: Icons.skip_next_outlined),
              BulkUploadStatCard(label: 'Failed', value: result.failed, color: Colors.red, icon: Icons.cancel_outlined),
            ],
          ),
          if (result.failedItems.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildFailedItemsList(),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: onClose, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), shape: const RoundedRectangleBorder()), child: const Text('Close'))),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton.icon(onPressed: onUploadAnother, icon: const Icon(Icons.upload_file, size: 18), label: const Text('Upload Another'), style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), elevation: 0, shape: const RoundedRectangleBorder()))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFailedItemsList() {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.red.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), color: Colors.red.shade50, child: Text('Failed Items (${result.failedItems.length})', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.red.shade700))),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: result.failedItems.length,
            separatorBuilder: (_, _) => Divider(height: 1, color: Colors.red.shade100),
            itemBuilder: (context, index) => Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), child: Text(result.failedItems[index].toString(), style: TextStyle(fontSize: 12, color: Colors.red.shade700))),
          ),
        ],
      ),
    );
  }
}

class BulkUploadStatusBanner extends StatelessWidget {
  final bool isSuccess;
  final int totalProcessed;

  const BulkUploadStatusBanner({super.key, required this.isSuccess, required this.totalProcessed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: isSuccess ? Colors.green.shade50 : Colors.red.shade50,
      child: Row(
        children: [
          Icon(isSuccess ? Icons.check_circle : Icons.error_outline, color: isSuccess ? Colors.green : Colors.red, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isSuccess ? 'Upload Successful!' : 'Upload Completed with Issues', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: isSuccess ? Colors.green.shade700 : Colors.red.shade700)),
                const SizedBox(height: 2),
                Text('$totalProcessed items processed', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BulkUploadStatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;

  const BulkUploadStatCard({super.key, required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: color.withAlpha(20), border: Border.all(color: color.withAlpha(60))),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min,
              children: [
                Text(value.toString(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
                Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BulkUploadStepCard extends StatelessWidget {
  final String stepNumber;
  final Color stepColor;
  final String title;
  final String subtitle;
  final Widget child;

  const BulkUploadStepCard({super.key, required this.stepNumber, required this.stepColor, required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 4, offset: const Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(width: 28, height: 28, decoration: BoxDecoration(color: stepColor, shape: BoxShape.circle), alignment: Alignment.center, child: Text(stepNumber, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
}
