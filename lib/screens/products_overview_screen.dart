import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/products.dart';

import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/widgets/badge.dart';
import 'package:shop_app/widgets/main_drawer.dart';
import 'package:shop_app/widgets/products_grid.dart';

enum FilterOptions {
  Favorites,
  All,
}

class ProductOverviewScreen extends StatefulWidget {
  @override
  State<ProductOverviewScreen> createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  bool _showFav = false;
  bool _isLoading = true;
  @override
  void initState() {
    // _isLoading = true;
    // Provider.of<Products>(context, listen: false).getProducts().then((value) {
    //   setState(() {
    //     _isLoading = false;
    //   });
    // });
    Future.delayed(Duration.zero).then((value) {
      Provider.of<Products>(context, listen: false).getProducts().then((value) {
        setState(() {
          _isLoading = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // print(_showFav);
    //final products = Provider.of<Products>(context, listen: false);
    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        title: const Text('MyShop'),
        actions: [
          PopupMenuButton(
            onSelected: (FilterOptions value) {
              //print('$value , $_showFav');
              setState(() {
                if (value == FilterOptions.Favorites) {
                  _showFav = true;
                } else {
                  _showFav = false;
                }
              });
            },
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              // ignore: prefer_const_constructors
              PopupMenuItem(
                child: Text('Only Favorites'),
                value: FilterOptions.Favorites,
              ),
              const PopupMenuItem(
                child: Text('Show All'),
                value: FilterOptions.All,
              ),
            ],
          ),
          Consumer<Cart>(
              builder: (context, cartItem, child) => Badge(
                  child: IconButton(
                    icon: Icon(Icons.shopping_cart),
                    onPressed: () =>
                        Navigator.of(context).pushNamed(CartScreen.route),
                  ),
                  value: cartItem.itemCount.toString(),
                  color: Colors.red))
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(_showFav),
    );
  }
}
