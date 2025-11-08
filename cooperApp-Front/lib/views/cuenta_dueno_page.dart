import 'package:flutter/material.dart';
import '../models/account_model.dart';
import '../services/account_service.dart'; // Asegúrate de importar esto
import 'package:flutter/services.dart'; // Para Clipboard

class CuentaDuenoPage extends StatelessWidget {
  final AccountModel account;

  const CuentaDuenoPage({super.key, required this.account});

  static const _menuAnadir = 'añadir';
  static const _menuCodigo = 'codigo';
  static const _menuHistorial = 'historial';

  void _handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case _menuAnadir:
        _showInviteMemberDialog(context);
        break;
      case _menuCodigo:
        _generateCodeAndShow(context);
        break;
      case _menuHistorial:
        _showMessage(context, 'Descargando historial');
        break;
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _generateCodeAndShow(BuildContext context) async {
    final service = AccountService();
    final code = await service.generateInviteCode(account.cuentaId);

    if (!context.mounted) return;

    if (code != null) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Código generado'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SelectableText(
                code,
                style: const TextStyle(
                  fontSize: 20,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Copiar código'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: code));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Código copiado al portapapeles')),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    } else {
      _showMessage(context, 'No se pudo generar el código.');
    }
  }

  void _showInviteMemberDialog(BuildContext context) {
    final _emailController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    final accountService = AccountService();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invitar nuevo miembro'),
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Correo electrónico',
              hintText: 'ejemplo@correo.com',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese un correo';
              }
              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
              if (!emailRegex.hasMatch(value)) {
                return 'Correo inválido';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState?.validate() ?? false) {
                final email = _emailController.text.trim();

                Navigator.pop(context); // Cerrar el diálogo

                bool success = await accountService.inviteMember(
                  email: email,
                  cuentaId: account.cuentaId,
                );

                if (!context.mounted) return;

                if (success) {
                  _showMessage(context, 'Invitación enviada a $email');
                } else {
                  _showMessage(context, 'Error al enviar invitación');
                }
              }
            },
            child: const Text('Enviar invitación'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          account.nombreCuenta,
          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        backgroundColor: Colors.indigo,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) => _handleMenuSelection(context, value),
            itemBuilder: (context) => const [
              PopupMenuItem(value: _menuAnadir, child: Text('Añadir miembros')),
              PopupMenuItem(value: _menuCodigo, child: Text('Generar código')),
              PopupMenuItem(value: _menuHistorial, child: Text('Descargar historial')),
            ],
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[100],
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tarjeta de saldo
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Saldo disponible',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${account.moneda} ${account.saldo.toStringAsFixed(2)}',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Información adicional
              Text('Estado: ${account.estado}', style: theme.textTheme.bodyMedium),
              Text('Tipo: ${account.tipo}', style: theme.textTheme.bodyMedium),
              Text('Descripción: ${account.descripcion}', style: theme.textTheme.bodyMedium),
              Text('Creado por: ${account.creadorNombre}', style: theme.textTheme.bodyMedium),
              Text(
                'Fecha de creación: ${account.fechaCreacion.toLocal().toString().split(' ')[0]}',
                style: theme.textTheme.bodyMedium,
              ),

              const SizedBox(height: 30),

              // Título movimientos
              Text(
                'Últimos movimientos',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),

              // Lista simulada de movimientos
              _buildMovimientoItem('Depósito', 100.00, Colors.green),
              const SizedBox(height: 10),
              _buildMovimientoItem('Retiro', 50.00, Colors.red),
              const SizedBox(height: 10),
              _buildMovimientoItem('Depósito', 200.00, Colors.green),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMovimientoItem(String tipo, double monto, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: ListTile(
        leading: Icon(
          tipo == 'Depósito' ? Icons.arrow_downward : Icons.arrow_upward,
          color: color,
        ),
        title: Text(tipo),
        trailing: Text(
          '${account.moneda} ${monto.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}
