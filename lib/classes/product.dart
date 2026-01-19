import 'dart:convert';

class Product {
  Product({required this.name, required this.barcode});

  String name;
  final String barcode;

  factory Product.fromJson(Map<String, dynamic> json) =>
      Product(name: json['name'], barcode: json['_id']);

  static Product fromJsonString(String str) =>
      Product.fromJson(json.decode(str));

  Map<String, dynamic> toJson() => {'name': name, '_id': barcode};

  String toJsonString() => json.encode(toJson());
}
