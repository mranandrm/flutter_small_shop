import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_small_shop/models/Brand.dart';
import 'package:http/http.dart' as http;

import '../models/Product.dart';
import '../services/CartProvider.dart';
import '../util/Constants.dart';

class ProductFilterByBrandScreen extends StatefulWidget {
  final String title;
  final Brand brand;
  const ProductFilterByBrandScreen({super.key, required this.title, required this.brand});

  @override
  State<ProductFilterByBrandScreen> createState() => _ProductFilterByBrandScreenState();
}

class _ProductFilterByBrandScreenState extends State<ProductFilterByBrandScreen> {

  late  List<Product> products = [];
  CartProvider cartProvider = CartProvider();

  @override
  void initStatte() {
    super.initState();
    fetchData();
  }
  Future<void> fetchData() async{

    try{

      final brand_id = widget.brand.id.toString();
      final response = await http.get(Uri.parse(Constants.BASE_URL+Constants.PRODUCT_FILTER_BY_BRAND_ROUTE+ brand_id));

      if( response.statusCode == 200){

        final List<dynamic> data = json.decode(response.body)['data'];

        setState(() {
          products = data.map((product) => Product.fromJson(product)).toList();
        });
      } else{

        throw Exception('Failed to load Products'+ Constants.BASE_URL+Constants.PRODUCT_FILTER_BY_BRAND_ROUTE+brand_id);
      }
    }
    catch(e){
      print('Error: $e');
    }
  }

  Future<void> onRefresh() async{
    await fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              fetchData();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: products.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(products[index].name),
              onTap: () {

                Map carts = {
                  'product_id' : products[index].id,

                };

                print("Product Page Cart Content ${carts}");

                cartProvider.addToCart(carts: carts, context: context, cart: {});

              },
            );
          },
        ),
      ),
    );
  }
}
