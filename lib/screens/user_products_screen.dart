import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shop_app/providers/products.dart';
import 'package:shop_app/widgets/main_drawer.dart';
import 'package:shop_app/widgets/user_product.dart';

import 'edit_product_screen.dart';

class UserProdScreen extends StatelessWidget {
  static const route = '/userprod';
  Future<void>? _refresh(BuildContext context) async {
    await Provider.of<Products>(context, listen: false).getProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    //  final prodData = Provider.of<Products>(context); //? consumer used to avoid infinte loob
    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(EditProdScreen.route);
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: FutureBuilder(
        future: Provider.of<Products>(context, listen: false).getProducts(true),
        builder: (context, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      _refresh(context);
                    },
                    child: Consumer<Products>(
                      builder: (context, prodData, _) => Padding(
                        padding: const EdgeInsets.all(8),
                        child: ListView.builder(
                          itemBuilder: (context, index) => Column(
                            children: [
                              UserProd(
                                  id: prodData.items[index].id,
                                  title: prodData.items[index].title,
                                  imageUrl: prodData.items[index].imageUrl),
                              const Divider()
                            ],
                          ),
                          itemCount: prodData.items.length,
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
