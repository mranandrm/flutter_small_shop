import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/Brand.dart';
import '../util/Constants.dart';

class BrandScreen extends StatefulWidget {
  final String title;
  const BrandScreen({super.key, required this.title});

  @override
  State<BrandScreen> createState() => _BrandScreenState();
}




class _BrandScreenState extends State<BrandScreen> {

  late List<Brand> brands = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async{

    try {

      final response = await http.get(Uri.parse(Constants.BASE_URL+Constants.BRAND_ROUTE));
      if(response.statusCode == 200){

        final List<dynamic> data = json.decode(response.body) ['data'];

        setState(() {
          brands = data.map((brand) => Brand.fromJson(brand)
          ).toList();
        });
      }
      else{

        throw Exception('Failed to load categories' + Constants.BASE_URL+Constants.BRAND_ROUTE);
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
          child: brands.isEmpty ? Center(child: CircularProgressIndicator()): ListView.builder(
              itemCount: brands.length,
              itemBuilder: (context,index){
                return ListTile(
                    leading: Image.network(brands[index].logo),
                    title: Text(brands[index].name),
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
