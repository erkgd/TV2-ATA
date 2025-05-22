import 'dart:convert';
// Comment out the secure storage for now
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../utils/api_config.dart';
import 'dart:developer' as developer;

class AuthService {
  final http.Client _client = http.Client();
  // Replace secure storage with shared preferences temporarily
  // final storage = const FlutterSecureStorage();
  final tokenKey = 'auth_token';

  Future<AuthResponse> register(String username, String password) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.auth}${ApiConfig.register}/');
    developer.log('Register request to: $url');
    final requestBody = jsonEncode({
      'username': username,
      'password': password,
    });
    
    try {
      final response = await _client.post(
        url,
        headers: ApiConfig.getHeaders(),
        body: requestBody,
      );

      developer.log('Register response code: ${response.statusCode}');
      developer.log('Register response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final authResponse = AuthResponse.fromJson(jsonDecode(response.body));
        await saveToken(authResponse.token);
        return authResponse;
      } else {
        throw Exception('Failed to register: Status ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      developer.log('Register error: $e', error: e);
      rethrow;
    }
  }
  Future<AuthResponse> login(String username, String password) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.auth}${ApiConfig.login}/');
    developer.log('Login request to: $url');
    
    // Creando un objeto Map en vez de jsonEncode directamente
    final Map<String, String> requestData = {
      'username': username,
      'password': password,
    };
    
    final requestBody = jsonEncode(requestData);
    developer.log('Request body: $requestBody');
    
    try {
      final response = await _client.post(
        url,
        headers: ApiConfig.getHeaders(),
        body: requestBody,
      );

      developer.log('Login response code: ${response.statusCode}');
      developer.log('Login response headers: ${response.headers}');
      developer.log('Login response body: ${response.body}');
      
      // Añadiendo mejor manejo de respuesta
      try {
        if (response.statusCode == 200) {
          // Verificar si el cuerpo está vacío
          if (response.body.isEmpty) {
            throw Exception('Server returned empty response body');
          }
          
          // Intentar parsear el JSON
          Map<String, dynamic> jsonData;
          try {
            jsonData = jsonDecode(response.body);
            developer.log('Parsed JSON data: $jsonData');
          } catch (e) {
            developer.log('JSON parse error: $e', error: e);
            throw FormatException('Could not parse server response as JSON: $e');
          }
          
          // Verificar que el token esté presente
          if (!jsonData.containsKey('token') && 
              !(jsonData.containsKey('auth') && jsonData['auth'] is Map) &&
              !(jsonData.containsKey('data') && jsonData['data'] is Map)) {
            developer.log('Token not found in response: $jsonData');
            throw Exception('Token not found in server response');
          }
          
          // Crear el objeto AuthResponse
          final authResponse = AuthResponse.fromJson(jsonData);
          
          // Verificar que el token no esté vacío
          if (authResponse.token.isEmpty) {
            throw Exception('Server returned empty token');
          }
          
          // Guardar el token
          await saveToken(authResponse.token);
          return authResponse;
        } else {
          // Intentar decodificar el mensaje de error
          String errorMessage = 'Failed to login: Status ${response.statusCode}';
          try {
            final errorJson = jsonDecode(response.body);
            if (errorJson['detail'] != null) {
              errorMessage += ', Error: ${errorJson['detail']}';
            }
          } catch (e) {
            // Si no se puede decodificar, usar el cuerpo de la respuesta tal cual
            errorMessage += ', Body: ${response.body}';
          }
          throw Exception(errorMessage);
        }
      } catch (e) {
        if (e is FormatException) {
          throw Exception('Failed to parse server response: ${e.message}');
        } else {
          rethrow;
        }
      }
    } catch (e) {
      developer.log('Login error: $e', error: e);
      rethrow;
    }
  }

  // Método para probar la conexión - útil para debug
  Future<bool> testConnection() async {
    try {
      developer.log('Testing connection to API server...');
      final url = Uri.parse('${ApiConfig.baseUrl}/status/');  // Endpoint ficticio
      
      final response = await _client.get(
        url,
        headers: ApiConfig.getHeaders(),
      ).timeout(const Duration(seconds: 5));
      
      developer.log('Connection test response: ${response.statusCode}');
      return response.statusCode < 500;  // Consideramos cualquier respuesta que no sea error del servidor
    } catch (e) {
      developer.log('Connection test failed: $e', error: e);
      return false;
    }
  }
    // Método alternativo de login con manejo de error más detallado
  Future<Map<String, dynamic>> loginRaw(String username, String password) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.auth}${ApiConfig.login}/');
    developer.log('Raw login request to: $url');
    
    final Map<String, String> requestData = {
      'username': username,
      'password': password,
    };
    
    try {
      // Primero verificar la conexión al servidor
      try {
        final testUrl = Uri.parse('${ApiConfig.baseUrl}/status/');
        final testResponse = await _client.get(testUrl).timeout(Duration(seconds: 5));
        developer.log('Server connection test: ${testResponse.statusCode}');
      } catch (e) {
        developer.log('Server connection test failed: $e');
      }
      
      developer.log('Sending raw login request...');
      developer.log('Request headers: ${ApiConfig.getHeaders()}');
      developer.log('Request body: ${jsonEncode(requestData)}');
      
      final response = await _client.post(
        url,
        headers: ApiConfig.getHeaders(),
        body: jsonEncode(requestData),
      ).timeout(Duration(seconds: 10));
      
      developer.log('Raw login response status: ${response.statusCode}');
      developer.log('Raw login response headers: ${response.headers}');
      developer.log('Raw login response body: ${response.body}');
      
      Map<String, dynamic> result = {
        'status': response.statusCode,
        'headers': response.headers,
        'body': response.body,
      };
      
      // Verificar si el body está vacío
      if (response.body.isEmpty) {
        developer.log('Warning: Response body is empty');
        result['warning'] = 'Response body is empty';
      } else {
        try {
          var jsonData = jsonDecode(response.body);
          result['parsedBody'] = jsonData;
          
          // Verificar la estructura del JSON recibido
          if (!jsonData.containsKey('token')) {
            result['warning'] = 'Response does not contain token field';
            developer.log('Warning: Response does not contain token field. Fields: ${jsonData.keys.toList()}');
          }
        } catch (e) {
          developer.log('Error parsing response body: $e');
          result['parseError'] = e.toString();
          
          // Intentar detectar qué formato tiene la respuesta
          if (response.body.contains('<!DOCTYPE html>')) {
            result['detectedFormat'] = 'HTML';
          } else if (response.body.startsWith('{') || response.body.startsWith('[')) {
            result['detectedFormat'] = 'Malformed JSON';
          } else {
            result['detectedFormat'] = 'Unknown';
          }
        }
      }
      
      return result;
    } catch (e) {
      developer.log('Raw login error: $e', error: e);
      return {
        'error': e.toString(),
        'status': -1,
        'isTimeout': e.toString().contains('TimeoutException'),
      };
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }

  Future<UserModel> getProfile() async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.users}/profile/'),
        headers: ApiConfig.getHeaders(token: token),
      );

      developer.log('Profile response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return UserModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to get profile: ${response.body}');
      }
    } catch (e) {
      developer.log('GetProfile error: $e', error: e);
      rethrow;
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  Future<void> saveToken(String token) async {
    print('Guardando token: ${token.substring(0, 5)}...');  // Solo muestra los primeros 5 caracteres por seguridad
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
    print('Token guardado correctamente');
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
  Future<UserModel> getCurrentUser() async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.users}/me/'),
        headers: ApiConfig.getHeaders(token: token),
      );

      developer.log('GetCurrentUser response status: ${response.statusCode}');
      developer.log('GetCurrentUser response body: ${response.body}');
      
      if (response.statusCode == 200) {
        try {
          // First check if body is empty
          if (response.body.isEmpty) {
            throw Exception('Empty response body from /api/users/me/');
          }
          
          // Try to parse the JSON
          final dynamic jsonData = jsonDecode(response.body);
          developer.log('GetCurrentUser parsed JSON: $jsonData');
          
          if (jsonData is! Map<String, dynamic>) {
            throw Exception('API returned invalid JSON format: $jsonData');
          }
          
          // If the response has minimal data, try to get more from the profile endpoint
          if (!jsonData.containsKey('email') && token != null) {
            developer.log('Limited user info, attempting to get full profile');
            try {
              final profileResponse = await _client.get(
                Uri.parse('${ApiConfig.baseUrl}${ApiConfig.users}/profile/'),
                headers: ApiConfig.getHeaders(token: token),
              );
              
              if (profileResponse.statusCode == 200) {
                final profileData = jsonDecode(profileResponse.body);
                if (profileData is Map<String, dynamic> && profileData.containsKey('user')) {
                  developer.log('Using user data from profile API instead');
                  return UserModel.fromJson(profileData['user']);
                }
              }
            } catch (profileError) {
              developer.log('Failed to get additional profile data: $profileError');
              // Continue with original data if profile lookup fails
            }
          }
          
          return UserModel.fromJson(jsonData);
        } catch (parseError) {
          developer.log('Error parsing user data: $parseError');
          throw Exception('Failed to parse user data: $parseError');
        }
      } else {
        throw Exception('Failed to get current user: Status ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      developer.log('GetCurrentUser error: $e', error: e);
      rethrow;
    }
  }
}
