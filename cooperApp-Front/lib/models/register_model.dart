class RegisterModel {
  final String email;
  final String password;
  final String firstname;
  final String lastname;
  final String tipoDocumento;
  final String dni;
  final String telefono;
  final String fechaNacimiento;

  // Constructor
  RegisterModel({
    required this.email,
    required this.password,
    required this.firstname,
    required this.lastname,
    required this.tipoDocumento,
    required this.dni,
    required this.telefono,
    required this.fechaNacimiento,
  });

  // Convierte un objeto RegisterModel a un mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'firstname': firstname,
      'lastname': lastname,
      'tipoDocumento': tipoDocumento,
      'dni': dni,
      'telefono': telefono,
      'fechaNacimiento': fechaNacimiento,
    };
  }

  // Convierte un mapa JSON a un objeto RegisterModel
  factory RegisterModel.fromJson(Map<String, dynamic> json) {
    return RegisterModel(
      email: json['email'],
      password: json['password'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      tipoDocumento: json['tipoDocumento'],
      dni: json['dni'],
      telefono: json['telefono'],
      fechaNacimiento: json['fechaNacimiento'],
    );
  }
}
