import 'package:flutter/material.dart';

class PrediceAbandonoViewModel extends ChangeNotifier {
  bool cargando = false;
  String nombreUsuario = "";
  double probabilidad = 0.0;
  String riesgo = "medio";
  BuildContext? context; // Por si se quiere cerrar diálogos desde el ViewModel

  void setContext(BuildContext ctx) {
    context = ctx;
  }

  void setCargando(bool value) {
    cargando = value;
    notifyListeners();
  }

  void setResultado(String nombre, double prob) {
    nombreUsuario = nombre;
    probabilidad = prob;
    riesgo = _calcularRiesgo(prob);
    notifyListeners();
  }

  String _calcularRiesgo(double prob) {
    if (prob >= 0.75) return "alto";
    if (prob >= 0.40) return "medio";
    return "bajo";
  }
}
