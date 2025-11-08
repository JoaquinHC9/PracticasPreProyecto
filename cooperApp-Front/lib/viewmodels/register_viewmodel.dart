import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/register_model.dart'; // Importa el modelo de registro
import '../config/constants.dart';

class RegisterViewModel extends ChangeNotifier {
  // Controllers for each input field
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();
  final phoneController = TextEditingController();
  final dniController = TextEditingController();
  final tipoDocumentoController = TextEditingController();

  DateTime? fechaNacimiento;

  void setFechaNacimiento(DateTime date) {
    fechaNacimiento = date;
    notifyListeners();
  }

  Future<void> registerUser(BuildContext context) async {
    if (fechaNacimiento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, seleccione la fecha de nacimiento')),
      );
      return;
    }

    final registerModel = RegisterModel(
      email: emailController.text,
      password: passwordController.text,
      firstname: firstnameController.text,
      lastname: lastnameController.text,
      tipoDocumento: tipoDocumentoController.text,
      dni: dniController.text,
      telefono: phoneController.text,
      fechaNacimiento: fechaNacimiento!.toIso8601String(),
    );

    final response = await _register(registerModel);

    if (response != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al registrar, intente nuevamente')),
      );
    }
  }

  Future<Map<String, dynamic>?> _register(RegisterModel registerModel) async {
    final url = Uri.parse('${AppConstants.backendBaseUrl}v1/auth/register');

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
}