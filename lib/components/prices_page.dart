import 'dart:convert';

import 'package:barcodes/components/select_city_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../classes/product_info.dart';
import '../classes/shared_prefs_keys.dart';

class PricesPage extends StatefulWidget {
  const PricesPage({super.key, required this.barcode});

  final String barcode;

  @override
  State<PricesPage> createState() => _PricesPageState();
}

class _PricesPageState extends State<PricesPage> {
  late Future<List<ProductInfo>> _productsFuture;

  Future<List<ProductInfo>> getProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final cityHash = prefs.getString(SharedPrefsKeys.cityHash);

    if (cityHash == null || cityHash.isEmpty) return [];

    final response = await http.get(
      Uri.parse(
        'https://menorpreco.notaparana.pr.gov.br/api/v1/produtos?local=$cityHash&gtin=${widget.barcode}',
      ),
    );

    var result = await jsonDecode(response.body);
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
          IconButton(
            onPressed: onSettingsPressed,
            icon: Icon(Icons.edit_location_alt_outlined),
          ),
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

  void onSettingsPressed() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SelectCityPage()),
    );
    setState(() {
      _productsFuture = getProducts();
    });
  }
}
