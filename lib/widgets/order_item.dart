import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/orders.dart'
    as ord; //because we have 2 classes with same name"OrderItem"

class OrderItem extends StatefulWidget {
  final ord.OrderItem order;

  OrderItem({required this.order});

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: !_expanded ? min(210, widget.order.products.length * 42.0) : 195,
      child: Card(
        margin: EdgeInsets.all(10),
        child: Column(
          children: [
            ListTile(
              title: Text('\$${widget.order.amount}'),
              subtitle: Text(
                  DateFormat('dd-MM-yyyy hh:mm').format(widget.order.dateTime)),
              trailing: IconButton(
                  onPressed: () {
                    setState(() {});
                    _expanded = !_expanded;
                  },
                  icon: _expanded
                      ? Icon(Icons.expand_less)
                      : Icon(Icons.expand_more)),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              //    child: Widget(),
              height:
                  _expanded ? min(200, widget.order.products.length * 40.0) : 0,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              child: ListView(
                  children: widget.order.products
                      .map(
                        (prod) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              prod.title,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              prod.price.toString(),
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList()),
            )
          ],
        ),
      ),
    );
  }
}
