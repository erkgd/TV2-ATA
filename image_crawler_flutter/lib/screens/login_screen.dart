import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;
  String? _error;
  String? _returnUrl;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if we were passed a return URL in the route arguments
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments != null && arguments is Map<String, dynamic>) {
      _returnUrl = arguments['returnRoute'];
    }
  }
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('Intentando login con usuario: ${_usernameController.text.trim()}');
      
      // Primero, probamos con el método raw para depurar
      final rawResult = await _authService.loginRaw(
        _usernameController.text.trim(),
        _passwordController.text,
      );
      
      print('Resultado login raw: $rawResult');
      
      // Si la respuesta es exitosa, usamos el método normal
      if (rawResult['status'] == 200) {
        print('Login exitoso, intentando obtener token...');
        
        await _authService.login(
          _usernameController.text.trim(),
          _passwordController.text,
        );
        
        print('Login completo, navegando...');
        
        // Navigate back or to home
        if (!mounted) return;        if (_returnUrl != null) {
          print('Navegando a ruta de retorno: $_returnUrl');
          // Usar pushNamedAndRemoveUntil para asegurarnos de limpiar la pila de navegación
          Navigator.of(context).pushNamedAndRemoveUntil(
            _returnUrl!,
            (route) => false, // Esto elimina todas las rutas anteriores
          );
        } else {
          print('Navegando a home');
          // Usar pushNamedAndRemoveUntil para asegurarnos de limpiar la pila de navegación
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/home',
            (route) => false, // Esto elimina todas las rutas anteriores
          );
        }
      } else {
        throw Exception('Login failed with status: ${rawResult['status']}');
      }
    } catch (e) {
      print('Login error completo: $e');
      setState(() {
        _error = 'Login failed. Please check your credentials.';
        _isLoading = false;
      });
      print('Login error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [                    Text(
                      'Welcome Back',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),                    Text(
                      'Sign in to your account to continue',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 32),
                    if (_error != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        color: Colors.red[50],
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red[700]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _error!,
                                style: TextStyle(color: Colors.red[700]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_error != null) const SizedBox(height: 16),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('LOGIN'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacementNamed('/register');
                          },
                          child: const Text('Register'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
