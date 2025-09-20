import 'package:flutter/material.dart';
import 'package:flutter_small_shop/models/Product.dart';
import 'package:provider/provider.dart';

import '../services/CartProvider.dart';
import 'CartScreen.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                product.image,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              product.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              product.description ?? "No description available",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              "₹ ${product.price.toString()}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final cartProvider =
                  Provider.of<CartProvider>(context, listen: false);

                  // Create cart request body (adjust keys to match your API)
                  Map<String, dynamic> cartData = {
                    "product_id": product.id,
                    "qty": 1,
                  };

                  await cartProvider.addToCart(
                    cart: cartData,
                    context: context,
                  );


                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen(title: 'Cart')),
                  );
                },
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text("Add to Cart"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
