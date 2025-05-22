import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import '../utils/api_config.dart';
import 'auth_service.dart';

class ImageService {
  final http.Client _client = http.Client();
  final AuthService _authService = AuthService();

  Future<PaginatedResponse<ImageModel>> getAllImages({int page = 1, int limit = 20}) async {
    final response = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.images}/?page=$page&limit=$limit'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      return PaginatedResponse.fromJson(
        data, 
        (item) => ImageModel.fromJson(item),
      );
    } else {
      throw Exception('Failed to load images: ${response.body}');
    }
  }
  Future<ImageModel> getImageById(String id) async {
    final token = await _authService.getToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Token $token',
    };

    print('Getting image details for ID: $id'); // Debug logging
    print('Authorization header: ${token != null ? "Token present" : "No token"}'); // Debug logging

    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.images}/$id/'),
        headers: headers,
      ).timeout(const Duration(seconds: 15)); // Add timeout to prevent hanging requests
      
      print('Image detail response status: ${response.statusCode}'); // Debug logging
      
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          print('Image detail data: ${data.toString().substring(0, min(200, data.toString().length))}...'); // Debug logging (truncated)
          
          // Validate image URL to make sure it's accessible
          if (data['url'] != null) {
            final imageUrl = data['url'].toString();
            if (imageUrl.isEmpty || !Uri.parse(imageUrl).isAbsolute) {
              print('Warning: Image has invalid URL: $imageUrl');
              // Provide a default placeholder URL if the URL is invalid
              data['url'] = 'https://via.placeholder.com/800x600.png?text=Image+Not+Available';
            }
          }
          
          // Ensure comments is always an array even if it's null in the response
          if (data['comments'] == null) {
            data['comments'] = [];
          }
          
          // Ensure likes is always an array even if it's null in the response
          if (data['likes'] == null) {
            data['likes'] = [];
          }

          // If similar images have invalid URLs, provide placeholders
          if (data['similar_images'] != null) {
            for (var i = 0; i < data['similar_images'].length; i++) {
              final similarImage = data['similar_images'][i];
              if (similarImage['thumbnailUrl'] == null || 
                  similarImage['thumbnailUrl'].toString().isEmpty || 
                  !Uri.parse(similarImage['thumbnailUrl'].toString()).isAbsolute) {
                data['similar_images'][i]['thumbnailUrl'] = 
                    'https://via.placeholder.com/150x150.png?text=Thumbnail';
              }
            }
          }

          return ImageModel.fromJson(data);
        } catch (e) {
          print('Error parsing image detail JSON: $e'); // Debug logging
          throw Exception('Failed to parse image details: $e');
        }
      } else {
        print('Error response body: ${response.body}'); // Debug logging
        throw Exception('Failed to load image: ${response.statusCode}');
      }
    } catch (e) {
      print('Network error getting image: $e');
      throw Exception('Network error: Unable to load image. Please check your connection.');
    }
  }

  Future<ImageModel> createImage(Map<String, dynamic> imageData) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.images}/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
      body: jsonEncode(imageData),
    );

    if (response.statusCode == 201) {
      return ImageModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create image: ${response.body}');
    }
  }

  Future<ImageModel> updateImage(String id, Map<String, dynamic> imageData) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await _client.put(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.images}/$id/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
      body: jsonEncode(imageData),
    );

    if (response.statusCode == 200) {
      return ImageModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update image: ${response.body}');
    }
  }

  Future<void> deleteImage(String id) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await _client.delete(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.images}/$id/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete image: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> likeImage(String id) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.images}/$id/like/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
      body: jsonEncode({}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to like image: ${response.body}');
    }
  }

  Future<void> unlikeImage(String id) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await _client.delete(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.images}/$id/like/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to unlike image: ${response.body}');
    }
  }
  Future<CommentModel> addComment(String id, String text) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Not authenticated');

    print('Adding comment to image ID: $id'); // Debug logging
    
    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.images}/$id/comment/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
      body: jsonEncode({'text': text}),
    );

    print('Comment response status: ${response.statusCode}'); // Debug logging
    print('Comment response body: ${response.body}'); // Debug logging
    
    // Accept both 201 (Created) and 200 (OK) as valid responses
    if (response.statusCode == 201 || response.statusCode == 200) {
      try {
        return CommentModel.fromJson(jsonDecode(response.body));
      } catch (e) {
        print('Error parsing comment JSON: $e'); // Debug logging
        throw Exception('Failed to parse comment data: $e');
      }
    } else {
      throw Exception('Failed to add comment: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.users}/profile/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get user profile: ${response.body}');
    }
  }  Future<List<ImageModel>> getUserFavorites() async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Not authenticated');

    print('Getting user favorites'); // Debug logging

    try {
      // Using the ProfileAPIView endpoint which contains user's liked images
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.users}/profile/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      );

      print('User favorites response status: ${response.statusCode}'); // Debug logging

      if (response.statusCode == 200) {
        try {
          String responseBody = response.body;
          print('Raw response: ${responseBody.substring(0, min(500, responseBody.length))}...'); // Print first 500 chars
          
          // First validate the JSON is well-formed
          dynamic jsonData;
          try {
            jsonData = jsonDecode(responseBody);
            if (jsonData is! Map<String, dynamic>) {
              print('Error: Response is not a JSON object: ${jsonData.runtimeType}');
              return [];
            }
          } catch (e) {
            print('Error decoding JSON: $e');
            throw Exception('Invalid JSON response from server: $e');
          }
          
          Map<String, dynamic> data = jsonData;
          print('Data keys: ${data.keys.toList()}'); // Print all keys in the response
          
          // Extract liked_images from the profile response
          if (data.containsKey('liked_images')) {
            if (data['liked_images'] is List) {
              List<dynamic> likedImages = data['liked_images'];
              print('Found ${likedImages.length} liked images'); // Debug logging
              
              if (likedImages.isEmpty) {
                return []; // No favorites, return empty list
              }
              
              if (likedImages.isNotEmpty) {
                print('First liked image properties: ${likedImages.first is Map ? likedImages.first.keys.toList() : 'Not a map'}'); // Show structure
              }
              
              List<ImageModel> results = [];
              for (var item in likedImages) {
                try {
                  if (item is Map<String, dynamic>) {
                    results.add(ImageModel.fromJson(item));
                  } else {
                    print('Warning: Liked image item is not a map: ${item.runtimeType}');
                  }
                } catch (e) {
                  print('Error parsing individual liked image: $e for image: $item');
                  // Only add valid images
                }
              }
              
              return results;
            } else {
              print('liked_images is not a List, it is: ${data['liked_images'].runtimeType}');
              throw Exception('Invalid liked_images format: expected a List but got ${data['liked_images'].runtimeType}');
            }
          } else {
            print('No liked_images key in profile data');
            throw Exception('Profile data is missing liked_images field');
          }
        } catch (e) {
          print('Error processing user favorites: $e'); // Debug logging
          throw Exception('Failed to process user favorites: $e');
        }
      } else {
        print('Error response body: ${response.body}'); // Debug logging
        throw Exception('Failed to get user favorites: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Network or parsing error: $e');
      throw Exception('Error loading favorites: $e');
    }
  }

  Future<Map<String, dynamic>> searchImages(
      String query, {
      String? copyrightFilter,
      bool transparentOnly = false,
      int page = 1,
      int limit = 20,
    }) async {
    final Map<String, String> queryParams = {
      'query': query,
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (copyrightFilter != null && copyrightFilter.isNotEmpty) {
      queryParams['copyright_filter'] = copyrightFilter;
    }

    if (transparentOnly) {
      queryParams['transparent_only'] = 'true';
    }

    final Uri uri = Uri.parse('${ApiConfig.baseUrl}/advanced-search/').replace(
      queryParameters: queryParams,
    );

    print('Search URL: $uri'); // Debug logging

    final response = await _client.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    print('Search response status: ${response.statusCode}'); // Debug logging
    
    if (response.statusCode == 200) {
      // The backend returns a flat list of images, not a paginated response
      final List<dynamic> data = jsonDecode(response.body);
      print('Found ${data.length} images in search results'); // Debug logging
      
      // Convert the response into our paginated format
      return {
        'items': data,
        'pagination': {
          'total': data.length,
          'page': page,
          'pages': (data.length / limit).ceil(),
          'hasMore': data.length >= limit
        }
      };
    } else {
      throw Exception('Failed to search images: ${response.body}');
    }
  }
}
