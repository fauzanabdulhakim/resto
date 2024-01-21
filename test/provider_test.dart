import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart%20';
import 'package:http/testing.dart';
import 'package:mockito/annotations.dart';
import 'package:restaurant/Model/modelList.dart';
import 'package:restaurant/Provider/list_provider.dart';

@GenerateMocks([http.Client])
void main() {
  group('Testing Restaurant Provider', () {
    test('if http call completes successfully, update state to Loaded',
        () async {
      final client = MockClient((request) async {
        final response = {
          "error": false,
          "message": "success",
          "count": 20,
          "restaurants": []
        };
        return Response(json.encode(response), 200);
      });

      final provider = RestaurantProvider();
      provider.setClient(client);

      await provider.fetchRestaurants();

      expect(provider.state, ProviderState.Loaded);
      expect(provider.restaurants, isA<List<Restaurant>>());
    });

    test('if http call fails, update state to Error', () async {
      final client = MockClient((request) async {
        return Response('Error', 500);
      });

      final provider = RestaurantProvider();
      provider.setClient(client);

      await provider.fetchRestaurants();

      expect(provider.state, ProviderState.Error);
      expect(provider.restaurants, isEmpty);
    });
  });
}
