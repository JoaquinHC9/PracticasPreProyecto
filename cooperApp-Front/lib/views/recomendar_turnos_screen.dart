import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class RecomendarTurnosScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Recomendación de Turnos")),
      body: Center(child: Text("Aquí se evaluarán turnos justos para cuentas mancomunadas.")),
    );
  }
}
