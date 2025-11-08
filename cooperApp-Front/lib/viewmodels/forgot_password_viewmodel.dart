import 'package:flutter/material.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  Future<void> sendRecoveryEmail({
    required BuildContext context,
    required String username,
    required String email,
  }) async {
    // Aquí iría la lógica real para recuperar contraseña (API, etc.)
    // Por ahora solo muestra un mensaje simulado:
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Correo enviado'),
        content: const Text('Por favor revise su correo electrónico'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}