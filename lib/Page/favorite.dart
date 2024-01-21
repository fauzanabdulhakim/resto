import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant/Model/modelDetail.dart';
import 'package:restaurant/Provider/detail_provider.dart';
import 'package:restaurant/Provider/favorite_provider.dart';
import 'package:restaurant/Service/Connectivity.dart';
import 'package:restaurant/Page/detail.dart';

class FavoritePage extends StatefulWidget {
  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<Restaurant> favoriteRestaurants = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    Provider.of<FavoriteProvider>(context, listen: false)
        .fetchFavoriteRestaurants();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite'),
      ),
      body: Consumer<ConnectivityProvider>(
        builder: (context, model, child) {
          if (model.status == ConnectivityStatus.Offline) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Anda sedang offline.',
                    textAlign: TextAlign.center,
                  ),
                  Text('Silahkan hubungkan ke jaringan internet !!!')
                ],
              ),
            );
          } else {
            return Consumer<FavoriteProvider>(
              builder: (context, favoriteProvider, child) {
                if (favoriteProvider.isLoading) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return ListView.builder(
                    itemCount: favoriteProvider.favoriteRestaurants.length,
                    itemBuilder: (context, index) {
                      Restaurant restaurant =
                          favoriteProvider.favoriteRestaurants[index];
                      return ListTile(
                        title: Text(restaurant.name),
                        subtitle: Row(
                          children: [
                            Icon(Icons.star,
                                size: 16, color: Colors.yellow[800]),
                            SizedBox(width: 4),
                            Text(restaurant.rating.toString()),
                          ],
                        ),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            'https://restaurant-api.dicoding.dev/images/medium/${restaurant.pictureId}',
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        onTap: () async {
                          Provider.of<RestaurantDetailProvider>(context,
                                  listen: false)
                              .resetState();
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RestaurantDetailPage(
                                restaurant.id,
                                restaurant.name,
                              ),
                            ),
                          );
                          Provider.of<FavoriteProvider>(context, listen: false)
                              .fetchFavoriteRestaurants();
                        },
                        trailing: IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            Provider.of<FavoriteProvider>(context,
                                    listen: false)
                                .removeFavoriteRestaurant(restaurant);
                          },
                        ),
                      );
                    },
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}
