import 'dart:io';

import 'package:barcodes/classes/product_repository.dart';
import 'package:barcodes/components/main_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/login_form_page.dart';

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static GlobalKey<ScaffoldMessengerState> snackBarKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barcodes',
      scaffoldMessengerKey: snackBarKey,
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    openNextPage();
  }

  void openNextPage() async {
    bool loginNeeded = true;
    final prefs = await SharedPreferences.getInstance();
    final connectionString = prefs.getString('connectionString');
    if (connectionString != null && connectionString.isNotEmpty) {
      var connected = await ProductRepository.connectWithString(
        connectionString,
      );
      if (connected) loginNeeded = false;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              loginNeeded ? const LoginForm() : const MainPage(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
