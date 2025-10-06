import 'dart:async';
import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_small_shop/models/HomeSlider.dart';
import 'package:flutter_small_shop/models/Brand.dart';
import 'package:flutter_small_shop/models/Category.dart';
import 'package:flutter_small_shop/screens/ProductFilterByBrandScreen.dart';
import 'package:flutter_small_shop/services/AuthProvider.dart';
import 'package:flutter_small_shop/util/Constants.dart';
import 'package:flutter_small_shop/widgets/CustomDrawer.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'ProductFilterByCategoryScreen.dart';

class HomeScreen extends StatefulWidget {
  final String title;

  const HomeScreen({Key? key, required this.title}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;

  final storage = FlutterSecureStorage();

  int _current = 0;

  late List<HomeSlider> imgList = [];
  late List<Brand> brand = [];
  late List<Category> category = [];

  @override
  void initState() {
    super.initState();
    // fetchAllData();
    readToken();
  }

  /// Fetch all API data together
  Future<void> fetchAllData() async {
    await Future.wait([
      fetchSlider(),
      fetchBrand(),
      fetchCategory(),
    ]);

    // If you still want periodic refresh:
    refreshData();
  }

  /// Safer auto-refresh (every 60s instead of 3s)
  void refreshData() {
    Future.delayed(const Duration(seconds: 60), () async {
      if (!mounted) return; // prevent setState after dispose
      await fetchAllData();
      refreshData(); // recursive call
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void readToken() async {
    String? token = await storage.read(key: 'token');
    if (token != null) {
      Provider.of<AuthProvider>(context, listen: false).tryToken(token: token);
      print("read token: $token");
    } else {
      print("Token is null");
    }
  }

  Future<void> fetchSlider() async {
    try {
      final response = await http.get(
        Uri.parse(Constants.BASE_URL + Constants.HOME_SLIDER_ROUTE),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        setState(() {
          imgList = data.map((row) => HomeSlider.fromJson(row)).toList();
        });
      } else {
        print('Failed to load slider');
      }
    } catch (e) {
      print('Error fetching slider: $e');
    }
  }

  Future<void> fetchBrand() async {
    try {
      final response = await http.get(
        Uri.parse(Constants.BASE_URL + Constants.BRAND_ROUTE),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        setState(() {
          brand = data.map((row) => Brand.fromJson(row)).toList();
        });
      } else {
        print('Failed to load brand');
      }
    } catch (e) {
      print('Error fetching brand: $e');
    }
  }

  Future<void> fetchCategory() async {
    try {
      final response = await http.get(
        Uri.parse(Constants.BASE_URL + Constants.CATEGORY_ROUTE),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        setState(() {
          category = data.map((row) => Category.fromJson(row)).toList();
        });
      } else {
        print('Failed to load category');
      }
    } catch (e) {
      print('Error fetching category: $e');
    }
  }

  List<Widget> get imageSliders => imgList
      .map(
        (item) => ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        item.image_path,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) =>
        const Icon(Icons.broken_image, size: 100),
      ),
    ),
  )
      .toList();

  List<Widget> get brandSliders => brand
      .map(
        (item) => InkWell(
  onTap: (){
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductFilterByBrandScreen(
          brand: item,
          title: item.name,
        ),
      ),
    );
  },
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  item.logo,
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 50),
                ),
              ),
              const SizedBox(height: 5),
              Text(item.name, style: const TextStyle(fontSize: 14)),
            ],
          ),
        )
  )
      .toList();

  List<Widget> get categorySliders => category
      .map(
        (item) => InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductFilterByCategoryScreen(
                  category: item,
                  title: item.name,
                ),
              ),
            );
          },
          child:  Column(
            children: [
              CircleAvatar(
                radius: 30,
                child: Text(
                  item.name[0].toUpperCase(),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 5),
              Text(item.name, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
  )
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      drawer: CustomDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Main slider
            CarouselSlider(
              items: imageSliders,
              options: CarouselOptions(
                autoPlay: true,
                enlargeCenterPage: true,
                aspectRatio: 2.0,
                onPageChanged: (index, reason) {
                  setState(() {
                    _current = index;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text("Brands",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            CarouselSlider(
              items: brandSliders,
              options: CarouselOptions(
                autoPlay: true,
                viewportFraction: 0.3,
                enlargeCenterPage: false,
              ),
            ),
            const SizedBox(height: 20),
            const Text("Categories",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            CarouselSlider(
              items: categorySliders,
              options: CarouselOptions(
                autoPlay: true,
                viewportFraction: 0.25,
                enlargeCenterPage: false,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
