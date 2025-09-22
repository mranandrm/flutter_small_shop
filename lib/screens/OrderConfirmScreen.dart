import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/Cart.dart';
import '../util/Constants.dart';
import 'OrderSuccessScreen.dart';

class OrderConfirmScreen extends StatefulWidget {

  final String title;
  final List<Cart> products;
  final String paymentMethod;
  const OrderConfirmScreen({super.key,required this.title, required this.products, required this.paymentMethod });

  @override
  State<OrderConfirmScreen> createState() => _OrderConfirmScreenState();
}

class _OrderConfirmScreenState extends State<OrderConfirmScreen> {

  final storage = FlutterSecureStorage();

  Future<void> confirmOrder() async{


     try{
         dynamic token = await storage.read(key: 'token');

         final header = {

           'Authorization': 'Bearer $token',
           'Content-Type': 'application/json',

         };
         final body = json.encode({
           'order_items': widget.products.map((p) => p.toJson()).toList(),
           'payment_method': widget.paymentMethod,
         });

         final response = await http.post(
           Uri.parse(Constants.BASE_URL + Constants.ORDER_CONFIRM),
           headers: header,
           body: body,
         );

         if (response.statusCode == 201) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Order confirmed successfully!')),
           );

           var responseJson = json.decode(response.body);
           var orderId = responseJson['data']['id'].toString();

           Navigator.pushAndRemoveUntil(
             context,
             MaterialPageRoute(
               builder: (context) => OrderSuccessScreen(
                 title: 'Order Success',
                 order_id: orderId,
               ),
             ),
                 (Route<dynamic> route) => false,
           );
         } else {
           print(response.statusCode);
           print(response.body);
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Failed to confirm order')),
           );
         }
     }

     catch (e) {

       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Error: $e')),
       );
     }
  }


  @override
  Widget build(BuildContext context) {
    double totalPrice =
    widget.products.fold(0, (sum, item) => sum + (item.price * item.qty));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Payment Method: ${widget.paymentMethod}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Products:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...widget.products.map((product) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Qty: ${product.qty}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          Text(
                            '₹ ${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          Text(
                            'Total ₹ ${product.qty * product.price}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            const Divider(thickness: 1.5, height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Price:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '₹ ${totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: confirmOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'Confirm Order',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
