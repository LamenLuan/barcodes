import 'package:flutter/material.dart';

import '../classes/product.dart';

class PricesPage extends StatefulWidget {
  const PricesPage({super.key, required this.barcode});

  final String barcode;

  @override
  State<PricesPage> createState() => _PricesPageState();
}

class _PricesPageState extends State<PricesPage> {
  late Future<List<Product>> _productsFuture;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Prices')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Expanded(
          child: FutureBuilder(
            future: _productsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Um erro ocorreu ao consultar os produtos'),
                );
              }
              if (snapshot.hasData == false || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'Nenhum produto encontrado...',
                    style: TextStyle(height: 8, fontSize: 16),
                  ),
                );
              }

              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var product = snapshot.data![index];
                  return Column();
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
