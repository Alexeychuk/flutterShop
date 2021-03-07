import 'package:flutter/material.dart';
import './product.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';

class Products with ChangeNotifier {
  List<Product> _items;

  final String token;
  final String userId;

  Products(this.token, this.userId, this._items);

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((product) => product.isFavorite).toList();
  }

  Future<void> fetchProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url =
        'https://flutter-shop-58cb3-default-rtdb.firebaseio.com/products.json?auth=$token&$filterString';
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      if (extractedData == null) return;
      url =
          'https://flutter-shop-58cb3-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$token';
      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          imageUrl: prodData['imageUrl'],
          isFavorite:
              favoriteData == null ? false : favoriteData[prodId] ?? false,
        ));
      });

      _items = loadedProducts;
      notifyListeners();
    } catch (err) {
      print(err);
      throw (err);
    }
  }

  Future<void> addProduct(Product product) async {
    final url =
        'https://flutter-shop-58cb3-default-rtdb.firebaseio.com/products.json?auth=$token';
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'creatorId': userId,
        }),
      );

      final newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (err) {
      throw err;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url =
          'https://flutter-shop-58cb3-default-rtdb.firebaseio.com/products/$id.json?auth=$token';
      await http.patch(
        url,
        body: json.encode({
          'title': newProduct.title,
          'price': newProduct.price,
          'description': newProduct.description,
          'imageUrl': newProduct.imageUrl,
        }),
      );
      _items[prodIndex] = newProduct;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://flutter-shop-58cb3-default-rtdb.firebaseio.com/products/$id.json?auth=$token';

    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();

    final response = await http.delete(url);

    //restore value if failed
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product');
    }
    existingProduct = null;
  }

  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }
}
