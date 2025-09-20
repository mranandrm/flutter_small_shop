import 'package:dio/dio.dart';
import 'package:dio/dio.dart' as Dio;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/Cart.dart';
import '../models/Product.dart';
import '../util/Constants.dart';
import 'dio.dart';

class CartProvider extends  ChangeNotifier{

  bool _isLoggedIn = false;

  bool get authenticated => _isLoggedIn;

  List<Cart> _cartItems = [];

  List<Cart> get cartItems=> _cartItems;

  bool get hasItems => _cartItems.isNotEmpty;


  final storage  = new FlutterSecureStorage();

  Future<void> getCartItems() async {


    try{

      dynamic token = await storage.read(key: 'token');

      Dio.Response response = await dio().get(
        Constants.CART_ROUTE,
        options: Dio.Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print(response.data);

      _cartItems = parseCartItems(response.data);

      // Notify listeners that the cart items have been updated
      notifyListeners();
    }
    catch (e) {

      print('Get Cart Items Error: $e' + Constants.BASE_URL + Constants.CART_ROUTE);

    }
  }

  List<Cart> parseCartItems(dynamic responseData) {
    try {
      List<Cart> cartItems = [];

      if (responseData.containsKey('data') && responseData['data'] is List) {
        // Assuming 'data' contains a list of cart items
        cartItems = List<Cart>.from(responseData['data'].map((item) {
          return Cart.fromJson(item);
        }));
      }

      return cartItems;
    } catch (e) {
      print('Error parsing cart items: $e');
      return [];
    }
  }

  // Add item to the cart
  void addToCart({required Map cart, required BuildContext context}) async {

    dynamic token = await this.storage.read(key: 'token');

    try {

      Dio.Response response = await dio().post(
        Constants.ADD_TO_CART_ROUTE,
        options: Dio.Options(headers: {'Authorization' : 'Bearer $token'}),
        data: cart, // Include carts in the request body
      );

      print(response.data);

      _isLoggedIn = true;

      // Refresh the cart items after adding a new item
      await getCartItems();

      notifyListeners(); // Notify UI about changes



    } catch (e) {
      print('Cart Error: $e' + Constants.BASE_URL + Constants.CART_ROUTE);
      // Handle the error appropriately (show a message, etc.)
    }
  }


  // Remove item from the cart
  Future<void> removeFromCart({required Map cart, required BuildContext context}) async {

    dynamic token = await this.storage.read(key: 'token');

    try {

      Dio.Response response = await dio().post(
        Constants.REMOVE_FROM_CART_ROUTE,
        options: Dio.Options(headers: {'Authorization' : 'Bearer $token'}),
        data: cart, // Include carts in the request body
      );

      print(response.data);

      _isLoggedIn = true;
      // notifyListeners();

      // _cartItems.remove(cartItem);
      notifyListeners();
      // Fetch updated cart items
      await getCartItems();

      // Show a success message using a Scaffold
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${cart['product_name']} removed to cart'),
          duration: Duration(seconds: 4),
        ),
      );

    } catch (e) {
      print('Cart Error: $e' + Constants.BASE_URL + Constants.REMOVE_FROM_CART_ROUTE);
      // Handle the error appropriately (show a message, etc.)
      if (e is DioError) {
        print('DioError: ${e.message}');
      }
    }


  }


  // Get total number of items in the cart
  int getCartItemCount() {
    return _cartItems.length;
  }

  // Calculate the total price of items in the cart
  double getTotalPrice(List<Product> products) {
    double totalPrice = 0.0;
    for (Cart cartItem in _cartItems) {
      // Find the corresponding product and calculate total price
      Product product = products.firstWhere((p) => p.id == cartItem.product_id);
      totalPrice += (product.price * cartItem.qty) as double;
    }
    return totalPrice;
  }

  // Clear the cart
  Future<void> clearCart() async {

    dynamic token = await this.storage.read(key: 'token');

    try {

      Dio.Response response = await dio().post(
        Constants.CLEAR_CART_ROUTE,
        options: Dio.Options(headers: {'Authorization' : 'Bearer $token'}),
        // data: carts, // Include carts in the request body
      );

      print(response.data);

      _isLoggedIn = true;

      _cartItems.clear();
      notifyListeners();

    } catch (e) {
      print('Cart Error: $e' + Constants.BASE_URL + Constants.CART_ROUTE);
      // Handle the error appropriately (show a message, etc.)
    }

  }
}

