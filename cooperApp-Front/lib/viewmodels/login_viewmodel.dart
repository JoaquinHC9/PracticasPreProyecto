import 'dart:math';
import 'package:flutter/material.dart';
import '../models/login_model.dart';
import '../services/auth_service.dart';

class LoginViewModel extends ChangeNotifier {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode passwordFocusNode = FocusNode();

  List<String> shuffledNumbers = [];

  LoginViewModel() {
    _shuffleNumbers();

    passwordFocusNode.addListener(() {
      if (passwordFocusNode.hasFocus) {
        _shuffleNumbers();
      }
    });
  }

  void _shuffleNumbers() {
    List<String> numbers = List.generate(10, (i) => i.toString());
    numbers.shuffle(Random());
    shuffledNumbers = numbers;
    notifyListeners();
  }

  void onNumberPressed(String number) {
    passwordController.text += number;
    notifyListeners();
  }

  void onDeletePressed() {
    if (passwordController.text.isNotEmpty) {
      passwordController.text = passwordController.text.substring(
        0,
        passwordController.text.length - 1,
      );
      notifyListeners();
    }
  }

  /// Método modificado para usar login real desde AuthService
  Future<bool> login(BuildContext context) async {
    final user = LoginModel(
      username: userController.text.trim(),
      password: passwordController.text,
    );

    final authService = AuthService();
    final response = await authService.login(user);

    if (response != null && response['accessToken'] != null) {
      // Aquí puedes guardar el token si deseas usarlo más adelante
      // Ej: await SharedPreferences.getInstance().setString('token', response['accessToken']);

      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario o clave incorrectos')),
      );
      return false;
    }
  }

  void disposeResources() {
    userController.dispose();
    passwordController.dispose();
    passwordFocusNode.dispose();
  }
}
