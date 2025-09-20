import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_small_shop/models/Cart.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../services/CartProvider.dart';
import '../util/Constants.dart';

class CartScreen extends StatefulWidget {

  final String title;
  const CartScreen({super.key,required this.title});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

  final storage = FlutterSecureStorage();

  late List<Cart> carts =[];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // Run immediately once
    fetchData();

    // Run every 5 seconds
    Timer.periodic(Duration(seconds: 5), (timer) {
      fetchData();
    });

  }

  double getGrandTotalPrice() {
    return carts.fold(0, (sum, item) => sum + (item.price * item.qty));
  }

  double getSubtotal(Cart row) {
    return row.price * row.qty;
  }

  Future<void> fetchData() async {
    try {
      dynamic token = await storage.read(key: 'token');
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      };

      final response = await http.get(
          headers: headers,
          Uri.parse(Constants.BASE_URL + Constants.CART_ROUTE)
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        setState(() {
          carts = data.map((cart) => Cart.fromJson(cart)).toList();
        });
      } else {
        throw Exception('Failed to load carts');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> updateCartQuantity(int cartId, String route) async {
    try {
      dynamic token = await storage.read(key: 'token');

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      };

      final body = json.encode({'cart_id': cartId});

      final response = await http.post(
        headers: headers,
        Uri.parse(Constants.BASE_URL + route),
        body: body,
      );

      if (response.statusCode == 200) {
        fetchData();
      } else {
        throw Exception('Failed to update cart quantity');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> onRefresh() async {
    await fetchData();
  }

  Widget _buildCartProduct(int index) {
    return GestureDetector(
      onLongPress: () async {
        Map cart = {
          'cart_id': carts[index].id.toString(),
          'product_name': carts[index].name,
        };
        await Provider.of<CartProvider>(context, listen: false)
            .removeFromCart(cart: cart, context: context);
        await fetchData();
      },
      child: ListTile(
        contentPadding: EdgeInsets.all(20.0),
        title: Text(
          carts[index].name,
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "\₹${carts[index].price.toString()} x ${carts[index].qty.toString()}",
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove_circle_outline),
                  onPressed: () {
                    if (carts[index].qty > 1) {
                      updateCartQuantity(
                          carts[index].id, Constants.DECREASE_CART_QTY_ROUTE);
                    }
                  },
                ),
                Text(carts[index].qty.toString()),
                IconButton(
                  icon: Icon(Icons.add_circle_outline),
                  onPressed: () {
                    updateCartQuantity(
                        carts[index].id, Constants.INCREASE_CART_QTY_ROUTE);
                  },
                ),
              ],
            ),
          ],
        ),
        trailing: Text(
          '\₹${getSubtotal(carts[index]).toStringAsFixed(2)}',
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Shopping Cart (${carts.length})',
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              await Provider.of<CartProvider>(context, listen: false).clearCart();
              await fetchData();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              if (carts.isEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 100),
                  child: Center(child: Text("Your Cart is Empty")),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: carts.length,
                  itemBuilder: (context, index) {
                    return _buildCartProduct(index);
                  },
                  separatorBuilder: (context, index) {
                    return Divider(color: Colors.grey[300]);
                  },
                ),
              SizedBox(height: 100), // Prevents last item from being hidden by bottomSheet
            ],
          ),
        ),
      ),
      bottomSheet: carts.isEmpty
          ? null
          : Container(
        height: 80.0,
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.pink, // Set background color to match theme
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
        child: Center(
          child: SizedBox(
            width: double.infinity, // Make button full width
            child: TextButton(
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => PaymentSelectionScreen(
                //       products: carts,
                //     ),
                //   ),
                // );
              },

              child: Text(
                'PLACE ORDER - ₹${getGrandTotalPrice().toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
