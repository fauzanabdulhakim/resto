import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:restaurant/Helper/notification_helper.dart';
import 'package:restaurant/Provider/list_provider.dart';
import 'package:restaurant/Model/modelList.dart';
import 'package:restaurant/main.dart';

final ReceivePort port = ReceivePort();

class BackgroundService {
  static BackgroundService? _instance;
  static const String _isolateName = 'isolate';
  static SendPort? _uiSendPort;

  BackgroundService._internal() {
    _instance = this;
  }

  factory BackgroundService() => _instance ?? BackgroundService._internal();

  void initIsolate() {
    IsolateNameServer.registerPortWithName(
      port.sendPort,
      _isolateName,
    );
  }

  static Future<void> callback() async {
    debugPrint('Alarm fired!');

    final NotificationHelper notificationHelper = NotificationHelper();

    final RestaurantProvider _restaurantProvider = RestaurantProvider();
    await _restaurantProvider.fetchRestaurants(); 

    final List<Restaurant> restaurants = _restaurantProvider.restaurants;

    if (restaurants.isNotEmpty) {
      final int index = Random().nextInt(restaurants.length);
      final Restaurant randomRestaurant = restaurants[index];

      await notificationHelper.showNotification(
        flutterLocalNotificationsPlugin,
        randomRestaurant,
      );
    }

    _uiSendPort ??= IsolateNameServer.lookupPortByName(_isolateName);
    _uiSendPort?.send(null);
  }
}
