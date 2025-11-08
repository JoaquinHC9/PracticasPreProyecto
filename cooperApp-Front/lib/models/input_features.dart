class InputFeatures {
  final int frecuenciaMesActual;
  final int frecuenciaMesAnterior;
  final double montoPromedioActual;
  final double montoPromedioAnterior;
  final int incumplimientosTotales;
  final int edad;
  final int variacionFrecuencia;

  InputFeatures({
    required this.frecuenciaMesActual,
    required this.frecuenciaMesAnterior,
    required this.montoPromedioActual,
    required this.montoPromedioAnterior,
    required this.incumplimientosTotales,
    required this.edad,
    required this.variacionFrecuencia,
  });

  Map<String, dynamic> toJson() => {
        "frecuenciaMesActual": frecuenciaMesActual,
        "frecuenciaMesAnterior": frecuenciaMesAnterior,
        "montoPromedioActual": montoPromedioActual,
        "montoPromedioAnterior": montoPromedioAnterior,
        "incumplimientosTotales": incumplimientosTotales,
        "edad": edad,
        "variacionFrecuencia": variacionFrecuencia,
      };
}
