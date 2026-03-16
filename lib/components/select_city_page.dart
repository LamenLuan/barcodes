import 'dart:convert';

import 'package:barcodes/classes/parana_cities_repository.dart';
import 'package:barcodes/classes/shared_prefs_keys.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SelectCityPage extends StatefulWidget {
  const SelectCityPage({super.key});

  @override
  State<SelectCityPage> createState() => _SelectCityPageState();
}

class _SelectCityPageState extends State<SelectCityPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final cityEntries = ParanaCitiesRepository.getCities();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Selecione sua cidade')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsetsGeometry.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownSearch<String>(
                items: (filter, loadProps) => cityEntries,
                decoratorProps: DropDownDecoratorProps(
                  decoration: InputDecoration(
                    labelText: "Cidade",
                    hintText: "Digite para buscar",
                    border: OutlineInputBorder(),
                  ),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(
                      hintText: "Pesquisar cidade",
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                onChanged: (String? value) async {
                  if (value == null || value.isEmpty) return;

                  final response = await http.get(
                    Uri.parse(
                      'https://menorpreco.notaparana.pr.gov.br/mapa/search?regiao=$value',
                    ),
                  );

                  final result = await jsonDecode(response.body);
                  final cityHash = result[0]['geohash'];

                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString(SharedPrefsKeys.cityHash, cityHash);

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
