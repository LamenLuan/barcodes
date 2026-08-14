import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../classes/snack_bars.dart';
import '../main.dart';

class ScanProductPage extends StatefulWidget {
  const ScanProductPage({super.key});

  @override
  State<ScanProductPage> createState() => _ScanProductPageState();
}

class _ScanProductPageState extends State<ScanProductPage> {
  bool productDetected = false;
  Timer? _debounce;

  void manageErrorSnackBar(String message) {
    if (_debounce == null) {
      SnackBars.showErrorSnackBar(context, message, persist: true);
    }

    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(const Duration(seconds: 1), () {
      MyApp.snackBarKey.currentState?.hideCurrentSnackBar();
      _debounce = null;
    });

    setState(() => productDetected = false);
  }

  void onScannerDetection(BarcodeCapture barcodeCapture) async {
    if (productDetected) return;
    if (barcodeCapture.barcodes.isEmpty) return;
    var barcode = barcodeCapture.barcodes.first;

    if (barcode.type != BarcodeType.product || barcode.displayValue == null) {
      manageErrorSnackBar('Código EAN inválido');
      return;
    }

    // var product = await ProductRepository.getProduct(barcode.displayValue!);
    //
    // if (product != null) {
    //   manageErrorSnackBar('Código EAN já cadastrado');
    //   return;
    // }

    if (!mounted) return;
    setState(() => productDetected = true);

    // final productName = await Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => CardForm(
    //       formName: 'Registrar produto',
    //       formValidator: (String? value) {
    //         if (value == null || value.isEmpty) {
    //           return 'O campo está vazio';
    //         }
    //
    //         return null;
    //       },
    //     ),
    //   ),
    // );
    //
    // if (!mounted || productName == null || productName.isEmpty) {
    //   setState(() => productDetected = false);
    //   return;
    // }

    Navigator.pop(context, barcode.displayValue!);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    MyApp.snackBarKey.currentState?.hideCurrentSnackBar();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: MobileScanner(onDetect: onScannerDetection));
  }
}
