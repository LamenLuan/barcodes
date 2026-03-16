import 'package:barcodes/classes/shared_prefs_keys.dart';
import 'package:barcodes/components/products_page.dart';
import 'package:barcodes/components/scan_product_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../classes/product.dart';
import '../classes/product_repository.dart';
import 'login_form_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  void onLogoutPressed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SharedPrefsKeys.connectionString, '');

    if (mounted == false) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginForm()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Barcodes'),
        actions: [
          IconButton(onPressed: onLogoutPressed, icon: Icon(Icons.logout)),
        ],
      ),
      body: Padding(padding: const EdgeInsets.all(12), child: ProductsPage()),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Product? product = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ScanProductPage()),
          );

          if (product == null) return;
          ProductRepository.addProduct(product);
          setState(() {});
        },
        tooltip: 'Registrar',
        child: Icon(Icons.add),
      ),
    );
  }
}
