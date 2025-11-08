import 'package:flutter/material.dart';
import '../services/account_service.dart';
import '../models/create_account_model.dart';

class CreateAccountViewModel extends ChangeNotifier {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController tipoController = TextEditingController();
  final TextEditingController monedaController = TextEditingController();
  final TextEditingController saldoController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();

  final AccountService _accountService = AccountService();

  Future<void> createAccount(BuildContext context) async {
    final String nombre = nombreController.text.trim();
    final String tipo = tipoController.text.trim();
    final String moneda = monedaController.text.trim();
    final String saldoStr = saldoController.text.trim();
    final String descripcion = descripcionController.text.trim();

    if (nombre.isEmpty || tipo.isEmpty || moneda.isEmpty || saldoStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, complete todos los campos obligatorios.')),
      );
      return;
    }

    final double? saldo = double.tryParse(saldoStr);
    if (saldo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saldo inválido. Debe ser un número.')),
      );
      return;
    }

    final createModel = CreateAccountModel(
      nombre: nombre,
      tipo: tipo,
      moneda: moneda,
      saldo: saldo,
      descripcion: descripcion,
      creadorUid: "", // Se sobreescribe dentro del servicio
    );

    final result = await _accountService.createAccount(createModel);

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cuenta creada con éxito.')),
      );
      // Opcional: limpiar los campos después de la creación
      nombreController.clear();
      tipoController.clear();
      monedaController.clear();
      saldoController.clear();
      descripcionController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ocurrió un error al crear la cuenta.')),
      );
    }
  }

  @override
  void dispose() {
    nombreController.dispose();
    tipoController.dispose();
    monedaController.dispose();
    saldoController.dispose();
    descripcionController.dispose();
    super.dispose();
  }
}
