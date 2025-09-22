class OrderItem{

  final String productName;
  final int qty;
  final String unitPrice;
  final int subTotal;

  OrderItem({
    required this.productName,
    required this.qty,
    required this.unitPrice,
    required this.subTotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productName: json['product_name'],
      qty: json['qty'],
      unitPrice: json['unit_price'],
      subTotal: json['sub_total'],
    );
  }

}