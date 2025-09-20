class Cart {

  int id;
  int product_id;
  // int customer_id;
  int qty;
  String name;
  double price;

  Cart({
    required this.id,
    required this.product_id,
    // required this.customer_id,
    required this.qty,
    required this.name,
    required this.price,
});

  Cart.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        product_id = json['product_id'],
        // customer_id = json['customer_id'],
        name = json['name'],
        qty = json['qty'],
        price = double.parse(json['price']);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': product_id,
      // 'customer_id': customer_id,
      'qty': qty,
      'unit_price': price,
    };
  }

}