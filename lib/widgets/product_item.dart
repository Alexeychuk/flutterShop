import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopApp/providers/auth.dart';
import '../providers/cart.dart';
import '../screens/product_detail_screen.dart';
import '../providers/product.dart';
import '../providers/products.dart';

class ProductItem extends StatelessWidget {
  // final String id;
  // final String title;
  // final String imageUrl;

  // ProductItem(this.id, this.title, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    // final product = Provider.of<Product>(context);
    final cart = Provider.of<Cart>(context, listen: false);
    final auth = Provider.of<Auth>(context, listen: false);
    final scaffold = Scaffold.of(context);
    return Consumer<Product>(
      builder: (ctx, product, child) => ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              arguments: product.id,
            );
          },
          child: GridTile(
            child: Hero(
              tag: product.id,
              child: FadeInImage(
                fit: BoxFit.cover,
                placeholder:
                    AssetImage('assets/images/product-placeholder.png'),
                image: NetworkImage(product.imageUrl),
              ),
            ),
            footer: GridTileBar(
              title: Text(
                product.title,
                textAlign: TextAlign.center,
              ),
              backgroundColor: Colors.black87,
              leading: IconButton(
                icon: Icon(product.isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border),
                onPressed: () async {
                  try {
                    await Provider.of<Product>(context, listen: false)
                        .toggleFavoriteStatus(auth.token, auth.userId);
                  } catch (_) {
                    print(_);
                    scaffold.showSnackBar(
                      SnackBar(
                        content: Text('Changing of status failed'),
                      ),
                    );
                  }
                },
                color: Theme.of(context).accentColor,
              ),
              trailing: IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  cart.addItem(product.id, product.price, product.title);
                  Scaffold.of(context).hideCurrentSnackBar();
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Added item to cart!',
                      ),
                      action: SnackBarAction(
                        label: 'UNDO',
                        onPressed: () {
                          cart.removeSingleItem(product.id);
                        },
                      ),
                      duration: Duration(
                        seconds: 2,
                      ),
                    ),
                  );
                },
                color: Theme.of(context).accentColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
