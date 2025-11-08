import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../config/constants.dart';

class UserService {
  final String _baseUrl = AppConstants.backendBaseUrl;

  String? _getUidFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length == 3) {
        final payload = base64Url.decode(base64Url.normalize(parts[1]));
        final payloadMap = jsonDecode(utf8.decode(payload));
        return payloadMap['sub'];
      }
      return null;
    } catch (e) {
      print('Error al decodificar el token: $e');
      return null;
    }
  }

  Future<UserModel?> fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return null;

    final uid = _getUidFromToken(token);
    print("UID extraído del token: $uid"); // Debug

    if (uid == null) return null;

    final url = Uri.parse('${_baseUrl}v1/users/$uid');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data);
    } else {
      print('Error al obtener perfil: ${response.statusCode}');
      print(response.body); // Debug
      return null;
    }
  }
  Future<bool> updateUser(String email, String telefono) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return false;

    final uid = _getUidFromToken(token);
    if (uid == null) return false;

    final url = Uri.parse('${_baseUrl}v1/users/edit/$uid');

    final body = jsonEncode({
      "email": email,
      "telefono": telefono,
      "uid": uid,
    });

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    return response.statusCode == 200;
  }

  Future<UserModel?> getUserFromToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return null;

    final uid = _getUidFromToken(token); // mismo método para extraer UID
    if (uid == null) return null;

    final url = Uri.parse('${AppConstants.backendBaseUrl}v1/users/$uid');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data);
    } else {
      print('Error al obtener usuario: ${response.statusCode}');
      return null;
    }
  }

}
