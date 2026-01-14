import 'package:flutter/material.dart';
import 'package:pos/domain/models/product.dart';

class AddToCartDialog extends StatefulWidget {
  final Products product;
  final Function(int quantity, double amount) onAdd;

  const AddToCartDialog({super.key, required this.product, required this.onAdd});

  @override
  State<AddToCartDialog> createState() => _AddToCartDialogState();
}

class _AddToCartDialogState extends State<AddToCartDialog> {
  bool isUnitMode = true;
  bool _isConfirmDisabled = false;
  String _errorMessage = '';
  
  final TextEditingController quantityController = TextEditingController(text: '1');
  final TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    quantityController.addListener(_validateInput);
    amountController.addListener(_validateInput);
    _validateInput(); // Initial validation
  }

  @override
  void dispose() {
    quantityController.removeListener(_validateInput);
    amountController.removeListener(_validateInput);
    quantityController.dispose();
    amountController.dispose();
    super.dispose();
  }

  void _validateInput() {
    if (isUnitMode) {
      _validateQuantity();
    } else {
      _validateAmount();
    }
  }

  void _validateQuantity() {
    final quantityText = quantityController.text.trim();
    
    if (quantityText.isEmpty) {
      setState(() {
        _isConfirmDisabled = true;
        _errorMessage = '';
      });
      return;
    }

    final quantity = int.tryParse(quantityText);
    
    if (quantity == null || quantity <= 0) {
      setState(() {
        _isConfirmDisabled = true;
        _errorMessage = 'Enter valid quantity';
      });
      return;
    }

    if (quantity > widget.product.stockQty) {
      setState(() {
        _isConfirmDisabled = true;
        _errorMessage = 'Exceeds available stock (${widget.product.stockQty})';
      });
      return;
    }

    setState(() {
      _isConfirmDisabled = false;
      _errorMessage = '';
    });
  }

  void _validateAmount() {
    final amountText = amountController.text.trim();
    
    if (amountText.isEmpty) {
      setState(() {
        _isConfirmDisabled = true;
        _errorMessage = '';
      });
      return;
    }

    final amount = double.tryParse(amountText);
    
    if (amount == null || amount <= 0) {
      setState(() {
        _isConfirmDisabled = true;
        _errorMessage = 'Enter valid amount';
      });
      return;
    }

    // Calculate quantity based on amount
    final quantity = (amount / widget.product.price).ceil();
    
    if (quantity > widget.product.stockQty) {
      setState(() {
        _isConfirmDisabled = true;
        _errorMessage = 'Amount exceeds stock limit (${widget.product.stockQty} units)';
      });
      return;
    }

    setState(() {
      _isConfirmDisabled = false;
      _errorMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add to cart',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.product.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 20, color: Colors.grey.shade700),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                height: 36,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue.shade400),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isUnitMode = true;
                            _validateInput();
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isUnitMode ? Colors.blue.shade400 : Colors.white,
                            borderRadius: const BorderRadius.horizontal(left: Radius.circular(5)),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Unit',
                            style: TextStyle(
                              color: isUnitMode ? Colors.white : Colors.blue.shade400,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isUnitMode = false;
                            _validateInput();
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: !isUnitMode ? Colors.blue.shade400 : Colors.white,
                            borderRadius: const BorderRadius.horizontal(right: Radius.circular(5)),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Value',
                            style: TextStyle(
                              color: !isUnitMode ? Colors.white : Colors.blue.shade400,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isUnitMode ? 'Quantity*' : 'Amount*',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: isUnitMode ? quantityController : amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: isUnitMode ? 'Enter quantity' : 'Enter amount',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color: _errorMessage.isNotEmpty ? Colors.red : Colors.grey.shade300
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color: _errorMessage.isNotEmpty ? Colors.red : Colors.blue.shade400
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
                  errorStyle: const TextStyle(fontSize: 12),
                ),
                onChanged: (value) => _validateInput(),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red, width: 1),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isConfirmDisabled ? null : () {
                        int qty;
                        double amt;
                        
                        if (isUnitMode) {
                          qty = int.tryParse(quantityController.text) ?? 1;
                          amt = qty * widget.product.price;
                        } else {
                          amt = double.tryParse(amountController.text) ?? 0;
                          qty = (amt / widget.product.price).ceil();
                        }
                        
                        // Final validation check
                        if (qty > widget.product.stockQty) {
                          setState(() {
                            _errorMessage = 'Exceeds available stock (${widget.product.stockQty})';
                            _isConfirmDisabled = true;
                          });
                          return;
                        }
                        
                        widget.onAdd(qty, amt);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isConfirmDisabled 
                            ? Colors.grey.shade400 
                            : Colors.blue.shade400,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}