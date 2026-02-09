import 'dart:convert';

import 'package:pos/domain/models/cart_item.dart';
import 'package:pos/domain/models/product.dart';
import 'package:pos/domain/models/inventory_discount_rule.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/core/services/storage_service.dart';

class CartManager {
  static const String _cartKey = 'shopping_cart';

  static Future<List<CartItem>> getCart() async {
    final storage = getIt<StorageService>();
    final cartString = await storage.getString(_cartKey);
    if (cartString == null) return [];

    final List<dynamic> cartJson = jsonDecode(cartString);
    return cartJson.map((item) => CartItem.fromJson(item)).toList();
  }

  static Future<void> saveCart(List<CartItem> cart) async {
    final storage = getIt<StorageService>();
    final cartString = jsonEncode(cart.map((item) => item.toJson()).toList());
    await storage.setString(_cartKey, cartString);
  }

  static Future<void> addToCart(
    Products product, {
    int quantity = 1,
    List<InventoryDiscountRule>? discountRules,
  }) async {
    final cart = await getCart();
    final index = cart.indexWhere((item) => item.product.id == product.id);

    if (index != -1) {
      final newQuantity = cart[index].quantity + quantity;
      final maxQuantity = cart[index].product.stockQty.toInt();

      if (newQuantity <= maxQuantity) {
        cart[index].quantity = newQuantity;
      } else {
        cart[index].quantity = maxQuantity;
      }

      // Re-apply discount rule for the new quantity
      if (discountRules != null) {
        _applyDiscountRule(cart[index], discountRules);
      }
    } else {
      CartItem newItem;
      if (quantity <= product.stockQty) {
        newItem = CartItem(product: product, quantity: quantity);
      } else {
        newItem = CartItem(
          product: product,
          quantity: product.stockQty.toInt(),
        );
      }

      // Apply discount rule for the new item
      if (discountRules != null) {
        _applyDiscountRule(newItem, discountRules);
      }
      cart.add(newItem);
    }

    await saveCart(cart);
  }

  static void _applyDiscountRule(
    CartItem item,
    List<InventoryDiscountRule> rules,
  ) {
    InventoryDiscountRule? bestRule;

    final now = DateTime.now();

    for (var rule in rules) {
      if (rule.isActive != 1) continue;

      // Check validity dates
      if (rule.validFrom != null) {
        final from = DateTime.tryParse(rule.validFrom!);
        if (from != null && now.isBefore(from)) continue;
      }
      if (rule.validUpto != null) {
        final upto = DateTime.tryParse(rule.validUpto!);
        if (upto != null && now.isAfter(upto.add(const Duration(days: 1)))) {
          continue;
        }
      }

      // Check item code or item group
      bool matches = false;
      if (rule.ruleType == 'Item' && rule.itemCode == item.product.id) {
        matches = true;
      } else if (rule.ruleType == 'Item Group' &&
          rule.itemGroup == item.product.category) {
        matches = true;
      }

      if (matches) {
        if (bestRule == null || rule.priority > bestRule.priority) {
          bestRule = rule;
        }
      }
    }

    if (bestRule != null) {
      double discount = 0.0;
      if (bestRule.discountType == 'Percentage') {
        discount =
            (item.product.price * item.quantity) *
            (bestRule.discountValue / 100);
      } else {
        // Amount discount per unit? Or total?
        // Based on the prompt "update price", I'll assume it's per unit for "Amount" type too if it scales.
        // But usually "Amount" in ERP systems for rule can be total.
        // Let's assume per unit for now to be safe with quantity updates.
        discount = bestRule.discountValue * item.quantity;
      }
      item.discountAmount = discount;
      item.discountName = bestRule.name;
    } else {
      item.discountAmount = 0.0;
      item.discountName = null;
    }
  }

  static Future<void> updateQuantity(
    String productId,
    int quantity, {
    List<InventoryDiscountRule>? discountRules,
  }) async {
    final cart = await getCart();
    final index = cart.indexWhere((item) => item.product.id == productId);

    if (index != -1) {
      final maxQuantity = cart[index].product.stockQty.toInt();
      if (quantity <= 0) {
        cart.removeAt(index);
      } else {
        if (quantity <= maxQuantity) {
          cart[index].quantity = quantity;
        } else {
          cart[index].quantity = maxQuantity;
        }

        // Re-apply discount rule for the new quantity
        if (discountRules != null) {
          _applyDiscountRule(cart[index], discountRules);
        }
      }
      await saveCart(cart);
    }
  }

  static Future<void> removeFromCart(String productId) async {
    final cart = await getCart();
    cart.removeWhere((item) => item.product.id == productId);
    await saveCart(cart);
  }

  static Future<void> clearCart() async {
    final storage = getIt<StorageService>();
    await storage.remove(_cartKey);
  }

  static Future<int> getCartCount() async {
    final cart = await getCart();
    int count = 0;
    for (var item in cart) {
      count += item.quantity;
    }
    return count;
  }

  static Future<double> getCartTotal() async {
    final cart = await getCart();
    double total = 0;
    for (var item in cart) {
      total += item.totalPrice;
    }
    return total;
  }
}
