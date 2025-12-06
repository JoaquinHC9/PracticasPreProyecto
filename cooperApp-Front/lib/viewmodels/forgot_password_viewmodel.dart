import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  Future<bool> sendRecoveryCode(
      BuildContext context,
      String email,
      ) async {
    try {
      bool ok = await _authService.sendResetCode(email);

      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Código enviado a tu correo'),
            backgroundColor: Colors.green,
          ),
        );
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No se pudo enviar el código"),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  Future<bool> confirmPasswordReset({
    required BuildContext context,
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      return await _authService.confirmResetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }
}