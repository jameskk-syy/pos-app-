import 'dart:convert';

import 'package:pos/domain/models/cart_item.dart';
import 'package:pos/domain/models/product.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartManager {
  static const String _cartKey = 'shopping_cart';

  static Future<List<CartItem>> getCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartString = prefs.getString(_cartKey);
    if (cartString == null) return [];

    final List<dynamic> cartJson = jsonDecode(cartString);
    return cartJson.map((item) => CartItem.fromJson(item)).toList();
  }

  static Future<void> saveCart(List<CartItem> cart) async {
    final prefs = await SharedPreferences.getInstance();
    final cartString = jsonEncode(cart.map((item) => item.toJson()).toList());
    await prefs.setString(_cartKey, cartString);
  }

  static Future<void> addToCart(Products product, {int quantity = 1}) async {
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
    } else {
      if (quantity <= product.stockQty) {
        final newItem = CartItem(product: product);
        newItem.quantity = quantity;
        cart.add(newItem);
      } else {
        final newItem = CartItem(product: product);
        newItem.quantity = product.stockQty.toInt();
        cart.add(newItem);
      }
    }

    await saveCart(cart);
  }

  static Future<void> updateQuantity(String productId, int quantity) async {
    final cart = await getCart();
    final index = cart.indexWhere((item) => item.product.id == productId);

    if (index != -1) {
      final maxQuantity = cart[index].product.stockQty.toInt();
      if (quantity <= 0) {
        cart.removeAt(index);
      } else if (quantity <= maxQuantity) {
        cart[index].quantity = quantity;
      } else {
        cart[index].quantity = maxQuantity;
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
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