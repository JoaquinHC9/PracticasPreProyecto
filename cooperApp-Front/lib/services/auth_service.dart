import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/login_model.dart';
import '../models/register_model.dart';
import '../config/constants.dart';

class AuthService {
  final String _baseUrl = AppConstants.backendBaseUrl;

  // Función de login
  Future<Map<String, dynamic>?> login(LoginModel loginModel) async {
    final url = Uri.parse('${_baseUrl}v1/auth/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': loginModel.username,
        'password': loginModel.password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Guardar accessToken en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['accessToken']);

      return data;
    } else {
      print('Error al hacer login: ${response.statusCode}');
      print(response.body);
      return null;
    }
  }

  // Función de registro
  Future<Map<String, dynamic>?> register(RegisterModel registerModel) async {
    final url = Uri.parse('${_baseUrl}v1/auth/register');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(registerModel.toJson()),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      print('Error al hacer registro: ${response.statusCode}');
      print(response.body);
      return null;
    }
  }

  // NUEVO: Función para cerrar sesión
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    print('Sesión cerrada: token eliminado');
  }
  Future<bool> sendResetCode(String email) async {
  final url = Uri.parse('${_baseUrl}v1/auth/reset-password/request');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({"email": email}),
  );

  if (response.statusCode == 200) {
    return true;
  } else {
    print(response.body);
    return false;
  }
}

// Confirmar nueva contraseña
Future<bool> confirmResetPassword({
  required String email,
  required String code,
  required String newPassword,
}) async {
  final url = Uri.parse('${_baseUrl}v1/auth/reset-password/confirm');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "email": email,
      "code": code,
      "newPassword": newPassword,
    }),
  );

  if (response.statusCode == 200) {
    return true;
  } else {
    print(response.body);
    return false;
  }
}

}
