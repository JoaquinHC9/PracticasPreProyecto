class UserModel {
  final String nombre;
  final String dni;
  final String fechaNacimiento;
  final String email;
  final String telefono;

  UserModel({
    required this.nombre,
    required this.dni,
    required this.fechaNacimiento,
    required this.email,
    required this.telefono,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      nombre: json['nombre'] ?? '',
      dni: json['dni'] ?? '',
      fechaNacimiento: json['fechaNacimiento']?.toString() ?? '',
      email: json['email'] ?? '',
      telefono: json['telefono'] ?? '',
    );
  }
}
