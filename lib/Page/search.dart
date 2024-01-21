import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant/Provider/detail_provider.dart';
import 'package:restaurant/Service/Connectivity.dart';
import 'package:restaurant/Page/detail.dart';
import '../Model/modelSearch.dart';
import '../Provider/search_provider.dart';

class SearchPage extends StatelessWidget {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                border: InputBorder.none,
              ),
              onSubmitted: (value) =>
                  _performSearch(context, searchProvider, value),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  if (_searchController.text.isEmpty) {
                    _showEmptyTextFieldDialog(context);
                  } else {
                    if (Provider.of<ConnectivityProvider>(context,
                                listen: false)
                            .status ==
                        ConnectivityStatus.Offline) {
                      _showOfflineDialog(context);
                    } else {
                      _handleSearch(context, searchProvider);
                    }
                  }
                },
              ),
            ],
          ),
          body: _buildBody(context, searchProvider),
        );
      },
    );
  }

  void _performSearch(
      BuildContext context, SearchProvider searchProvider, String query) {
    try {
      searchProvider.fetchSearchResults(query);
    } catch (error) {
      _showErrorDialog(context, error.toString());
    }
  }

  void _handleSearch(BuildContext context, SearchProvider searchProvider) {
    try {
      _performSearch(context, searchProvider, _searchController.text);
    } catch (error) {
      _showErrorDialog(context, error.toString());
    }
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, SearchProvider searchProvider) {
    final searchResult = searchProvider.searchResult;

    return Consumer<ConnectivityProvider>(
      builder: (context, connectivityProvider, child) {
        if (connectivityProvider.status == ConnectivityStatus.Offline &&
            (searchResult.restaurants.isEmpty)) {
          return _buildOfflineView(context, searchProvider);
        } else {
          return searchProvider.isLoading
              ? Center(child: CircularProgressIndicator())
              : _buildSearchResults(searchResult);
        }
      },
    );
  }

  Widget _buildOfflineView(
      BuildContext context, SearchProvider searchProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Kamu sedang offline.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(RestaurantSearch? searchResult) {
    final restaurants = searchResult?.restaurants ?? [];
    if (_searchController.text.isNotEmpty && restaurants.isEmpty) {
      return Center(
        child: Text('Kafe yang kamu cari tidak tersedia.'),
      );
    }

    return ListView.builder(
      itemCount: restaurants.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  Provider.of<RestaurantDetailProvider>(context, listen: false)
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
                  'https://restaurant-api.dicoding.dev/images/medium/${restaurants[index].pictureId}',
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

  void _showEmptyTextFieldDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Peringatan'),
          content: Text('Silahkan masukkan nama kafe terlebih dahulu.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showOfflineDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Peringatan'),
          content: Text('Kamu sedang offline.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
