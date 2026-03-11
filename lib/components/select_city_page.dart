import 'package:barcodes/classes/parana_cities_repository.dart';
import 'package:flutter/material.dart';

class SelectCityPage extends StatefulWidget {
  const SelectCityPage({super.key});

  @override
  State<SelectCityPage> createState() => _SelectCityPageState();
}

class _SelectCityPageState extends State<SelectCityPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final cityEntries = ParanaCitiesRepository.getCities()
      .map((city) => DropdownMenuItem(value: city, child: Text(city)))
      .toList();

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
              DropdownButton(items: cityEntries, onChanged: (String? value) {}),
            ],
          ),
        ),
      ),
    );
  }
}
