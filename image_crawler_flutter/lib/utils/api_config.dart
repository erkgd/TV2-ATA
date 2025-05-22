class ApiConfig {
  // Para dispositivos Android, es necesario usar la IP 10.0.2.2 para acceder al localhost de la máquina host
  // Para dispositivos físicos, se debe usar la IP real de la máquina
  static const String baseUrl = 'http://10.0.2.2:3000/api'; // Para emuladores Android
  // static const String baseUrl = 'http://192.168.x.x:8000/api'; // Para dispositivos físicos (reemplazar con tu IP)
  // static const String baseUrl = 'http://localhost:8000/api'; // Para web

  // Endpoints
  static const String images = '/images';
  static const String users = '/users';
  static const String auth = '/users';
  static const String register = '/register';
  static const String login = '/login';
  
  // Header configs
  static Map<String, String> getHeaders({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Token $token';
    }
    
    return headers;
  }
}
