import 'dart:async';

import 'package:barcodes/classes/product_repository.dart';
import 'package:barcodes/components/product_card.dart';
import 'package:barcodes/components/search_input.dart';
import 'package:flutter/material.dart';

import '../classes/product.dart';
import 'card_form.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  String? nameFilter;
  Timer? _debounce;
  String? expandedCard;
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = ProductRepository.getProducts(nameFilter);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void onSearchInputChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        nameFilter = query;
        _productsFuture = ProductRepository.getProducts(nameFilter);
      });
    });
  }

  void onCardEditButtonPressed(Product product) async {
    final productName = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CardForm(
          formName: 'Editar produto',
          initialProductName: product.name,
          formValidator: (String? value) {
            if (value == null || value.isEmpty) {
              return 'O campo está vazio';
            }

            if (value.toUpperCase() == product.name) {
              return 'Nenhum alteração foi realizada';
            }

            return null;
          },
        ),
      ),
    );

    if (!mounted || productName == null || productName.isEmpty) return;

    product.name = productName;
    await ProductRepository.updateProduct(product);
    setState(() {});
  }

  void onCardDeleteButtonPressed(Product product) async {
    await ProductRepository.removeProduct(product);
    setState(() {
      _productsFuture = ProductRepository.getProducts(nameFilter);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: .start,
      children: [
        SearchInput(onChanged: onSearchInputChanged),
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

                  return ProductCard(
                    product: product,
                    isExpanded: expandedCard == product.barcode,
                    onEditButtonPressed: () => onCardEditButtonPressed(product),
                    onDeleteButtonPressed: () =>
                        onCardDeleteButtonPressed(product),
                    onCardLongPress: () {
                      setState(
                        () => expandedCard = expandedCard == product.barcode
                            ? null
                            : product.barcode,
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
