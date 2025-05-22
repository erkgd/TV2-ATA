import 'package:flutter/material.dart';
import '../screens/screens.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen(), settings: settings);
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      default:
        // Handle dynamic routes
        if (settings.name?.startsWith('/image/') ?? false) {
          final imageId = settings.name!.replaceFirst('/image/', '');
          return MaterialPageRoute(
            builder: (_) => ImageDetailScreen(imageId: imageId),
          );
        }
        
        // Default 404 page
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Page Not Found')),
            body: const Center(
              child: Text('The page you requested was not found.'),
            ),
          ),
        );
    }
  }
}
