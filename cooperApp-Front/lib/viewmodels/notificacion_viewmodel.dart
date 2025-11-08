import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationService _service = NotificationService();
  List<NotificationModel> _notificaciones = [];

  List<NotificationModel> get notificaciones => _notificaciones;

  bool _loading = false;
  bool get loading => _loading;
  String _lastUid = '';
  Future<void> fetchNotificaciones(String uid) async {
    _loading = true;
    notifyListeners();
    try {
      _notificaciones = await _service.getNotificaciones(uid); // <- pásalo
    } catch (e) {
      debugPrint('Error al obtener notificaciones: $e');
      _notificaciones = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
  Future<void> acceptNotification(String idNotificacion) async {
    await _service.acceptNotification(idNotificacion);
    await fetchNotificaciones(_lastUid); // refrescar luego de aceptar
  }

  Future<void> rejectNotification(String idNotificacion) async {
    await _service.rejectNotification(idNotificacion);
    await fetchNotificaciones(_lastUid); // refrescar luego de rechazar
  }
}