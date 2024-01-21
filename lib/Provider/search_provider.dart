import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:restaurant/Model/modelSearch.dart';

class SearchProvider extends ChangeNotifier {
  RestaurantSearch _searchResult = RestaurantSearch(
    error: false,
    founded: 0,
    restaurants: [],
  );
  bool _isLoading = false;

  RestaurantSearch get searchResult => _searchResult;
  bool get isLoading => _isLoading;

  Future<void> fetchSearchResults(String query) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('https://restaurant-api.dicoding.dev/search?q=$query'),
      );

      if (response.statusCode == 200) {
        _searchResult = RestaurantSearch.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load search results');
      }

      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _searchResult = RestaurantSearch(
        error: true,
        founded: 0,
        restaurants: [],
      );
      _isLoading = false;
      notifyListeners();
    }
  }
}
