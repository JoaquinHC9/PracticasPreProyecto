class NotificationModel {
  final String? idNotification;
  final String? idUsuario;
  final String? mensaje;
  final String? tipo;
  final String? idCuenta;
  final String? idSolicitante;
  final String? estado;
  final String? fechaCreacion;
  final String? fechaModificacion;

  NotificationModel({
    this.idNotification,
    this.idUsuario,
    this.mensaje,
    this.tipo,
    this.idCuenta,
    this.idSolicitante,
    this.estado,
    this.fechaCreacion,
    this.fechaModificacion,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      idNotification: json['idNotification'],
      idUsuario: json['idUsuario'],
      mensaje: json['mensaje'],
      tipo: json['tipo'],
      idCuenta: json['idCuenta'],
      idSolicitante: json['idSolcitante'], // cuidado con el nombre en el backend
      estado: json['estado'],
      fechaCreacion: json['fechaCreacion'],
      fechaModificacion: json['fechaModificacion'],
    );
  }
}
