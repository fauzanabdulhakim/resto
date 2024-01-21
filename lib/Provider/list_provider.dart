import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:restaurant/Model/modelList.dart';

enum ProviderState { Loading, Error, Loaded }

class RestaurantProvider with ChangeNotifier {
  List<Restaurant> _restaurants = [];
  ProviderState _state = ProviderState.Loading;
  http.Client _client = http.Client(); 

  List<Restaurant> get restaurants => _restaurants;
  ProviderState get state => _state;

  void setClient(http.Client client) {
    _client = client;
  }

  Future<void> fetchRestaurants() async {
    try {
      final response = await _client.get(
        Uri.parse('https://restaurant-api.dicoding.dev/list'),
      );

      if (response.statusCode == 200) {
        final ListRestaurant listRestaurant =
            ListRestaurant.fromJson(json.decode(response.body));
        _restaurants = listRestaurant.restaurants;
        _state = ProviderState.Loaded;
      } else {
        _state = ProviderState.Error;
      }
    } catch (e) {
      _state = ProviderState.Error;
    }

    notifyListeners();
  }
}
