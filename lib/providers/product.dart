import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';
import 'dart:convert';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  void toggleFavoriteStatus(String token, String userId) async {
    final prevIsFavoriteValue = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();

    final url =
        'https://flutter-shop-58cb3-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$token';

    try {
      final response = await http.put(
        url,
        body: json.encode(
          isFavorite,
        ),
      );
      if (response.statusCode >= 400) {
        isFavorite = prevIsFavoriteValue;
        notifyListeners();
        throw HttpException('Could not change favorite status of the product');
      }
    } catch (err) {
      isFavorite = prevIsFavoriteValue;
      notifyListeners();
      throw err;
    }
  }
}
