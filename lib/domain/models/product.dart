import 'package:pos/domain/responses/item_list.dart';

class Products {
  final String id;
  final String name;
  final double price;
  final String image;
  final String category;
  final double stockQty;
  final String uom;

  Products({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.category,
    required this.stockQty,
    required this.uom,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'image': image,
        'category': category,
        'stockQty': stockQty,
        'uom': uom,
      };

  factory Products.fromJson(Map<String, dynamic> json) => Products(
        id: json['id'],
        name: json['name'],
        price: json['price'],
        image: json['image'],
        category: json['category'],
        stockQty: json['stockQty'],
        uom: json['uom'] ?? 'Unit', 
      );

  static String getEmojiForCategory(String category) {
    final Map<String, String> categoryIcons = {
      'Electronics': '💻',
      'Consumables': '🛒',
      'Raw Material': '⚙️',
      'Finished Goods': '📦',
      'Subassembly': '🔧',
      'Sports': '⚽',
      'Home': '🏠',
      'Accessories': '👜',
      'Default': '📊',
    };
    return categoryIcons[category] ?? categoryIcons['Default']!;
  }
  static Products fromStockItem(StockItem item) {
    return Products(
      id: item.itemCode,
      name: item.itemName,
      price: item.price,
      image: Products.getEmojiForCategory(item.itemGroup),
      category: item.itemGroup,
      stockQty: item.stockQty,
      uom: item.stockUom,
    );
  }
}