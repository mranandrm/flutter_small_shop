import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_small_shop/models/Order.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;

import '../util/Constants.dart';
import 'OrderDetailScreen.dart';

class OrderScreen extends StatefulWidget {
  final String title;
  const OrderScreen({super.key, required this.title});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {

  late  Future<List<Order>>  futureOrders;
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    futureOrders = fetchOrders();
  }

  Future<List<Order>> fetchOrders() async {
    dynamic token = await storage.read(key: 'token');
    final response = await http.get(
      Uri.parse(Constants.BASE_URL + Constants.ORDER_ROUTE),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return data.map<Order>((json) => Order.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load orders');
    }
  }

  Future<void> deleteOrder(int orderId) async {
    dynamic token = await storage.read(key: 'token');
    final response = await http.delete(
      Uri.parse("${Constants.BASE_URL}${Constants.ORDER_DELETE_ROUTE}/$orderId"),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        futureOrders = fetchOrders();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete order')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder<List<Order>>(
        future: futureOrders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No orders available.'));
          } else {
            final orders = snapshot.data!;

            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Slidable(
                  key: ValueKey(order.id),
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) => deleteOrder(order.id),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    elevation: 2.0,
                    child: ListTile(
                      title: Text(order.customerName),
                      subtitle: Text('Total: ₹${order.totalAmount}'),
                      trailing: Icon(Icons.arrow_forward),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderDetailScreen(order: order),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}