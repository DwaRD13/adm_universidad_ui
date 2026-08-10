import '../app/constantes.dart';

/// Usuario autenticado. Refleja `UsuarioDto` del backend.
class Usuario {
  const Usuario({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.nombreCompleto,
    required this.email,
    required this.rol,
    this.matricula,
    this.telefono,
    this.estado,
  });

  final int id;
  final String nombres;
  final String apellidos;
  final String nombreCompleto;
  final String email;
  final String rol;
  final String? matricula;
  final String? telefono;
  final String? estado;

  bool get esEstudiante => rol == Constantes.rolEstudiante;
  bool get esProfesor => rol == Constantes.rolProfesor;
  bool get esAdministrativo => rol == Constantes.rolAdministrativo;

  factory Usuario.desdeJson(Map<String, dynamic> json) => Usuario(
    id: json['id'] as int,
    nombres: json['nombres'] as String? ?? '',
    apellidos: json['apellidos'] as String? ?? '',
    nombreCompleto: json['nombreCompleto'] as String? ?? '',
    email: json['email'] as String? ?? '',
    rol: json['rol'] as String? ?? '',
    matricula: json['matricula'] as String?,
    telefono: json['telefono'] as String?,
    estado: json['estado'] as String?,
  );

  Map<String, dynamic> aJson() => {
    'id': id,
    'nombres': nombres,
    'apellidos': apellidos,
    'nombreCompleto': nombreCompleto,
    'email': email,
    'rol': rol,
    'matricula': matricula,
    'telefono': telefono,
    'estado': estado,
  };
}
