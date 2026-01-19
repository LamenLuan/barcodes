import 'package:barcodes/classes/product.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';

class ProductRepository {
  static Db? _db;
  static late DbCollection _productCollection;

  static Future<DbCollection> get productCollection async {
    if (_db == null || !_db!.isConnected) await connect();
    return _productCollection;
  }

  static Future<void> connect() async {
    _db = await Db.create(dotenv.env['CONNECTION_STRING']!);
    await _db!.open(secure: true, tlsAllowInvalidCertificates: true);
    _productCollection = _db!.collection('Products');
  }

  static Future<List<Product>> getProducts(String? nameFilter) async {
    late List<Map<String, dynamic>> dataList;
    final collection = await productCollection;

    if (nameFilter != null && nameFilter.isNotEmpty) {
      dataList = await collection
          .find(where.match('name', nameFilter, caseInsensitive: true))
          .toList();
    } else {
      dataList = await collection.find().toList();
    }

    var products = dataList.map((e) => Product.fromJson(e)).toList();

    return products;
  }

  static Future<Product?> getProduct(String barcode) async {
    final collection = await productCollection;
    var json = await collection.findOne(where.eq('_id', barcode));

    if (json == null) return null;
    var product = Product.fromJson(json);
    return product;
  }

  static Future<void> updateProduct(Product product) async {
    final json = product.toJson();
    final collection = await productCollection;
    await collection.replaceOne(where.eq('_id', product.barcode), json);
  }

  static Future<void> removeProduct(Product product) async {
    final collection = await productCollection;
    await collection.remove(where.eq('_id', product.barcode));
  }

  static Future<void> addProduct(Product product) async {
    final collection = await productCollection;
    await collection.insertOne(product.toJson());
  }
}
