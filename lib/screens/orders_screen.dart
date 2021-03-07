import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../providers/orders.dart' show Orders;
import 'package:provider/provider.dart';
import '../widgets/orderItem.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Future _ordersFuture;

  Future _obtainFuture() {
    return Provider.of<Orders>(context, listen: false).fetchOrders();
  }

  @override
  void initState() {
    //we use that approach we do not refresh widget when something else change and no additional
    //http requests will be
    _ordersFuture = _obtainFuture();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //DO NOT use Provider in build IF in inside widget
    //is FutureBuilder  - there can be a loop, use consumer instead
    //final orderData = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
      ),
      body: FutureBuilder(
        future: _ordersFuture,
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            //handling error of Future
            if (dataSnapshot.error != null) {
              //.......handle error on screen
              return Center(
                child: Text('Error occured'),
              );
            } else {
              return Consumer<Orders>(
                builder: (ctx, orderData, child) => ListView.builder(
                  itemBuilder: (ctx, index) =>
                      OrderItem(orderData.orders[index]),
                  itemCount: orderData.orders.length,
                ),
              );
            }
          }
        },
      ),
      drawer: AppDrawer(),
    );
  }
}

//handle initial loading of data in statefull widget
//@override
// void initState() {
//without setState because this func starts before first build of widget
// _isLoading = true;

// Provider.of<Orders>(context, listen: false).fetchOrders().then((_) {
//   setState(() {
//     _isLoading = false;
//   });
// });
//super.initState();
//}

//another approach
// @override
// void didChangeDependencies() {
//   if (_isInit) {
//     setState(() {
//       _isLoading = true;
//     });
// Provider.of<Orders>(context).fetchOrders().then((_) {
//   setState(() {
//     _isLoading = false;
//   });
// });
//   }

//   _isInit = false;
//   super.didChangeDependencies();
// }
