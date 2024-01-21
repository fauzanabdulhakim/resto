import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:restaurant/Helper/notification_helper.dart';
import 'package:restaurant/Page/favorite.dart';
import 'package:restaurant/Page/home.dart';
import 'package:restaurant/Page/setting.dart';
import 'package:restaurant/Helper/sharedPref_helper.dart';
import 'package:restaurant/Provider/detail_provider.dart';
import 'package:restaurant/Provider/favorite_provider.dart';
import 'package:restaurant/Provider/list_provider.dart';
import 'package:restaurant/Provider/search_provider.dart';
import 'package:restaurant/Provider/scheduling_provider.dart';
import 'package:restaurant/Provider/sharedPref_provider.dart';
import 'package:restaurant/Reminder/background_reminder.dart';
import 'package:restaurant/Service/Connectivity.dart';
import 'package:restaurant/splashscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final NotificationHelper notificationHelper = NotificationHelper();
  final BackgroundService service = BackgroundService();
  service.initIsolate();

  await AndroidAlarmManager.initialize();

  await notificationHelper.initNotification(flutterLocalNotificationsPlugin);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (_) => RestaurantProvider()),
        ChangeNotifierProvider(create: (_) => RestaurantDetailProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => SchedulingProvider()),
        ChangeNotifierProvider(
            create: (_) => SharedPrefProvider(
                sharedPrefHelper: SharedPrefHelper(
                    sharedPreference: SharedPreferences.getInstance()))),
      ],
      child: MaterialApp(
        home: SplashScreen(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    FavoritePage(),
    SettingsPage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favorite',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Pengaturan',
            ),
          ],
        ),
      ),
    );
  }
}
