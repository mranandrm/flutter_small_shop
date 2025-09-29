import 'package:intl/intl.dart';
import 'OrderItem.dart';

class Order {
  final int id;
  final String customerName;
  // final String timings;
  final String totalAmount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItem> orderItems;

  Order({
    required this.id,
    required this.customerName,
    // required this.timings,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
    required this.orderItems,
  });

  // Factory constructor to create Order object from JSON
  factory Order.fromJson(Map<String, dynamic> json) {
    var list = json['order_items'] as List;
    List<OrderItem> orderItemsList = list.map((i) => OrderItem.fromJson(i)).toList();

    return Order(
      id: json['id'],
      customerName: json['customer_name'],
      // timings: json['timings'],
      totalAmount: json['total_amount'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      orderItems: orderItemsList,
    );
  }

  // Format date function
  String formatDate(DateTime date) {
    return DateFormat('dd-MM-yyyy HH:mm:ss').format(date);
  }

  // Get formatted createdAt
  String get formattedCreatedAt => formatDate(createdAt);

  // Get formatted updatedAt
  String get formattedUpdatedAt => formatDate(updatedAt);
}