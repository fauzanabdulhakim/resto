import 'package:flutter/cupertino.dart';
import 'package:restaurant/Helper/sharedPref_helper.dart';

class SharedPrefProvider extends ChangeNotifier {
  SharedPrefHelper sharedPrefHelper;

  SharedPrefProvider({required this.sharedPrefHelper}) {
    _getDailyActive();
  }

  bool _isDailyActive = false;
  bool get isDailyActive => _isDailyActive;

  void _getDailyActive() async {
    _isDailyActive = await sharedPrefHelper.isDailyRestaurantActive;
    notifyListeners();
  }

  void enableDailyActive(bool value) {
    sharedPrefHelper.setDailyRestaurant(value);
    _getDailyActive();
  }
}
