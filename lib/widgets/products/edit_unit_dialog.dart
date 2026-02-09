import 'package:flutter/material.dart';
import 'package:pos/domain/responses/uom_response.dart';
import 'package:pos/presentation/units/bloc/units_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditUnitDialog extends StatefulWidget {
  final UOM uom;

  const EditUnitDialog({super.key, required this.uom});

  @override
  State<EditUnitDialog> createState() => _EditUnitDialogState();
}

class _EditUnitDialogState extends State<EditUnitDialog> {
  late TextEditingController _nameController;
  late bool _mustBeWholeNumber;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.uom.uomName);
    _mustBeWholeNumber = widget.uom.mustBeWholeNumber ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      context.read<UnitsBloc>().add(
        UpdateUnit(
          name: widget.uom.name, // The original name acts as identifier
          uomName: _nameController.text.trim(),
          mustBeWholeNumber: _mustBeWholeNumber,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = MediaQuery.of(context).size.width >= 600;
        final width = isTablet
            ? 500.0
            : MediaQuery.of(context).size.width * 0.9;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Edit Unit of Measure',
            style: TextStyle(
              fontSize: isTablet ? 24 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: width,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Unit Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Is Whole Number'),
                    value: _mustBeWholeNumber,
                    activeThumbColor: Colors.blue,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) {
                      setState(() => _mustBeWholeNumber = value);
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}
