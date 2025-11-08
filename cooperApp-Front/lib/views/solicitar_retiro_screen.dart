import 'package:flutter/material.dart';
import '../models/account_model.dart';
import '../services/account_service.dart';
import '../widgets/app_drawer.dart';

class SolicitarRetiroScreen extends StatefulWidget {
  const SolicitarRetiroScreen({Key? key}) : super(key: key);

  @override
  _SolicitarRetiroScreenState createState() => _SolicitarRetiroScreenState();
}

class _SolicitarRetiroScreenState extends State<SolicitarRetiroScreen> {
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
  final TextEditingController _cuentaDestinoController = TextEditingController();

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
    _cuentaDestinoController.dispose();
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
          'Se generó con éxito la solicitud de retiro de dinero, recuerde que, una vez aprobado por todos los miembros, visualizará el dinero en minutos.',
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

  void _onSolicitarRetiro() async {
    if (_formKey.currentState!.validate()) {
      if (_cuentaSeleccionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seleccione una cuenta')),
        );
        return;
      }

      final monto = double.tryParse(_cantidadController.text);
      if (monto == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingrese una cantidad válida')),
        );
        return;
      }

      // Llamar al servicio para retirar
      final success = await AccountService().withdraw(
        cuentaId: _cuentaSeleccionada!.cuentaId, // o cuentaUid según tu modelo
        monto: monto,
      );

      if (success) {
        _mostrarAlertaSolicitudExitosa();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al solicitar retiro')),
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
        title: const Text('Solicitar Retiro'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Selector de cuenta
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
                      // Cuando cambia la cuenta, limpia la cantidad para evitar confusión
                      _cantidadController.clear();
                    });
                  },
                ),

                const SizedBox(height: 24),

                // Muestra saldo actual de la cuenta seleccionada (solo lectura)
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
                              fontWeight: FontWeight.w600),
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

                // Cantidad a retirar
                TextFormField(
                  controller: _cantidadController,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true, signed: false),
                  decoration: _inputDecoration('¿Cuánto desea retirar?', primaryColor),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Ingrese una cantidad';
                    final cantidad = double.tryParse(value);
                    if (cantidad == null || cantidad <= 0) return 'Ingrese una cantidad válida';

                    if (_cuentaSeleccionada != null && cantidad > _cuentaSeleccionada!.saldo) {
                      return 'La cantidad no puede ser mayor al saldo actual';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Método de retiro
                DropdownButtonFormField<String>(
                  decoration: _inputDecoration('Método', primaryColor),
                  hint: const Text('Seleccione método de transferencia'),
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

                // Cuenta o CCI destino
                TextFormField(
                  controller: _cuentaDestinoController,
                  keyboardType: TextInputType.number
                ),

                const SizedBox(height: 24),

                // Advertencia en rojo con icono
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Recuerde que la solicitud deberá ser aprobada por todos los miembros de la cuenta mancomunada.',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Botones
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
                        onPressed: _onSolicitarRetiro,
                        icon: const Icon(Icons.check),
                        label: const Text('Solicitar retiro', style: TextStyle(fontSize: 16)),
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
