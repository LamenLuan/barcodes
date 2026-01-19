import 'dart:io';

import 'package:barcodes/classes/product.dart';
import 'package:barcodes/classes/product_repository.dart';
import 'package:barcodes/components/scan_product_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'classes/snack_bars.dart';
import 'components/products_page.dart';

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  await dotenv.load(fileName: "config.env");
  runApp(const MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static GlobalKey<ScaffoldMessengerState> snackBarKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barcodes',
      scaffoldMessengerKey: snackBarKey,
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: MyHomePage(title: 'Barcodes'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(padding: const EdgeInsets.all(12), child: ProductsPage()),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Product? product = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ScanProductPage()),
          );

          if (context.mounted && product == null) {
            SnackBars.showErrorSnackBar(context, 'Nenhum produto encontrado');
            return;
          }

          ProductRepository.addProduct(product!);
          setState(() {});
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
