import 'package:flutter/material.dart';

class SearchInput extends StatelessWidget {
  const SearchInput({super.key, required this.onChanged });

  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      decoration: const InputDecoration(hintText: 'Buscar produto por nome'),
    );
  }
}
