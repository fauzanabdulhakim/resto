import 'package:flutter/foundation.dart';
import 'package:restaurant/Helper/dbHelper.dart';
import 'package:restaurant/Model/modelDetail.dart';

class FavoriteProvider extends ChangeNotifier {
  List<Restaurant> _favoriteRestaurants = [];
  bool _isLoading = false;

  List<Restaurant> get favoriteRestaurants => _favoriteRestaurants;
  bool get isLoading => _isLoading;

  Future<void> fetchFavoriteRestaurants() async {
    _isLoading = true;

    try {
      List<Restaurant> favorites =
          await DatabaseProvider.db.getAllFavoriteRestaurants();
      _favoriteRestaurants = favorites;
    } catch (e) {
      print('Kesalahan saat mengambil restoran favorit: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> removeFavoriteRestaurant(Restaurant restaurant) async {
    await DatabaseProvider.db.removeFavoriteRestaurant(restaurant.id);
    await fetchFavoriteRestaurants();

    notifyListeners();
  }
}
