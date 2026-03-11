import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

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
    // var response = http.get(
    //   Uri.parse('https://jsonplaceholder.typicode.com/albums/1'),
    // );
    var contents = await rootBundle.loadString('test.json');
    var result = await jsonDecode(contents);
    var products = result['produtos'];
    List<ProductInfo> productInfos = [];

    for (var product in products) {
      var store = product['estabelecimento'];

      var productInfo = ProductInfo(
        price: double.parse(product['valor']),
        date: DateTime.parse(product['datahora']),
        storeName: store['nm_emp'],
        storeAddress: getAddress(store),
      );

      productInfos.add(productInfo);
    }

    productInfos.sort((a, b) => a.price.compareTo(b.price));

    return productInfos;
  }

  @override
  void initState() {
    super.initState();
    _productsFuture = getProducts();
  }

  @override
  Widget build(BuildContext context) {
    var formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      appBar: AppBar(
        title: Text('Preços'),
        actions: [
          IconButton(onPressed: onLogoutPressed, icon: Icon(Icons.settings)),
        ],
      ),
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
                      return Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          children: [
                            Row(
                              spacing: 12,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(formatter.format(product.price)),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 2,
                                  children: [
                                    Text(product.storeName),
                                    Text(
                                      product.storeAddress,
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
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

  String getAddress(store) {
    var address = '';

    var name = store['nm_logr'];
    if (name == null) return address;

    var type = store['tp_logr'];
    if (type != null) address = '$type ';

    address += name;

    var number = store['nr_logr'];
    if (number != null) address += ', $number';

    var neighbourhood = store['bairro'];
    if (neighbourhood != null) address += ', $neighbourhood';

    return address;
  }

  void onLogoutPressed() {}
}
