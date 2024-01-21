import 'package:flutter/material.dart';
import 'package:restaurant/Model/modelList.dart';
import 'package:restaurant/Provider/detail_provider.dart';
import 'package:restaurant/Provider/list_provider.dart';
import 'package:restaurant/Page/detail.dart';
import 'package:restaurant/Page/search.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    Provider.of<RestaurantProvider>(context, listen: false).fetchRestaurants();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurant List'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchPage()),
              );
            },
          ),
        ],
      ),
      body: Consumer<RestaurantProvider>(
        builder: (context, restaurantProvider, child) {
          if (restaurantProvider.state == ProviderState.Loading) {
            return Center(child: CircularProgressIndicator());
          } else if (restaurantProvider.state == ProviderState.Error) {
            if (_isOffline) {
              return Center(
                child: Text('Terjadi kesalahan. Silakan coba lagi nanti.'),
              );
            } else {
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
            }
          } else {
            List<Restaurant> restaurants = restaurantProvider.restaurants;
            return ListView.builder(
              itemCount: restaurants.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          Provider.of<RestaurantDetailProvider>(context,
                                  listen: false)
                              .resetState();
                          return RestaurantDetailPage(
                            restaurants[index].id,
                            restaurants[index].name,
                          );
                        },
                      ),
                    );
                  },
                  child: ListTile(
                    leading: Hero(
                      tag: 'restaurantImage${restaurants[index].id}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6.0),
                        child: Image.network(
                          'https://restaurant-api.dicoding.dev/images/large/${restaurants[index].pictureId}',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    title: Text(restaurants[index].name),
                    subtitle: Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(restaurants[index].city),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
