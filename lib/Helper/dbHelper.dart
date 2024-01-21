import 'package:restaurant/Model/modelDetail.dart';
import 'package:restaurant/Provider/detail_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseProvider {
  DatabaseProvider._();
  static final DatabaseProvider db = DatabaseProvider._();
  Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await initDB();
    return _database;
  }

  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'restaurants.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE FavoriteRestaurants (
          id TEXT PRIMARY KEY,
          isFavorite INTEGER
        )
      ''');
    });
  }

  Future<Restaurant> fetchRestaurantById(String restaurantId) async {
    try {
      RestaurantDetailProvider detailProvider = RestaurantDetailProvider();
      await detailProvider.fetchRestaurantDetail(restaurantId);
      RestaurantDetail restaurantDetail = detailProvider.restaurantDetail;
      return restaurantDetail.restaurants;
    } catch (e) {
      throw Exception('Error fetching restaurant: $e');
    }
  }

  Future<void> toggleFavoriteStatus(
      String restaurantId, bool isFavorite) async {
    final db = await database;
    await db!.insert(
      'FavoriteRestaurants',
      {'id': restaurantId, 'isFavorite': isFavorite ? 1 : 0},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> isRestaurantFavorite(String restaurantId) async {
    final db = await database;
    var result = await db!.query(
      'FavoriteRestaurants',
      where: 'id = ?',
      whereArgs: [restaurantId],
    );
    return result.isNotEmpty ? result[0]['isFavorite'] == 1 : false;
  }

  Future<List<Restaurant>> getAllFavoriteRestaurants() async {
    final db = await database;
    var result = await db!.query('FavoriteRestaurants');

    if (result.isNotEmpty) {
      print('Mendapatkan restoran favorit dari database: $result');
      List<Restaurant> favoriteRestaurants = [];

      for (var res in result) {
        try {
          String id = res['id'].toString();
          Restaurant restaurant = await fetchRestaurantById(id);
          favoriteRestaurants.add(restaurant);
        } catch (e) {
          print('Error converting to Restaurant object: $e');
        }
      }
      return favoriteRestaurants;
    } else {
      print('Tidak ada restoran favorit dalam database');
      return [];
    }
  }

  Future<void> removeFavoriteRestaurant(String restaurantId) async {
    final db = await database;
    await db!.delete(
      'FavoriteRestaurants',
      where: 'id = ?',
      whereArgs: [restaurantId],
    );
  }
}
