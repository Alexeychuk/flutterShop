import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/ProductsGrid.dart';
import '../widgets/badge.dart';
import '../providers/cart.dart';
import '../providers/products.dart';
import '../screens/cart_screen.dart';

enum FilterOptions {
  Favorites,
  All,
}

class ProductsOverviewScreen extends StatefulWidget {
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showOnlyFavorites = false;
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    //Provider.of<Products>(context, listen: false).fetchProducts();

    //#1
    //this is a hack, because you cant access context initially(but if set listen: false you can(i don`t know this))
    // Future.delayed(Duration.zero).then((_) {
    //   Provider.of<Products>(context).fetchProducts();
    // });
    super.initState();
  }

  //#2 - isInit allow to fetch data after initializing
  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });

      Provider.of<Products>(context).fetchProducts().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MyShop'),
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            itemBuilder: (_) => [
              PopupMenuItem(
                  child: Text('Only Favorites'),
                  value: FilterOptions.Favorites),
              PopupMenuItem(
                child: Text('Show All'),
                value: FilterOptions.All,
              ),
            ],
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.Favorites) {
                  _showOnlyFavorites = true;
                } else {
                  _showOnlyFavorites = false;
                }
              });
            },
          ),
          Consumer<Cart>(
            builder: (_, cartData, ch) => Badge(
              child: ch,
              value: cartData.itemCount.toString(),
            ),
            child: IconButton(
              icon: Icon(
                Icons.shopping_cart,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(_showOnlyFavorites),
      drawer: AppDrawer(),
    );
  }
}
