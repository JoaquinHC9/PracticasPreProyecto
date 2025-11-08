import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/input_features.dart';

class PrediccionService {
  final String baseUrl = "https://tallermovilg2ml-010e0a8a58c1.herokuapp.com";
  Future<Map<String, dynamic>> predecir(InputFeatures input) async {
    final url = Uri.parse("$baseUrl/predict");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(input.toJson()),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Error al obtener predicción");
    }
  }
}
