import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/orders.dart' show Orders;
import 'package:shop_app/widgets/main_drawer.dart';
import 'package:shop_app/widgets/order_item.dart'; //to solve naming conflict

class OrderScreen extends StatelessWidget {
  static const route = '/orders';

  //var _isloading = false;
  // @override
  // void initState() {
  //   //! as we using (listen : false) we dont need the double commented way
  //   // Future.delayed(Duration.zero).then((_) async {
  //   //   setState(() {
  //   _isloading = true;
  //   //    });
  //   //await
  //   Provider.of<Orders>(context, listen: false).getOrders().then((_) {
  //     setState(() {
  //       _isloading = false;
  //     });
  //   });
  //   // setState(() {
  //   //   _isloading = false;
  //   // });
  //   //  });

  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    //  print('Orders Screen');
    // final orderData = Provider.of<Orders>(context,listen: false); //! if not false it will not work
    //? will use consumer instead even this works fine
    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        title: const Text('Orders'),
      ),
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).getOrders(),
        // initialData: InitialData,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.error != null) {
            return const Center(
              child: Text('Error Occured'),
            );
          } else {
            return Consumer<Orders>(
              builder: (context, orderData, child) {
                return ListView.builder(
                  itemBuilder: (context, index) {
                    return OrderItem(order: orderData.orders[index]);
                  },
                  itemCount: orderData.orders.length,
                );
              },
            );
          }
        },
      ),
    );
  }
}
