import 'dart:isolate';
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

  final RestaurantProvider _restaurantProvider = RestaurantProvider();

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
    await notificationHelper.showNotification(
      flutterLocalNotificationsPlugin,
      _instance!._restaurantProvider.restaurants as ListRestaurant,
    );

    _uiSendPort ??= IsolateNameServer.lookupPortByName(_isolateName);
    _uiSendPort?.send(null);
  }
}
