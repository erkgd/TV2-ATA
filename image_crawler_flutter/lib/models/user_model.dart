class UserModel {
  final String id;
  final String username;
  final String? email;
  final String? avatar;
  final String? createdAt;

  UserModel({
    required this.id,
    required this.username,
    this.email,
    this.avatar,
    this.createdAt,
  });
  factory UserModel.fromJson(Map<String, dynamic> json) {
    print('UserModel.fromJson raw data: $json'); // Debug logging
    
    // Handle potential user data nested in response
    Map<String, dynamic> userData = json;
    if (json.containsKey('user') && json['user'] is Map<String, dynamic>) {
      userData = json['user'];
      print('Found nested user data: $userData');
    }
    
    // Extract ID - could be string or int
    String userId = '';
    if (userData.containsKey('id')) {
      userId = userData['id'].toString();
    } else if (userData.containsKey('_id')) {
      userId = userData['_id'].toString();
    } else if (userData.containsKey('userId')) {
      userId = userData['userId'].toString();
    } else if (userData.containsKey('user_id')) {
      userId = userData['user_id'].toString();
    }
    
    // For username, try several common field names
    String username = userData['username'] ?? 
                     userData['name'] ?? 
                     userData['displayName'] ?? 
                     userData['userName'] ?? 
                     userData['user_name'] ?? 
                     'Unknown User';
    
    return UserModel(
      id: userId,
      username: username,
      email: userData['email'],
      avatar: userData['avatar'] ?? userData['profile_picture'] ?? userData['profilePicture'],
      createdAt: userData['created_at'] ?? userData['createdAt'] ?? userData['date_joined'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatar': avatar,
      'createdAt': createdAt,
    };
  }
}

class AuthResponse {
  final String id;
  final String username;
  final String token;

  AuthResponse({
    required this.id,
    required this.username,
    required this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Añadir log para debugging
    print('AuthResponse.fromJson raw data: $json');
    
    // Buscar token en diferentes ubicaciones posibles
    String? token = json['token'];
    if (token == null) {
      // Si no encuentra token directamente, buscar en sub-objetos comunes
      if (json['auth'] is Map) {
        token = json['auth']['token'];
      } else if (json['data'] is Map) {
        token = json['data']['token'];
      } else if (json['user'] is Map && json['user']['token'] != null) {
        token = json['user']['token'];
      }
    }

    // ID podría estar en varios formatos
    var id = '';
    if (json['id'] != null) {
      id = json['id'].toString();
    } else if (json['user_id'] != null) {
      id = json['user_id'].toString();
    } else if (json['userId'] != null) {
      id = json['userId'].toString();
    }

    return AuthResponse(
      id: id,
      username: json['username'] ?? '',
      token: token ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'token': token,
    };
  }
}

class SearchHistory {
  final String id;
  final String user;
  final String query;
  final SearchFilters filters;
  final String createdAt;

  SearchHistory({
    required this.id,
    required this.user,
    required this.query,
    required this.filters,
    required this.createdAt,
  });

  factory SearchHistory.fromJson(Map<String, dynamic> json) {
    return SearchHistory(
      id: json['id'] ?? '',
      user: json['user'] ?? '',
      query: json['query'] ?? '',
      filters: SearchFilters.fromJson(json['filters'] ?? {}),
      createdAt: json['created_at'] ?? json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'query': query,
      'filters': filters.toJson(),
      'createdAt': createdAt,
    };
  }
}

class SearchFilters {
  final String copyrightFilter;
  final bool transparentOnly;
  final bool? useApi;

  SearchFilters({
    required this.copyrightFilter,
    required this.transparentOnly,
    this.useApi,
  });

  factory SearchFilters.fromJson(Map<String, dynamic> json) {
    return SearchFilters(
      copyrightFilter: json['copyright_filter'] ?? json['copyrightFilter'] ?? '',
      transparentOnly: json['transparent_only'] ?? json['transparentOnly'] ?? false,
      useApi: json['use_api'] ?? json['useApi'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'copyrightFilter': copyrightFilter,
      'transparentOnly': transparentOnly,
      'useApi': useApi,
    };
  }
}
