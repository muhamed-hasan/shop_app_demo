import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shop_app/models/http_exception.dart';
import 'package:shop_app/providers/product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Products with ChangeNotifier {
  final String authToken;
  final String userId;
  Products(this.authToken, this._items, this.userId);

  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];
  // bool _showFav = false;
  List<Product> get items {
    //? if (_showFav) return _items.where((element) => element.isFavorite).toList();
    return [..._items];
  }

  List<Product> get favs {
    return _items.where((element) => element.isFavorite).toList();
    //? return [..._items];
  }

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> getProducts([bool filterBy = false]) async {
    var url = Uri.https(
        'mmmhwebapps-default-rtdb.asia-southeast1.firebasedatabase.app',
        '/products.json',
        {'auth': authToken});
    if (filterBy) {
      url = Uri.https(
          'mmmhwebapps-default-rtdb.asia-southeast1.firebasedatabase.app',
          '/products.json', {
        'auth': authToken,
        'orderBy': '"creatorId"',
        'equalTo': '"$userId"'
      });
    }

    try {
      final response = await http.get(url);
      //  print(response.body);
      final data = json.decode(response.body) as Map<String, dynamic>?;
      if (data == null) {
        return;
      }
      url = Uri.https(
          'mmmhwebapps-default-rtdb.asia-southeast1.firebasedatabase.app',
          '/userFavorites/$userId.json',
          {'auth': authToken});
      final favResponse = await http.get(url);
      final favData = json.decode(favResponse.body);
      final List<Product> loadedProducts = [];

      data.forEach((key, prodData) {
        loadedProducts.add(
          Product(
            id: key,
            title: prodData['title'],
            description: prodData['description'],
            imageUrl: prodData['imageUrl'],
            price: prodData['price'],
            isFavorite: favData == null ? false : favData[key] ?? false,
          ),
        );
      });
      _items = loadedProducts;
      notifyListeners();
    } on Exception catch (e) {
      //   throw (e);
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.https(
        'mmmhwebapps-default-rtdb.asia-southeast1.firebasedatabase.app',
        '/products.json',
        {'auth': authToken});
    try {
      final response = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'creatorId': userId
            // 'isFavorite': product.isFavorite,
          }));
      final newProduct = Product(
          id: json.decode(response.body)['name'],
          title: product.title,
          description: product.description,
          imageUrl: product.imageUrl,
          price: product.price);

      _items.add(newProduct);

      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateProd(String? id, Product newProd) async {
    final prodIndex = _items.indexWhere((element) => element.id == id);
    if (prodIndex >= 0) {
      final url = Uri.https(
          'mmmhwebapps-default-rtdb.asia-southeast1.firebasedatabase.app',
          '/products/$id.json',
          {'auth': authToken});
      await http.patch(url,
          body: json.encode({
            'title': newProd.title,
            'description': newProd.description,
            'imageUrl': newProd.imageUrl,
            'price': newProd.price
          }));
      _items[prodIndex] = newProd;
      notifyListeners();
    } else {
      print('invalid Id');
    }
  }

  Future<void> deleteProd(String id) async {
    final url = Uri.https(
        'mmmhwebapps-default-rtdb.asia-southeast1.firebasedatabase.app',
        '/products/$id.json',
        {'auth': authToken});
    final existingProdIndex = _items.indexWhere((element) => element.id == id);
    Product? existingProd =
        _items[existingProdIndex]; //? storing the product before deleting

    _items.removeAt(existingProdIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      //! rollback on error
      _items.insert(existingProdIndex, existingProd);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingProd = null;

    // _items.removeWhere((element) => element.id == id);
    // notifyListeners();
  }
}
