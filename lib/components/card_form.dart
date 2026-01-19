import 'package:flutter/material.dart';

class CardForm extends StatefulWidget {
  const CardForm({
    super.key,
    required this.formName,
    required this.formValidator,
    this.initialProductName,
  });

  final String formName;
  final String? initialProductName;
  final String? Function(String?) formValidator;

  @override
  State<CardForm> createState() => _CardFormState();
}

class _CardFormState extends State<CardForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _textController = TextEditingController(
    text: widget.initialProductName,
  );

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.formName)),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _textController,
                decoration: const InputDecoration(hintText: 'Nome do produto'),
                validator: widget.formValidator,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() == false) return;
                    Navigator.pop(context, _textController.text);
                  },
                  child: const Text('Salvar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
