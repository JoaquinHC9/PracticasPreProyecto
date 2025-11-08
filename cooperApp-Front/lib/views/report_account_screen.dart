import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/report_viewmodel.dart';
import '../widgets/app_drawer.dart';

class ReportAccountScreen extends StatelessWidget {
  const ReportAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReportViewModel(),
      child: Scaffold(
        drawer: const AppDrawer(),
        appBar: AppBar(
          title: const Text('Denunciar cuenta mancomunada'),
          backgroundColor: Colors.green,
        ),
        body: const Padding(
          padding: EdgeInsets.all(16.0),
          child: ReportForm(),
        ),
      ),
    );
  }
}

class ReportForm extends StatefulWidget {
  const ReportForm({super.key});

  @override
  State<ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends State<ReportForm> {
  @override
  void initState() {
    super.initState();
    // Cargar las cuentas cuando se inicializa el widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReportViewModel>(context, listen: false).loadMemberAccounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ReportViewModel>(context);

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFCF5),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black26)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Seleccione cuenta a denunciar'),
            const SizedBox(height: 5),

            // Mostrar indicador de carga mientras se cargan las cuentas
            if (vm.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else
            // Dropdown dinámico con las cuentas donde es miembro
              DropdownButtonFormField<String>(
                value: vm.selectedAccount,
                items: vm.memberAccounts.map((account) {
                  return DropdownMenuItem(
                    value: account.cuentaId,
                    child: Text('${account.nombreCuenta} - ${account.tipo}'),
                  );
                }).toList(),
                decoration: InputDecoration(
                  hintText: vm.memberAccounts.isEmpty
                      ? 'No hay cuentas disponibles'
                      : 'Seleccione una cuenta',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.brown.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: vm.memberAccounts.isEmpty ? null : vm.updateAccount,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor seleccione una cuenta';
                  }
                  return null;
                },
              ),

            // Mostrar mensaje si no hay cuentas
            if (vm.memberAccounts.isEmpty && !vm.isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'No tienes cuentas donde seas miembro para reportar',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),

            const SizedBox(height: 20),

            const Text('Motivo de denuncia'),
            const SizedBox(height: 5),
            TextFormField(
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Ej. La descripción no va con el fin de la cuenta mancomunada',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.brown.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: vm.updateReason,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese un motivo';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            const Text('Adjuntar evidencia'),
            const SizedBox(height: 5),
            TextFormField(
              readOnly: true,
              controller: TextEditingController(
                text: vm.evidences.isEmpty
                    ? ''
                    : vm.evidences.map((e) => e.path.split('/').last).join(', '),
              ),
              decoration: InputDecoration(
                hintText: 'Seleccione hasta 3 archivos',
                suffixIcon: const Icon(Icons.upload_file),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.brown.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onTap: () {
                vm.pickFiles();
              },
            ),

            const SizedBox(height: 30),

            Center(
              child: ElevatedButton(
                onPressed: (vm.memberAccounts.isEmpty || vm.isLoading)
                    ? null
                    : () async {
                  try {
                    await vm.submitReport();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Reporte enviado exitosamente'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFDFAE),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  'Denunciar cuenta mancomunada',
                  style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}