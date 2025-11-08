import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class JoinAccountViewModel extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  String _codigo = '';
  bool _isLoading = false;

  String get codigo => _codigo;
  bool get isLoading => _isLoading;

  void actualizarCodigo(String valor) {
    _codigo = valor;
    notifyListeners();
  }

  Future<void> unirseCuenta(BuildContext context) async {
    if (_codigo.trim().isEmpty) {
      _mostrarDialogo(context, 'Error', 'Debes ingresar un código válido.');
      return;
    }

    _isLoading = true;
    notifyListeners();

    final success = await _notificationService.requestAccess(_codigo);

    _isLoading = false;
    notifyListeners();

    if (success) {
      _mostrarDialogo(context, '¡Éxito!', 'Solicitud enviada correctamente.');
    } else {
      _mostrarDialogo(context, 'Error', 'No se pudo enviar la solicitud.');
    }
  }

  void _mostrarDialogo(BuildContext context, String titulo, String mensaje) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            child: const Text('Cerrar'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
