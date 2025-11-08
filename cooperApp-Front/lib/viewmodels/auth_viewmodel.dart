import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  Future<void> logout(BuildContext context) async {
    await _authService.logout(); // Limpia sesión, token, etc.
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }
}
