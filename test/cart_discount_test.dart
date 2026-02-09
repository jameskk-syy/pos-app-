import 'package:flutter_test/flutter_test.dart';
import 'package:pos/domain/models/product.dart';
import 'package:pos/domain/models/inventory_discount_rule.dart';
import 'package:pos/utils/cart_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('CartManager Discount Tests', () {
    final product = Products(
      id: 'ITEM001',
      name: 'Test Item',
      price: 100.0,
      image: '📦',
      category: 'Test Category',
      stockQty: 100,
      uom: 'Unit',
    );

    final rule = InventoryDiscountRule(
      name: 'Test Discount',
      ruleType: 'Item',
      itemCode: 'ITEM001',
      batchNo: null,
      itemGroup: null,
      warehouse: 'Main',
      company: 'Test Co',
      discountType: 'Percentage',
      discountValue: 10.0,
      priority: 1,
      isActive: 1,
      validFrom: null,
      validUpto: null,
      description: '10% off',
    );

    test('Add item with percentage discount', () async {
      await CartManager.clearCart();
      await CartManager.addToCart(product, quantity: 2, discountRules: [rule]);

      final cart = await CartManager.getCart();
      expect(cart.length, 1);
      expect(cart[0].quantity, 2);
      expect(cart[0].discountAmount, 20.0); // 10% of 200
      expect(cart[0].totalPrice, 180.0);
      expect(cart[0].discountName, 'Test Discount');
    });

    test('Update quantity updates discount', () async {
      await CartManager.clearCart();
      await CartManager.addToCart(product, quantity: 1, discountRules: [rule]);

      var cart = await CartManager.getCart();
      expect(cart[0].discountAmount, 10.0);

      await CartManager.updateQuantity('ITEM001', 5, discountRules: [rule]);
      cart = await CartManager.getCart();
      expect(cart[0].quantity, 5);
      expect(cart[0].discountAmount, 50.0);
      expect(cart[0].totalPrice, 450.0);
    });

    test('Amount discount', () async {
      final amountRule = InventoryDiscountRule(
        name: 'Amount Off',
        ruleType: 'Item',
        itemCode: 'ITEM001',
        batchNo: null,
        itemGroup: null,
        warehouse: 'Main',
        company: 'Test Co',
        discountType: 'Amount',
        discountValue: 15.0,
        priority: 1,
        isActive: 1,
        validFrom: null,
        validUpto: null,
        description: "\$15 off",
      );

      await CartManager.clearCart();
      await CartManager.addToCart(
        product,
        quantity: 2,
        discountRules: [amountRule],
      );

      final cart = await CartManager.getCart();
      expect(cart[0].discountAmount, 30.0); // 15 * 2
      expect(cart[0].totalPrice, 170.0);
    });
  });
}
