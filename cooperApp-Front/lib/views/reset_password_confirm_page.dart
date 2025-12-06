import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/forgot_password_viewmodel.dart';

class ResetPasswordConfirmPage extends StatefulWidget {
  final String email;

  const ResetPasswordConfirmPage({super.key, required this.email});

  @override
  State<ResetPasswordConfirmPage> createState() =>
      _ResetPasswordConfirmPageState();
}

class _ResetPasswordConfirmPageState extends State<ResetPasswordConfirmPage> {
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ForgotPasswordViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Restablecer contraseña"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "Código enviado a: ${widget.email}",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: "Código de verificación",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Nueva contraseña",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : () async {
                final code = _codeController.text.trim();
                final password = _passwordController.text.trim();

                if (code.isEmpty || password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Complete todos los campos")),
                  );
                  return;
                }

                setState(() => _isLoading = true);

                bool ok = await viewModel.confirmPasswordReset(
                  context: context,
                  email: widget.email,
                  code: code,
                  newPassword: password,
                );

                setState(() => _isLoading = false);

                if (ok && mounted) {
                  // Volver a la página de login
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Contraseña cambiada correctamente"),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Código incorrecto o expirado"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Confirmar", style: TextStyle(color: Colors.white, fontSize: 18)),
            )
          ],
        ),
      ),
    );
  }
}