import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/input_features.dart';
import '../services/prediccion_service.dart';
import '../viewmodels/predice_abandono_view_model.dart';

class PrediceAbandonoScreen extends StatelessWidget {
  const PrediceAbandonoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<PrediceAbandonoViewModel>(context, listen: true);
    vm.setContext(context);

    final List<Map<String, dynamic>> usuarios = [
      {
        "nombre": "Camila Zegarra",
        "edad": 24,
        "frecuencia": "1/4",
        "monto": "S/ 80",
        "incumplimientos": 3,
        "avatar": "C",
        "color": Colors.purple,
        "input": InputFeatures(
          frecuenciaMesActual: 1,
          frecuenciaMesAnterior: 4,
          montoPromedioActual: 80.0,
          montoPromedioAnterior: 140.0,
          incumplimientosTotales: 3,
          edad: 24,
          variacionFrecuencia: -3,
        ),
      },
      {
        "nombre": "Rodrigo Barreto",
        "edad": 30,
        "frecuencia": "5/5",
        "monto": "S/ 220",
        "incumplimientos": 0,
        "avatar": "R",
        "color": Colors.blue,
        "input": InputFeatures(
          frecuenciaMesActual: 5,
          frecuenciaMesAnterior: 5,
          montoPromedioActual: 220.0,
          montoPromedioAnterior: 210.0,
          incumplimientosTotales: 0,
          edad: 30,
          variacionFrecuencia: 0,
        ),
      },
      {
        "nombre": "Lucía Fernandez",
        "edad": 25,
        "frecuencia": "3/4",
        "monto": "S/ 150",
        "incumplimientos": 1,
        "avatar": "L",
        "color": Colors.teal,
        "input": InputFeatures(
          frecuenciaMesActual: 3,
          frecuenciaMesAnterior: 4,
          montoPromedioActual: 150.0,
          montoPromedioAnterior: 180.0,
          incumplimientosTotales: 1,
          edad: 25,
          variacionFrecuencia: -1,
        ),
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8EF),
      appBar: AppBar(
        title: const Text(
          "Predicción de Abandono",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF00796B),
        elevation: 0,
        centerTitle: true,
      ),
      body: vm.cargando
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00796B)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Analizando datos...",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF4D4D4D),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFF4B64C).withOpacity(0.2),
                            const Color(0xFFF4B64C).withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF4B64C)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Row(
                            children: [
                              Icon(
                                Icons.analytics_outlined,
                                color: Color(0xFF00796B),
                                size: 28,
                              ),
                              SizedBox(width: 12),
                              Text(
                                "Simulador de Predicción",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00796B),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Text(
                            "Selecciona un usuario para analizar su probabilidad de abandono basada en su comportamiento histórico.",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF4D4D4D),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ...usuarios.map((usuario) => _buildUserCard(context, usuario, vm)),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildUserCard(BuildContext context, Map<String, dynamic> usuario, PrediceAbandonoViewModel vm) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            await _procesarPrediccion(context, usuario, vm);
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: usuario['color'].withOpacity(0.2),
                  child: Text(
                    usuario['avatar'],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: usuario['color'],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        usuario['nombre'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00796B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildInfoChip("${usuario['edad']} años", Icons.person_outline),
                          const SizedBox(width: 8),
                          _buildInfoChip("Frec: ${usuario['frecuencia']}", Icons.trending_up_outlined),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _buildInfoChip(usuario['monto'], Icons.attach_money_outlined),
                          const SizedBox(width: 8),
                          _buildInfoChip("${usuario['incumplimientos']} incump.", Icons.warning_amber_outlined),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4B64C).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFF00796B),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8EF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF4D4D4D)),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF4D4D4D),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _procesarPrediccion(BuildContext context, Map<String, dynamic> usuario, PrediceAbandonoViewModel vm) async {
    vm.setCargando(true);
    try {
      final resultado = await PrediccionService().predecir(usuario['input']);
      vm.setResultado(usuario['nombre'], resultado['probabilidad']);
      _mostrarResultado(context, vm);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Error al predecir: ${e.toString()}",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      vm.setCargando(false);
    }
  }

  void _mostrarResultado(BuildContext context, PrediceAbandonoViewModel vm) {
    Color color;
    String mensaje;
    IconData icon;

    if (vm.riesgo == "alto") {
      color = Colors.red[600]!;
      mensaje = "Riesgo alto de abandono";
      icon = Icons.warning;
    } else if (vm.riesgo == "medio") {
      color = const Color(0xFFF4B64C); // color anaranjado
      mensaje = "Riesgo moderado de abandono";
      icon = Icons.info;
    } else {
      color = const Color(0xFF00796B); // color verde oscuro
      mensaje = "Bajo riesgo de abandono";
      icon = Icons.check_circle;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Resultado - ${vm.nombreUsuario}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                mensaje,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.percent, color: color, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Probabilidad: ${(vm.probabilidad * 100).toStringAsFixed(1)}%",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              backgroundColor: color.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              "Cerrar",
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
