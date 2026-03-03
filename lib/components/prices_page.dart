import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../classes/product_info.dart';

class PricesPage extends StatefulWidget {
  const PricesPage({super.key, required this.barcode});

  final String barcode;

  @override
  State<PricesPage> createState() => _PricesPageState();
}

class _PricesPageState extends State<PricesPage> {
  late Future<List<ProductInfo>> _productsFuture;

  Future<List<ProductInfo>> getProducts() async {
    var contents = await rootBundle.loadString('test.json');
    var result = jsonDecode(contents);
    var produtos = result['produtos'];
    List<ProductInfo> productInfos = [];

    for (var produto in produtos) {
      var store = produto['estabelecimento'];
      var productInfo = ProductInfo(
        name: produto['desc'],
        price: double.parse(produto['valor']),
        date: DateTime.parse(produto['datahora']),
        storeName: store['nm_emp'],
        storeAddress:
            '${store['tp_logr']} ${store['nm_logr']},'
            ' ${store['nr_logr']}, ${store['complemento']}',
      );

      productInfos.add(productInfo);
    }

    return productInfos;
  }

  @override
  void initState() {
    super.initState();
    _productsFuture = getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Prices')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
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
                      return Column(children: [Text(product.name)]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
