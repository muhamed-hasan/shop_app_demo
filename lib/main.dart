import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/auth_screen.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/screens/orders_screen.dart';
import 'package:shop_app/screens/product_detail_screen.dart';
import 'package:shop_app/screens/products_overview_screen.dart';
import 'package:shop_app/screens/splash_screen.dart';
import 'package:shop_app/screens/user_products_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          //   ChangeNotifierProvider(create: (context) => Products()),
          ChangeNotifierProvider(create: (context) => Cart()),
          //ChangeNotifierProvider(create: (context) => Orders()),
          ChangeNotifierProvider(create: (context) => Auth()),
          ChangeNotifierProxyProvider<Auth, Orders>(
            create: (context) {
              return Orders([], '', '');
            },
            update: (context, auth, previous) {
              return Orders(previous == null ? [] : previous.orders,
                  auth.token ?? '', auth.userId);
            },
          ),
          ChangeNotifierProxyProvider<Auth, Products>(
            update: (context, auth, previousProd) => Products(auth.token ?? '',
                previousProd == null ? [] : previousProd.items, auth.userId),
            create: (context) {
              return Products('', [], '');
            },
          )
        ],
        child: Consumer<Auth>(
          builder: (context, auth, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'ShopApp',
              theme: ThemeData(
                  primarySwatch: Colors.purple,
                  colorScheme: ColorScheme.fromSwatch().copyWith(
                    secondary: Colors.deepOrange,
                  ),
                  fontFamily: 'Lato'
                  // accentColor: Colors.amber
                  ),
              // home: ProductOverviewScreen(),
              home: auth.isAuth
                  ? ProductOverviewScreen()
                  : FutureBuilder(
                      future: auth.tryLogin(),
                      // initialData: InitialData,
                      builder: (ctx, snapshot) {
                        // auth.tryLogin();
                        return snapshot.connectionState ==
                                ConnectionState.waiting
                            ? SplashScreen()
                            : AuthScreen();
                      },
                    ),
              routes: {
                ProductDetailSccreen.route: (ctx) => ProductDetailSccreen(),
                CartScreen.route: (ctx) => CartScreen(),
                OrderScreen.route: (ctx) => OrderScreen(),
                UserProdScreen.route: (ctx) => UserProdScreen(),
                EditProdScreen.route: (ctx) => EditProdScreen(),
                AuthScreen.route: (ctx) => AuthScreen(),
              },
            );
          },
        ));
  }
}
