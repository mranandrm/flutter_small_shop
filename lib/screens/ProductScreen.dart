import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_small_shop/models/Product.dart';
import 'package:http/http.dart' as http;

import '../util/Constants.dart';

class ProductScreen extends StatefulWidget {
  final String title;

  const ProductScreen({super.key,required this.title});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {

  late List<Product> products = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async{

    try {

      final response = await http.get(Uri.parse(Constants.BASE_URL+Constants.Product_ROUTE));
      if(response.statusCode == 200){

        final List<dynamic> data = json.decode(response.body) ['data'];

        setState(() {
          products = data.map((brand) => Product.fromJson(brand)
          ).toList();
        });
      }
      else{

        throw Exception('Failed to load categories' + Constants.BASE_URL+Constants.Product_ROUTE);
      }
    }
    catch(e) {

      print('Error: $e');
    }
  }

  // void navigateToProductScreen(Category SelectedCategory) {
  //
  //   Navigator.push(
  //       context,
  //     MaterialPageRoute(builder: (context) => ProductFilterByCategoryScreen(title: selectedCategory.name, category:selectedCategory),
  //     ),
  //   );
  // }

  Future<void> onRefresh() async {
    await fetchData();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        title: Text(widget.title),

        actions: [
          IconButton(
              onPressed: () {
                fetchData();
              },
              icon: Icon(Icons.refresh)),
        ],
      ),

      body: RefreshIndicator(
          child: products.isEmpty ? Center(child: CircularProgressIndicator()): ListView.builder(
              itemCount: products.length,
              itemBuilder: (context,index){
                return ListTile(
                    leading: Image.network(products[index].image),
                    title: Text(products[index].name),
                    // description: Text(products[index].description),
                    // price: Text(products[index].price),
                    onTap: (){
                      // navigateToProductScreen(categories[index]);
                    }
                );
              }
          ) ,
          onRefresh: onRefresh
      ),
    );
  }
}
