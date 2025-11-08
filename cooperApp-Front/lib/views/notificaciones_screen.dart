import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/notificacion_viewmodel.dart';

class NotificacionesScreen extends StatefulWidget {
  final String cuentaId;

  const NotificacionesScreen({Key? key, required this.cuentaId}) : super(key: key);

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    await Provider.of<NotificationViewModel>(context, listen: false)
        .fetchNotificaciones(widget.cuentaId);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<NotificationViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: Colors.green,
      ),
      body: viewModel.loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadNotifications,
        child: viewModel.notificaciones.isEmpty
            ? const Center(child: Text('No hay notificaciones.'))
            : ListView.builder(
          itemCount: viewModel.notificaciones.length,
          itemBuilder: (context, index) {
            final noti = viewModel.notificaciones[index];
            final date = _formatDate(noti.fechaCreacion);
            final icon = _getIcon(noti.tipo);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: _getColorByEstado(noti.estado),
                        width: 5,
                      ),
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(icon, color: _getColorByEstado(noti.estado)),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            noti.tipo ?? 'Notificación',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (noti.estado != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getColorByEstado(noti.estado).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _getColorByEstado(noti.estado),
                              ),
                            ),
                            child: Text(
                              noti.estado!.toUpperCase(),
                              style: TextStyle(
                                color: _getColorByEstado(noti.estado),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (noti.mensaje != null) Text(noti.mensaje!),
                        if (date != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              date,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        if (noti.estado?.toLowerCase() == 'pending')
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade600,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                  onPressed: () async {
                                    await viewModel.acceptNotification(
                                        noti.idNotification!);
                                  },
                                  icon: const Icon(Icons.check),
                                  label: const Text("Aceptar"),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade600,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                  onPressed: () async {
                                    await viewModel.rejectNotification(
                                        noti.idNotification!);
                                  },
                                  icon: const Icon(Icons.close),
                                  label: const Text("Rechazar"),
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
          },
        ),
      ),
    );
  }

  /// Formatea fecha ISO a formato local legible
  String? _formatDate(String? isoDate) {
    if (isoDate == null) return null;
    try {
      final parsed = DateTime.parse(isoDate);
      return DateFormat('dd MMM yyyy – HH:mm').format(parsed);
    } catch (e) {
      return isoDate;
    }
  }

  /// Selecciona icono según tipo
  IconData _getIcon(String? tipo) {
    switch (tipo) {
      case 'INVITACION_ACCESO_CUENTA':
        return Icons.mail_outline; // Invitación
      case 'SOLICITUD_ACCESO_CUENTA':
        return Icons.lock_open; // Solicitud de acceso
      case 'REPORTE_CUENTA':
        return Icons.report_problem; // Reporte
      case 'DEPOSITO':
        return Icons.attach_money; // Depósito
      case 'RETIRO':
        return Icons.money_off; // Retiro
      case 'TRANSFERENCIA':
        return Icons.swap_horiz; // Transferencia
      case 'ALERTA':
        return Icons.warning; // Genérica de alerta
      case 'INFO':
      default:
        return Icons.notifications; // Genérico
    }
  }

  /// Color dinámico por estado
  Color _getColorByEstado(String? estado) {
    switch (estado?.toLowerCase()) {
      case 'pending':
        return Colors.orange.shade600;
      case 'aceptada':
        return Colors.blueAccent;
      case 'completado':
        return Colors.green.shade600;
      case 'rechazada':
        return Colors.redAccent;
      default:
        return Colors.grey.shade500;
    }
  }
}
