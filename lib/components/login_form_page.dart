import 'package:barcodes/components/action_button.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../classes/product_repository.dart';
import '../classes/snack_bars.dart';
import 'main_page.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _textController = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void onButtonPressed() async {
      if (_formKey.currentState!.validate() == false) return;
      setState(() => loading = true);

      var connected = await ProductRepository.connectWithString(
        _textController.text,
      );

      if (context.mounted == false) {
        setState(() => loading = false);
        return;
      }

      if (connected == false) {
        SnackBars.showErrorSnackBar(context, 'String de conexão inválida');
        setState(() => loading = false);
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      prefs.setString('connectionString', _textController.text);
      setState(() => loading = false);

      if (context.mounted == false) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Acessar')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _textController,
                decoration: const InputDecoration(
                  hintText: 'String de conexão',
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'O campo está vazio';
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ActionButton(
                  onPressed: onButtonPressed,
                  loading: loading,
                  child: const Text('Acessar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
