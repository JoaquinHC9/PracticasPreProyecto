class CreateAccountModel {
  final String nombre;
  final String tipo;
  final String moneda;
  final double saldo;
  final String descripcion;
  final String creadorUid;

  CreateAccountModel({
    required this.nombre,
    required this.tipo,
    required this.moneda,
    required this.saldo,
    required this.descripcion,
    required this.creadorUid,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'tipo': tipo,
      'moneda': moneda,
      'saldo': saldo,
      'descripcion': descripcion,
      'creadorUid': creadorUid,
    };
  }
}
