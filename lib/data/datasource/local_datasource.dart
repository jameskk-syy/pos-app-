import 'package:hive/hive.dart';
// import 'package:flutter/foundation.dart';

class LocalDataSource {
  static const String boxCustomers = 'customers';
  static const String boxProducts = 'products';
  static const String boxInventoryRules = 'inventory_rules';
  static const String boxPaymentMethods = 'payment_methods';
  static const String boxOfflineSales = 'offline_sales';
  static const String boxWarehouses = 'warehouses';
  static const String boxLoyaltyPrograms = 'loyalty_programs';
  static const String boxOfflineLoyaltyPoints = 'offline_loyalty_points';
  static const String boxDashboardData = 'dashboard_data';
  static const String boxStaff = 'staff';

  // --- Customers ---
  Future<void> cacheCustomers(List<Map<String, dynamic>> customers) async {
    final box = Hive.box(boxCustomers);
    await box.clear();
    await box.addAll(customers);
  }

  List<Map<String, dynamic>> getCachedCustomers() {
    final box = Hive.box(boxCustomers);
    return box.values.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // --- Staff ---
  Future<void> cacheStaff(List<Map<String, dynamic>> staff) async {
    final box = Hive.box(boxStaff);
    await box.clear();
    await box.addAll(staff);
  }

  List<Map<String, dynamic>> getCachedStaff() {
    final box = Hive.box(boxStaff);
    return box.values.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // --- Products ---
  Future<void> cacheProducts(
    List<Map<String, dynamic>> products, {
    bool clear = false,
  }) async {
    final box = Hive.box(boxProducts);

    if (clear) {
      await box.clear();
    }

    // Convert list to map keyed by item_code for incremental updates
    final Map<dynamic, Map<String, dynamic>> productMap = {};
    for (var product in products) {
      final key = product['item_code'] ?? product['itemCode'];
      if (key != null) {
        productMap[key] = product;
      } else {
        // debugPrint('Skipping product without item_code during cache: $product');
      }
    }

    if (productMap.isNotEmpty) {
      await box.putAll(productMap);
    }
  }

  List<Map<String, dynamic>> getCachedProducts() {
    final box = Hive.box(boxProducts);
    return box.values.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // --- Inventory Rules ---
  Future<void> cacheInventoryRules(List<Map<String, dynamic>> rules) async {
    final box = Hive.box(boxInventoryRules);
    await box.clear();
    await box.addAll(rules);
  }

  List<Map<String, dynamic>> getCachedInventoryRules() {
    final box = Hive.box(boxInventoryRules);
    return box.values.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // --- Payment Methods ---
  Future<void> cachePaymentMethods(List<Map<String, dynamic>> methods) async {
    final box = Hive.box(boxPaymentMethods);
    await box.clear();
    await box.addAll(methods);
  }

  List<Map<String, dynamic>> getCachedPaymentMethods() {
    final box = Hive.box(boxPaymentMethods);
    return box.values.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // --- Offline Sales ---
  Future<void> saveOfflineSale(Map<String, dynamic> saleRequest) async {
    final box = Hive.box(boxOfflineSales);
    await box.add(saleRequest);
    // debugPrint("Offline sale saved. Total pending: ${box.length}");
  }

  List<Map<String, dynamic>> getOfflineSales() {
    final box = Hive.box(boxOfflineSales);
    return box.values
        .map((e) => _fixHiveMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  // ignore: unintended_html_in_doc_comment
  /// Recursively converts Map<dynamic, dynamic> to Map<String, dynamic>
  /// which Hive often returns for nested objects.
  Map<String, dynamic> _fixHiveMap(Map<String, dynamic> map) {
    final Map<String, dynamic> fixed = {};
    map.forEach((key, value) {
      if (value is Map) {
        fixed[key] = _fixHiveMap(Map<String, dynamic>.from(value));
      } else if (value is List) {
        fixed[key] = value.map((item) {
          if (item is Map) {
            return _fixHiveMap(Map<String, dynamic>.from(item));
          }
          return item;
        }).toList();
      } else {
        fixed[key] = value;
      }
    });
    return fixed;
  }

  Future<void> clearOfflineSale(int index) async {
    final box = Hive.box(boxOfflineSales);
    await box.deleteAt(index);
  }

  Future<void> clearAllOfflineSales() async {
    final box = Hive.box(boxOfflineSales);
    await box.clear();
  }

  // --- Warehouses ---
  Future<void> cacheWarehouses(List<Map<String, dynamic>> warehouses) async {
    final box = Hive.box(boxWarehouses);
    await box.clear();
    await box.addAll(warehouses);
  }

  List<Map<String, dynamic>> getCachedWarehouses() {
    final box = Hive.box(boxWarehouses);
    return box.values.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // --- Loyalty Programs ---
  Future<void> cacheLoyaltyPrograms(List<Map<String, dynamic>> programs) async {
    final box = Hive.box(boxLoyaltyPrograms);
    await box.clear();
    await box.addAll(programs);
  }

  List<Map<String, dynamic>> getCachedLoyaltyPrograms() {
    final box = Hive.box(boxLoyaltyPrograms);
    return box.values.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // --- Offline Loyalty Points ---
  Future<void> saveOfflineLoyaltyPoints(
    Map<String, dynamic> loyaltyRequest,
  ) async {
    final box = Hive.box(boxOfflineLoyaltyPoints);
    await box.add(loyaltyRequest);
    // debugPrint("Offline loyalty points saved. Total pending: ${box.length}");
  }

  List<Map<String, dynamic>> getOfflineLoyaltyPoints() {
    final box = Hive.box(boxOfflineLoyaltyPoints);
    return box.values.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> clearAllOfflineLoyaltyPoints() async {
    final box = Hive.box(boxOfflineLoyaltyPoints);
    await box.clear();
  }

  // --- Dashboard Data ---
  Future<void> cacheDashboardData(Map<String, dynamic> dashboardData) async {
    final box = Hive.box(boxDashboardData);
    await box.clear(); // Always replace with latest data
    await box.put('latest', dashboardData);
    // debugPrint("Dashboard data cached");
  }

  Map<String, dynamic>? getCachedDashboardData() {
    final box = Hive.box(boxDashboardData);
    final data = box.get('latest');
    return data != null ? Map<String, dynamic>.from(data as Map) : null;
  }

  Future<void> clearDashboardCache() async {
    final box = Hive.box(boxDashboardData);
    await box.clear();
  }
}
