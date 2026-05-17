import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationService {
  static Future<List<dynamic>> searchLocation(String query) async {
    if (query.isEmpty) return [];

    final encodedQuery = Uri.encodeComponent(query);

    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search'
      '?q=$encodedQuery'
      '&format=json'
      '&limit=10'
      '&countrycodes=id'
      '&addressdetails=1',
    );

    final response = await http.get(
      url,
      headers: {'User-Agent': 'aerodry-app'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load locations');
    }
  }

  static Future<String> reverseLocation(double lat, double lon) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse'
      '?lat=$lat&lon=$lon&format=json',
    );

    final response = await http.get(
      url,
      headers: {'User-Agent': 'aerodry-app'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['display_name'] ?? 'Current Location';
    }

    return 'Current Location';
  }
}
