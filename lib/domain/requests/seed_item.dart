class CreateOrderRequest {
  final String priceList;
  final String buyingPriceList;
  final String warehouse;
  final String company;
  final String industry;
  final List<OrderItemRequest> items;

  CreateOrderRequest({
    required this.priceList,
    required this.buyingPriceList,
    required this.warehouse,
    required this.company,
    required this.industry,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      "price_list": priceList,
      "buying_price_list": buyingPriceList,
      "warehouse": warehouse,
      "company": company,
      "industry": industry,
      "items": items.map((e) => e.toJson()).toList(),
    };
  }
}

class OrderItemRequest {
  final String itemCode;
  final String itemName;
  final double itemPrice;
  final String itemGroup;
  final String uom;
  final double buyingPrice;
  final int qty;
  final String warehouse;
  final double basicRate;

  OrderItemRequest({
    required this.itemCode,
    required this.itemName,
    required this.itemPrice,
    required this.itemGroup,
    required this.uom,
    required this.buyingPrice,
    required this.qty,
    required this.warehouse,
    required this.basicRate,
  });

  Map<String, dynamic> toJson() {
    return {
      "item_code": itemCode,
      "item_name": itemName,
      "item_price": itemPrice,
      "item_group": itemGroup,
      "uom": uom,
      "buying_price": buyingPrice,
      "qty": qty,
      "warehouse": warehouse,
      "basic_rate": basicRate,
    };
  }
}