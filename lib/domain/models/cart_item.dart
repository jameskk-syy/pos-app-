import 'product.dart';

class CartItem {
  final Products product;
  int quantity;
  double discountAmount;
  String? discountName;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.discountAmount = 0.0,
    this.discountName,
  });

  Map<String, dynamic> toJson() => {
    'product': product.toJson(),
    'quantity': quantity,
    'discountAmount': discountAmount,
    'discountName': discountName,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    product: Products.fromJson(json['product']),
    quantity: json['quantity'],
    discountAmount: (json['discountAmount'] ?? 0.0).toDouble(),
    discountName: json['discountName'],
  );

  double get totalPrice => (product.price * quantity) - discountAmount;
}
