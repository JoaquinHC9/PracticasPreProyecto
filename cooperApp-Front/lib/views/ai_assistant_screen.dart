import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../widgets/app_drawer.dart';
import 'analiza_patrones_screen.dart';
import 'predice_abandono_screen.dart';
import 'sugerir_metas_screen.dart';
import 'recomendar_turnos_screen.dart';


class AiAssistantScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF5),
      drawer: AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.grey[800]),
          actions: [
            Padding(

              padding: const EdgeInsets.only(right: 16.0),
              child: SizedBox(
                height: kToolbarHeight, // Usa la altura estándar de la AppBar
                child: Center(
                  child: Image.asset(
                    'assets/images/ardillas.png',
                    height: 48, // Puedes probar con 48, 56, 64, etc.
                  ),
                ),
              ),
            )
          ]
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: ListView(
          children: [
            const SizedBox(height: 12),
            const Center(
              child: Text(
                "Asistente Inteligente InvierteYa",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green),
              ),
            ),
            const SizedBox(height: 24),
            _buildOptionCard(
              context,
              title: "Analiza patrones de ahorro",
              subtitle: "Frecuencia, montos e incumplimiento",
              icon: LucideIcons.piggyBank,
              route: AnalizaPatronesScreen(),
            ),
            _buildOptionCard(
              context,
              title: "Predice el abandono de aportes",
              subtitle: "Estima si un usuario va a dejar de aportar",
              icon: LucideIcons.trendingDown,
              route: PrediceAbandonoScreen(),
            ),
            _buildOptionCard(
              context,
              title: "Sugerir nuevas metas o reajustes",
              subtitle: "Propone metas diferentes o ajustes automáticos",
              icon: LucideIcons.target,
              route: SugerirMetasScreen(),
            ),
            _buildOptionCard(
              context,
              title: "Recomienda turnos más justos",
              subtitle: "Evaluar turnos viables en cuentas mancomunadas",
              icon: LucideIcons.userCheck,
              route: RecomendarTurnosScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context,
      {required String title,
        required String subtitle,
        required IconData icon,
        required Widget route}) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => route),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5C778),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 5,
                offset: Offset(2, 4))
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.teal),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.teal[900]),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(icon, size: 32, color: Colors.black),
          ],
        ),
      ),
    );
  }
}
