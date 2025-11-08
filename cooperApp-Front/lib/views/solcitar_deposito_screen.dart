import 'package:flutter/material.dart';
import '../models/account_model.dart';
import '../services/account_service.dart';
import '../widgets/app_drawer.dart';

class SolicitarDepositoScreen extends StatefulWidget {
  const SolicitarDepositoScreen({Key? key}) : super(key: key);

  @override
  _SolicitarDepositoScreenState createState() => _SolicitarDepositoScreenState();
}

class _SolicitarDepositoScreenState extends State<SolicitarDepositoScreen> {
  final _formKey = GlobalKey<FormState>();
  final AccountService _accountService = AccountService();

  List<AccountModel> _cuentas = [];
  AccountModel? _cuentaSeleccionada;

  String? _metodoSeleccionado;
  final List<String> _metodos = [
    'Transferencia bancaria',
    'Pago móvil',
    'Cheque',
    'Otro',
  ];

  final TextEditingController _cantidadController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarCuentas();
  }

  Future<void> _cargarCuentas() async {
    final cuentas = await _accountService.getAccountsWhereMember();
    setState(() {
      _cuentas = cuentas;
    });
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    super.dispose();
  }

  void _mostrarAlertaCancelar() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmación'),
        content: const Text('¿Seguro que desea cancelar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/home');
            },
            child: const Text('Sí'),
          ),
        ],
      ),
    );
  }

  void _mostrarAlertaSolicitudExitosa() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Solicitud enviada'),
        content: const Text(
          'Se generó con éxito la solicitud de depósito, el dinero se verá reflejado una vez aprobado.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/home');
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  void _onSolicitarDeposito() async {
    if (_formKey.currentState!.validate()) {
      if (_cuentaSeleccionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seleccione una cuenta')),
        );
        return;
      }

      final monto = double.tryParse(_cantidadController.text);
      if (monto == null || monto <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingrese una cantidad válida')),
        );
        return;
      }

      // Llamar al servicio para depositar
      final success = await _accountService.deposit(
        cuentaId: _cuentaSeleccionada!.cuentaId,
        monto: monto,
      );

      if (success) {
        _mostrarAlertaSolicitudExitosa();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al solicitar depósito')),
        );
      }
    }
  }

  InputDecoration _inputDecoration(String label, Color color) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: color),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.brown.shade700;
    final Color accentColor = Colors.green.shade700;

    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: const Color(0xFFFFFCF5),
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Solicitar Depósito'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                DropdownButtonFormField<AccountModel>(
                  decoration: _inputDecoration('Cuenta', primaryColor),
                  hint: const Text('Seleccione cuenta'),
                  value: _cuentaSeleccionada,
                  items: _cuentas.map((cuenta) {
                    return DropdownMenuItem(
                      value: cuenta,
                      child: Text('${cuenta.creadorNombre} (Saldo: S/ ${cuenta.saldo.toStringAsFixed(2)})'),
                    );
                  }).toList(),
                  validator: (value) => value == null ? 'Seleccione una cuenta' : null,
                  onChanged: (cuenta) {
                    setState(() {
                      _cuentaSeleccionada = cuenta;
                      _cantidadController.clear();
                    });
                  },
                ),
                const SizedBox(height: 24),

                if (_cuentaSeleccionada != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Saldo actual',
                          style: TextStyle(
                            fontSize: 18,
                            color: primaryColor.withOpacity(0.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'S/ ${_cuentaSeleccionada!.saldo.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _cantidadController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
                  decoration: _inputDecoration('¿Cuánto desea depositar?', primaryColor),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Ingrese una cantidad';
                    final cantidad = double.tryParse(value);
                    if (cantidad == null || cantidad <= 0) return 'Ingrese una cantidad válida';
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                DropdownButtonFormField<String>(
                  decoration: _inputDecoration('Método', primaryColor),
                  hint: const Text('Seleccione método de depósito'),
                  value: _metodoSeleccionado,
                  items: _metodos
                      .map((metodo) => DropdownMenuItem(value: metodo, child: Text(metodo)))
                      .toList(),
                  validator: (value) => value == null ? 'Seleccione un método' : null,
                  onChanged: (value) {
                    setState(() => _metodoSeleccionado = value);
                  },
                ),

                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.yellow.shade300),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, color: Colors.amber, size: 28),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Recuerde que la solicitud deberá ser aprobada por todos los miembros de la cuenta mancomunada.',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryColor,
                          side: BorderSide(color: primaryColor, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        onPressed: _mostrarAlertaCancelar,
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _onSolicitarDeposito,
                        icon: const Icon(Icons.check),
                        label: const Text('Solicitar depósito', style: TextStyle(fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
