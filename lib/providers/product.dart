import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String? id;
  final String title;
  final String description;
  final String imageUrl;
  final double price;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.price,
    this.isFavorite = false,
  });

  Future<void> toggleFav(String? token, String userId) async {
    final oldState = isFavorite; //! for roll back on error
    isFavorite = !isFavorite;
    notifyListeners();
    final url = Uri.https(
        'mmmhwebapps-default-rtdb.asia-southeast1.firebasedatabase.app',
        '/userFavorites/$userId/$id.json',
        {'auth': token});
    try {
      final response = await http.put(url, body: json.encode(isFavorite));
      if (response.statusCode >= 400) {
        isFavorite = oldState;
        notifyListeners();
      }
    } on Exception catch (e) {
      isFavorite = oldState;
      notifyListeners();
    }
  }
}
