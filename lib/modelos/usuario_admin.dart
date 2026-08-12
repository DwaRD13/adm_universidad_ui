/// Usuario administrador. Refleja el DTO del backend para el panel admin.
class UsuarioAdmin {
  const UsuarioAdmin({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.email,
    required this.rol,
    this.matricula,
    this.telefono,
    this.estado,
    this.creadoEn,
  });

  final int id;
  final String nombres;
  final String apellidos;
  final String email;
  final String rol;
  final String? matricula;
  final String? telefono;
  final String? estado;
  final DateTime? creadoEn;

  String get nombreCompleto => '$nombres $apellidos';

  factory UsuarioAdmin.desdeJson(Map<String, dynamic> json) => UsuarioAdmin(
    id: json['id'] as int,
    nombres: json['nombres'] as String? ?? '',
    apellidos: json['apellidos'] as String? ?? '',
    email: json['email'] as String? ?? '',
    rol: json['rol'] is Map
        ? (json['rol']['nombre'] as String? ?? '')
        : (json['rol'] as String? ?? ''),
    matricula: json['matricula'] as String?,
    telefono: json['telefono'] as String?,
    estado: json['estado'] as String?,
    creadoEn: json['creadoEn'] != null
        ? DateTime.parse(json['creadoEn'] as String)
        : null,
  );

  Map<String, dynamic> aJson() => {
    'id': id,
    'nombres': nombres,
    'apellidos': apellidos,
    'email': email,
    'rol': rol,
    'matricula': matricula,
    'telefono': telefono,
    'estado': estado,
    'creadoEn': creadoEn?.toIso8601String(),
  };
}
