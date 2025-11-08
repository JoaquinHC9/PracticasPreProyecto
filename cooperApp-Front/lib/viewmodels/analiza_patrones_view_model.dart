import 'package:flutter/material.dart';

class AnalizaPatronesViewModel extends ChangeNotifier {
  List<String> _alertas = [];
  String _mensajeFinal = '';

  List<String> get alertas => _alertas;
  String get mensajeFinal => _mensajeFinal;

  AnalizaPatronesViewModel() {
    cargarDatos();
  }

  void cargarDatos() {
    // Simulación de carga de datos
    _alertas = [
      "Aporte incumplido el 10 de febrero en monto de S/.100",
    ];
    _mensajeFinal = "Tu frecuencia de ahorros ha disminuido\nen marzo.";

    notifyListeners();
  }
}