class AccountModel {
  final String cuentaId;
  final String nombreCuenta;
  final String tipo;
  final String estado;
  final String moneda;
  final double saldo;
  final String descripcion;
  final String creadorNombre;
  final String creadorUid;
  final DateTime fechaCreacion;

  AccountModel({
    required this.cuentaId,
    required this.nombreCuenta,
    required this.tipo,
    required this.estado,
    required this.moneda,
    required this.saldo,
    required this.descripcion,
    required this.creadorNombre,
    required this.creadorUid,
    required this.fechaCreacion,
  });
  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      cuentaId: json['cuentaId'] ?? '',
      nombreCuenta: json['nombreCuenta'] ?? '',
      tipo: json['tipo'] ?? '',
      estado: json['estado'] ?? '',
      moneda: json['moneda'] ?? '',
      saldo: (json['saldo'] as num).toDouble(),
      descripcion: json['descripcion'] ?? '',
      creadorNombre: json['creadorNombre'] ?? '',
      creadorUid: json['creadorUid'] ?? '',
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
    );
  }
}
