import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../screens/edit_product_screen.dart';
import '../widgets/user_product_item.dart';
import '../providers/products.dart';
import '../widgets/app_drawer.dart';

class UserProductsScreen extends StatelessWidget {
  static String routeName = './user-products';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false).fetchProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    //final productsData = Provider.of<Products>(context);
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text('Your products'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshProducts(context),
                    child: Consumer<Products>(
                      builder: (ctx, productsData, _) => Padding(
                        padding: EdgeInsets.all(8),
                        child: ListView.builder(
                          itemBuilder: (_, index) => Column(
                            children: [
                              UserProductItem(
                                imageUrl: productsData.items[index].imageUrl,
                                title: productsData.items[index].title,
                                id: productsData.items[index].id,
                              ),
                              Divider(),
                            ],
                          ),
                          itemCount: productsData.items.length,
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
