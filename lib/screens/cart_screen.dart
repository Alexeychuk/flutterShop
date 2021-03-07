import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart' show Cart;
import '../widgets/cart_item.dart';
import '../providers/orders.dart';

class CartScreen extends StatefulWidget {
  static const routeName = '/cart';

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  var _isLoading = false;

  Future<void> handleOrder() async {
    final cart = Provider.of<Cart>(context, listen: false);
    try {
      setState(() {
        _isLoading = true;
      });

      await Provider.of<Orders>(context, listen: false).addOrder(
        cart.items.values.toList(),
        cart.totalAmount,
      );
      cart.clearCart();
    } catch (err) {
      print(err);
      await showDialog<Null>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(err.toString()),
          actions: [
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Ok'),
            )
          ],
        ),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: Column(
        children: <Widget>[
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  Spacer(),
                  Chip(
                    label: Text(
                      '\$${cart.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Theme.of(context).primaryTextTheme.title.color,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  TextButton(
                    child: _isLoading
                        ? CircularProgressIndicator()
                        : Text('ORDER NOW'),
                    onPressed: _isLoading || cart.totalAmount <= 0
                        ? null
                        : handleOrder,
                    style: TextButton.styleFrom(
                        primary: Theme.of(context).primaryColor),
                    //textColor: Theme.of(context).primaryColor,
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: cart.itemCount,
              itemBuilder: (ctx, i) {
                return CartItem(
                  productId: cart.items.keys.toList()[i],
                  id: cart.items.values.toList()[i].id,
                  price: cart.items.values.toList()[i].price,
                  title: cart.items.values.toList()[i].title,
                  quantity: cart.items.values.toList()[i].quantity,
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
