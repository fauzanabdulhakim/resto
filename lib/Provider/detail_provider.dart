import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:restaurant/Model/modelDetail.dart';

enum ProviderStateDetail { Loading, Error, Loaded }

class RestaurantDetailProvider with ChangeNotifier {
  ProviderStateDetail _state = ProviderStateDetail.Loading;
  RestaurantDetail _restaurantDetail = RestaurantDetail(
    error: false,
    message: '',
    restaurants: Restaurant(
      id: '',
      name: '',
      description: '',
      city: '',
      address: '',
      pictureId: '',
      categories: [],
      menus: Menus(foods: [], drinks: []),
      rating: 0.0,
      customerReviews: [],
    ),
  );

  ProviderStateDetail get state => _state;
  RestaurantDetail get restaurantDetail => _restaurantDetail;

  void resetState() {
    _state = ProviderStateDetail.Loading;
    _restaurantDetail = RestaurantDetail(
      error: false,
      message: '',
      restaurants: Restaurant(
        id: '',
        name: '',
        description: '',
        city: '',
        address: '',
        pictureId: '',
        categories: [],
        menus: Menus(foods: [], drinks: []),
        rating: 0.0,
        customerReviews: [],
      ),
    );
  }

  Future<void> fetchRestaurantDetail(String restaurantId) async {
    try {
      final response = await http.get(Uri.parse(
          'https://restaurant-api.dicoding.dev/detail/$restaurantId'));

      if (response.statusCode == 200) {
        final fetchedDetail =
            RestaurantDetail.fromJson(json.decode(response.body));
        _restaurantDetail = fetchedDetail;
        _state = ProviderStateDetail.Loaded;
      } else {
        _state = ProviderStateDetail.Error;
      }
    } catch (e) {
      _state = ProviderStateDetail.Error;
    }

    notifyListeners();
  }
}
