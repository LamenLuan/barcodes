import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../classes/shared_prefs_keys.dart';

class SelectCityPage extends StatefulWidget {
  const SelectCityPage({super.key, required this.searchRadius});

  final double searchRadius;

  @override
  State<SelectCityPage> createState() => _SelectCityPageState();
}

class _SelectCityPageState extends State<SelectCityPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late double _searchRadius;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchRadius = widget.searchRadius;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Configurar localização')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsetsGeometry.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Raio de busca'),
              Slider(
                label: '${_searchRadius.round()} km',
                value: _searchRadius,
                min: 1,
                max: 10,
                divisions: 9,
                onChanged: (double value) {
                  setState(() {
                    _searchRadius = value;
                  });

                  if (_debounce?.isActive ?? false) _debounce!.cancel();

                  _debounce = Timer(
                    const Duration(milliseconds: 1000),
                    () async {
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setDouble(
                        SharedPrefsKeys.searchRadius,
                        _searchRadius,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
