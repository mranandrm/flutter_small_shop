import 'package:flutter/material.dart';
import 'package:flutter_small_shop/screens/CartScreen.dart';
import 'package:flutter_small_shop/screens/OrderScreen.dart';
import 'package:flutter_small_shop/screens/ProductScreen.dart';
import 'package:flutter_small_shop/screens/SettingScreen.dart';
import 'package:provider/provider.dart';

import '../screens/LoginScreen.dart';
import '../screens/RegisterScreen.dart';
import '../services/AuthProvider.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          if (!auth.authenticated) {
            return ListView(
              children: [
                ListTile(
                  title: Text('Login'),
                  leading: Icon(Icons.login),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => LoginScreen(title: 'Login Screen')),
                    );
                  },
                ),
                ListTile(
                  title: Text('Register'),
                  leading: Icon(Icons.app_registration),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterScreen(title: 'Register')),
                    );
                  },
                ),


              ],
            );
          } else {

            print(auth.user.toString());
            String avatar = auth.user?.avatar as String;
            String name = auth.user?.name as String;
            String email = auth.user?.email as String;

            return ListView(
              children: [
                DrawerHeader(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(avatar),
                          radius: 30,
                        ),
                        SizedBox(height: 10),
                        Text(
                          name,
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: 20),
                        Text(
                          email,
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                ),
                ListTile(
                  title: Text('Products'),
                  leading: Icon(Icons.production_quantity_limits),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProductScreen(title: 'Products')),
                    );
                  },
                ),
                ListTile(
                  title: Text('Cart'),
                  leading: Icon(Icons.add_shopping_cart_sharp),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CartScreen(title: 'Carts')),
                    );
                  },
                ),
                ListTile(
                  title: Text('My Orders'),
                  leading: Icon(Icons.shopping_cart),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => OrderScreen(title: 'My Orders')),
                    );
                  },
                ),
                ListTile(
                  title: Text('Setting'),
                  leading: Icon(Icons.shopping_cart),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingScreen(title: 'Setting')),
                    );
                  },
                ),
                ListTile(
                  title: Text('Logout'),
                  leading: Icon(Icons.logout),
                  onTap: () {
                    Provider.of<AuthProvider>(context, listen: false).logout(context);
                  },
                ),

              ],
            );
          }
        },
      ),
    );
  }
}