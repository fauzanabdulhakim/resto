import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:restaurant/Helper/dbHelper.dart';
import 'package:restaurant/Service/Connectivity.dart';
import '../Model/modelDetail.dart';
import '../Provider/detail_provider.dart';

class RestaurantDetailPage extends StatefulWidget {
  final String restaurantId;
  final String restaurantName;

  RestaurantDetailPage(this.restaurantId, this.restaurantName);

  @override
  _RestaurantDetailPageState createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkIsFavorite();

    Provider.of<RestaurantDetailProvider>(context, listen: false)
        .fetchRestaurantDetail(widget.restaurantId);
  }

  Future<void> _checkIsFavorite() async {
    bool favorite =
        await DatabaseProvider.db.isRestaurantFavorite(widget.restaurantId);
    setState(() {
      isFavorite = favorite;
    });
  }

  Future<void> _removeFavoriteStatus() async {
    try {
      await DatabaseProvider.db.removeFavoriteRestaurant(widget.restaurantId);
      setState(() {
        isFavorite = false;
      });
      print('Status favorit berhasil dihapus');
    } catch (e) {
      print('Gagal menghapus status favorit: $e');
    }
  }

  Future<void> _toggleFavoriteStatus() async {
    if (isFavorite) {
      await _removeFavoriteStatus();
    } else {
      setState(() {
        isFavorite = !isFavorite;
      });

      try {
        await DatabaseProvider.db
            .toggleFavoriteStatus(widget.restaurantId, isFavorite);
        print('Status favorit berhasil diperbarui: $isFavorite');
      } catch (e) {
        print('Gagal mengubah status favorit: $e');
      }
    }
  }

  Future<void> sendReview(
      String name, String review, BuildContext context) async {
    final response = await http.post(
      Uri.parse('https://restaurant-api.dicoding.dev/review'),
      body: jsonEncode({
        'id': widget.restaurantId,
        'name': name,
        'review': review,
      }),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add review. Please try again later.'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Review added successfully'),
          duration: Duration(seconds: 2),
        ),
      );
      await Provider.of<RestaurantDetailProvider>(context, listen: false)
          .fetchRestaurantDetail(widget.restaurantId);
    }
  }

  Future<void> addReview(BuildContext context) async {
    String name = '';
    String review = '';

    try {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                title: Text('Add Review'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      decoration: InputDecoration(labelText: 'Your Name'),
                      onChanged: (value) {
                        setState(() {
                          name = value;
                        });
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Your Review'),
                      onChanged: (value) {
                        setState(() {
                          review = value;
                        });
                      },
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('Submit'),
                    onPressed: () async {
                      try {
                        await sendReview(name, review, context);
                        Navigator.of(context).pop();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Anda sedang offline.'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                  ),
                ],
              );
            },
          );
        },
      );
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(widget.restaurantName),
            Spacer(),
            IconButton(
              onPressed: () async {
                await _toggleFavoriteStatus();
                setState(() {});
              },
              tooltip: 'Favorite',
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : null,
              ),
            ),
          ],
        ),
      ),
      body: Consumer<RestaurantDetailProvider>(
        builder: (context, restaurantDetailProvider, child) {
          if (restaurantDetailProvider.state == ProviderStateDetail.Loading) {
            return Center(child: CircularProgressIndicator());
          } else if (restaurantDetailProvider.state ==
              ProviderStateDetail.Error) {
            return Consumer<ConnectivityProvider>(
              builder: (context, model, child) {
                if (model.status == ConnectivityStatus.Offline) {
                  return Scaffold(
                    body: Center(
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
                    ),
                  );
                } else {
                  return Center(
                    child: Text(
                      'Gagal memuat data restoran. Silakan coba lagi.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }
              },
            );
          } else {
            RestaurantDetail restaurantDetail =
                restaurantDetailProvider.restaurantDetail;

            return SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'restaurantImage${restaurantDetail.restaurants.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        'https://restaurant-api.dicoding.dev/images/medium/${restaurantDetail.restaurants.pictureId}',
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Rating: ${restaurantDetail.restaurants.rating.toString()}',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    '${restaurantDetail.restaurants.address}, ${restaurantDetail.restaurants.city}',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'Categories:',
                    style: TextStyle(fontSize: 16),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: restaurantDetail.restaurants.categories
                        .map((category) => Card(
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Text(category.name),
                              ),
                            ))
                        .toList(),
                  ),
                  const Divider(
                    color: Colors.grey,
                    thickness: 1,
                  ),
                  Text(
                    ' ${restaurantDetail.restaurants.description}',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  const Divider(
                    color: Colors.grey,
                    thickness: 1,
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'Menu ',
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text('Foods:', style: TextStyle(fontSize: 16.0)),
                              const SizedBox(height: 8.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: restaurantDetail
                                    .restaurants.menus.foods
                                    .map((food) => Text('- ${food.name}',
                                        style: const TextStyle(fontSize: 16.0)))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 18.0),
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              const Text('Drinks:',
                                  style: TextStyle(fontSize: 16.0)),
                              const SizedBox(height: 8.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: restaurantDetail
                                    .restaurants.menus.drinks
                                    .map((drink) => Text('- ${drink.name}',
                                        style: const TextStyle(fontSize: 16.0)))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  const Divider(
                    color: Colors.grey,
                    thickness: 1,
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'Reviews :',
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: restaurantDetail.restaurants.customerReviews
                        .map((review) => Card(
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Name: ${review.name}',
                                        style: const TextStyle(fontSize: 16.0)),
                                    Text('Review: ${review.review}',
                                        style: const TextStyle(fontSize: 16.0)),
                                    Text('Date: ${review.date}',
                                        style: const TextStyle(fontSize: 16.0)),
                                  ],
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addReview(context);
        },
        tooltip: 'Add Review',
        child: Icon(Icons.reviews),
      ),
    );
  }
}
