import 'package:flutter/cupertino.dart';
import 'package:shopApp/models/http_exception.dart';
import 'package:shopApp/providers/cart.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.dateTime,
    @required this.products,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders;

  final String token;
  final String userId;

  Orders(this.token, this.userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchOrders() async {
    final url =
        'https://flutter-shop-58cb3-default-rtdb.firebaseio.com/orders/$userId.json?auth=$token';
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      //notifyListeners()
      final List<OrderItem> loadedOrders = [];
      extractedData.forEach((orderId, orderData) {
        loadedOrders.add(OrderItem(
          id: orderId,
          amount: orderData['amount'],
          dateTime: DateTime.parse(orderData['dateTime']),
          products: (orderData['products'] as List<dynamic>)
              .map((prod) => CartItem(
                  id: prod['id'],
                  price: prod['price'],
                  title: prod['title'],
                  quantity: prod['quantity']))
              .toList(),
        ));
      });
      _orders = loadedOrders;
      notifyListeners();
    } catch (err) {
      throw err;
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url =
        'https://flutter-shop-58cb3-default-rtdb.firebaseio.com/orders/$userId.json?auth=$token';
    final timeStamp = DateTime.now();

    // final encodedCartProducts = jsonEncode(cartProducts);
    final response = await http.post(
      url,
      body: json.encode({
        'amount': total,
        'products': cartProducts
            .map((cp) => {
                  'id': cp.id,
                  'title': cp.title,
                  'quantity': cp.quantity,
                  'price': cp.price,
                })
            .toList(),
        'dateTime': timeStamp.toIso8601String(),
      }),
    );

    if (response.statusCode >= 400) {
      throw HttpException('Failed to add order');
    }

    _orders.insert(
        0,
        OrderItem(
          id: json.decode(response.body)['name'],
          amount: total,
          dateTime: timeStamp,
          products: cartProducts,
        ));
    notifyListeners();
  }
}
