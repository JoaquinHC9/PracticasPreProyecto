import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class AnalizaPatronesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.grey[800]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: SizedBox(
              height: kToolbarHeight,
              child: Center(
                child: Image.asset(
                  'assets/images/ardillas.png',
                  height: 48, // Más grande
                ),
              ),
            ),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        children: [
          const SizedBox(height: 16),
          const Center(
            child: Text(
              "Analizar patrones de ahorro",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.green,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Gráfico de Frecuencia
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Frecuencia de Aportes",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Image.asset(
                'assets/images/frecuencia.jpg', // Tu gráfico de línea
                fit: BoxFit.cover,
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Gráfico de Montos
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Montos Promedio por Mes",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Image.asset(
                'assets/images/montos.png', // Tu gráfico de barras
                fit: BoxFit.cover,
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Alerta
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFFFFDEAA),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Alertas de Incumplimientos",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: const [
                      Icon(Icons.warning, size: 32),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Aporte incumplido el 10 de febrero en monto de S/.100",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Mensaje final
          const Center(
            child: Text(
              "Tu frecuencia de ahorros ha disminuido\nen marzo.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}