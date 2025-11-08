import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/create_account_view_model.dart';

class CreateAccountScreen extends StatelessWidget {
  CreateAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    InputDecoration _inputDecoration(String label, IconData icon) {
      return InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.brown),
        labelStyle: const TextStyle(color: Colors.brown),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.brown, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.green, width: 2),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => CreateAccountViewModel(),
      child: Consumer<CreateAccountViewModel>(
        builder: (context, viewModel, _) => Scaffold(
          backgroundColor: const Color(0xFFFFFCF5),
          appBar: AppBar(
            title: const Text('Crear Cuenta'),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Crear Nueva Cuenta',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(height: 30),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.brown.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: viewModel.nombreController,
                        decoration: _inputDecoration('Nombre', Icons.account_circle),
                      ),
                      const SizedBox(height: 20),

                      TextField(
                        controller: viewModel.tipoController,
                        decoration: _inputDecoration('Tipo', Icons.category),
                      ),
                      const SizedBox(height: 20),

                      TextField(
                        controller: viewModel.monedaController,
                        decoration: _inputDecoration('Moneda', Icons.monetization_on),
                      ),
                      const SizedBox(height: 20),

                      TextField(
                        controller: viewModel.saldoController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('Saldo', Icons.attach_money),
                      ),
                      const SizedBox(height: 20),

                      TextField(
                        controller: viewModel.descripcionController,
                        maxLines: 3,
                        decoration: _inputDecoration('Descripción', Icons.description),
                      ),
                      const SizedBox(height: 30),

                      ElevatedButton.icon(
                        onPressed: () => viewModel.createAccount(context),
                        icon: const Icon(Icons.check),
                        label: const Text('Crear Cuenta', style: TextStyle(fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
