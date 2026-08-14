import 'package:barcodes/classes/shared_prefs_keys.dart';
import 'package:barcodes/components/prices_page.dart';
import 'package:barcodes/components/products_page.dart';
import 'package:barcodes/components/scan_product_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../classes/product.dart';
import '../classes/product_repository.dart';
import 'card_form.dart';
import 'login_form_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<ProductsPageState> _productsKey = GlobalKey();

  void onLogoutPressed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SharedPrefsKeys.connectionString, '');

    if (mounted == false) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginForm()),
    );
  }

  Future<void> openPricesPage(String productCode) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PricesPage(barcode: productCode)),
    );
  }

  Future<Product?> registerProduct(String productCode) async {
    final productName = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CardForm(
          formName: 'Registrar produto',
          formValidator: (String? value) {
            if (value == null || value.isEmpty) {
              return 'O campo está vazio';
            }

            return null;
          },
        ),
      ),
    );

    return Product(barcode: productCode, name: productName);
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
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ProductsPage(_productsKey),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String productCode = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ScanProductPage()),
          );

          var product = await ProductRepository.getProduct(productCode);
          if (!context.mounted) return;
          var productFound = product != null;

          await showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(getBottomSheetText(productFound, product?.name)),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: getBottomSheetButtons(
                        productFound,
                        productCode,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          );
        },
        tooltip: 'Escanear',
        child: Icon(Icons.camera_alt),
      ),
    );
  }

  String getBottomSheetText(bool productFound, String? productName) {
    return productFound
        ? 'Produto detectado: ${productName!}'
        : 'Gostaria de cadastrar o produto ou apenas consultar os preços?';
  }

  List<Widget> getBottomSheetButtons(bool productFound, String productCode) {
    if (productFound) {
      return [
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            await openPricesPage(productCode);
          },
          child: const Text('Consultar preços'),
        ),
      ];
    }

    return [
      ElevatedButton(
        onPressed: () async {
          Navigator.pop(context);
          await openPricesPage(productCode);
        },
        child: const Text('Consultar preços'),
      ),
      ElevatedButton(
        onPressed: () async {
          Navigator.pop(context);
          var product = await registerProduct(productCode);
          if (product == null) return;
          await ProductRepository.addProduct(product);
          _productsKey.currentState?.refresh();
        },
        child: const Text('Cadastrar produto'),
      ),
    ];
  }
}
