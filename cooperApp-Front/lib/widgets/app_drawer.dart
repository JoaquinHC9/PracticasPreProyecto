import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/report_viewmodel.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('¿Seguro que quieres cerrar sesión?'),
        content: const Text('Perderás tu sesión actual.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await Provider.of<AuthViewModel>(context, listen: false).logout(context);
            },
            child: const Text(
              'Cerrar sesión',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToReportAccount(BuildContext context) {
    final reportVM = Provider.of<ReportViewModel>(context, listen: false);
    reportVM.prepareReport();
    Navigator.pop(context);
    Navigator.pushNamed(context, '/reportAccount');
  }

  Future<void> _navigateToNotifications(BuildContext context) async {
    final uid = await _extractUidFromToken();
    if (uid != null) {
      Navigator.pop(context);
      Navigator.pushNamed(context, '/notificaciones', arguments: uid);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo obtener el ID del usuario')),
      );
    }
  }

  Future<String?> _extractUidFromToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return null;

    try {
      final parts = token.split('.');
      if (parts.length == 3) {
        final payload = base64Url.decode(base64Url.normalize(parts[1]));
        final payloadMap = jsonDecode(utf8.decode(payload));
        return payloadMap['sub']; // uid del usuario
      }
    } catch (e) {
      print('Error al decodificar el token: $e');
    }
    return null;
  }


  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = Colors.black87,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: onTap,
      visualDensity: const VisualDensity(horizontal: 0, vertical: -1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.account_circle, size: 64, color: Colors.white),
                  SizedBox(height: 8),
                  Text('CooperApp',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  SizedBox(height: 4),
                  Text('Ahorra fácil, ahorra juntos',
                      style: TextStyle(fontSize: 14, color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _buildDrawerItem(
              icon: Icons.home,
              title: 'Inicio',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/home');
              },
            ),
            _buildDrawerItem(
              icon: Icons.person,
              title: 'Perfil',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/perfil');
              },
            ),
            _buildDrawerItem(
              icon: Icons.account_balance,
              title: 'Crear cuenta',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/createAccount');
              },
            ),
            _buildDrawerItem(
              icon: Icons.group_add,
              title: 'Unirme a una cuenta',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/joinAccount');
              },
            ),
            _buildDrawerItem(
              icon: Icons.notifications,
              title: 'Notificaciones',
              onTap: () => _navigateToNotifications(context),
            ),
            _buildDrawerItem(
              icon: Icons.money_off,
              title: 'Solicitar retiro',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/solicitarRetiro');
              },
            ),
            _buildDrawerItem(
              icon: Icons.arrow_downward,
              title: 'Solicitar depósito',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/solicitarDeposito');
              },
            ),
            _buildDrawerItem(
              icon: Icons.savings,
              title: 'Ahorra Ya',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/aiAssistant');
              },
            ),
            _buildDrawerItem(
              icon: Icons.report_problem,
              title: 'Denunciar cuenta',
              onTap: () => _navigateToReportAccount(context),
              iconColor: Colors.redAccent,
            ),
            const Divider(thickness: 1, indent: 16, endIndent: 16),
            _buildDrawerItem(
              icon: Icons.logout,
              title: 'Cerrar sesión',
              onTap: () => _confirmLogout(context),
              iconColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}
