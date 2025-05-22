import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';
import 'auth_service.dart';

class SearchService {
  final http.Client _client = http.Client();
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>> getSearchOptions() async {
    // Update URL to match Django backend endpoint path
    final response = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/search/options/'),
      headers: {'Content-Type': 'application/json'},
    );

    print('Search options response status: ${response.statusCode}'); // Debug logging

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load search options: ${response.body}');
    }
  }
  Future<void> saveSearchHistory(
      String query, String copyrightFilter, bool transparentOnly) async {
    final token = await _authService.getToken();
    if (token == null) return;

    try {
      await _client.post(
        Uri.parse('${ApiConfig.baseUrl}/history/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: jsonEncode({
          'query': query,
          'filters': {
            'copyright_filter': copyrightFilter,
            'transparent_only': transparentOnly,
          }
        }),
      );
    } catch (e) {
      print('Failed to save search history: $e');
      // No need to throw, this is a non-critical operation
    }
  }
  Future<List<dynamic>> getSearchHistory() async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/history/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get search history: ${response.body}');
    }
  }
}
