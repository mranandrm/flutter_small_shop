import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_small_shop/models/Category.dart';
import 'package:flutter_small_shop/util/Constants.dart';

import 'package:http/http.dart' as http;

class CategoryScreen extends StatefulWidget {
   final String title;
  const CategoryScreen({super.key, required this.title});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  
  late List<Category> categories = [];
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }
  
  Future<void> fetchData() async{
    
    try {
      
      final response = await http.get(Uri.parse(Constants.BASE_URL+Constants.CATEGORY_ROUTE));
      if(response.statusCode == 200){

        final List<dynamic> data = json.decode(response.body) ['data'];

        setState(() {
          categories = data.map((category) => Category.fromJson(category)
          ).toList();
        });
      }
      else{

        throw Exception('Failed to load categories' + Constants.BASE_URL+Constants.CATEGORY_ROUTE);
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
          child: categories.isEmpty ? Center(child: CircularProgressIndicator()): ListView.builder(
            itemCount: categories.length,
              itemBuilder: (context,index){

              return ListTile(
                title: Text(categories[index].name),
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
