/// Espejo de ConversacionDto. Estos nombres SÍ están confirmados: se leen
/// directamente como accessors (actual.usuarioId(), actual.nombre(), etc.)
/// dentro de ServicioMensajes.conversaciones().
class Conversacion {
  const Conversacion({
    required this.usuarioId,
    required this.nombre,
    required this.rol,
    this.ultimoMensaje,
    this.fechaUltimoMensaje,
    required this.sinLeer,
  });

  final int usuarioId;
  final String nombre;
  final String rol;
  final String? ultimoMensaje;
  final DateTime? fechaUltimoMensaje;
  final int sinLeer;

  factory Conversacion.desdeJson(Map<String, dynamic> json) => Conversacion(
    usuarioId: json['usuarioId'] as int,
    nombre: json['nombre'] as String? ?? '',
    rol: json['rol'] as String? ?? '',
    ultimoMensaje: json['ultimoMensaje'] as String?,
    fechaUltimoMensaje: json['fechaUltimoMensaje'] == null
        ? null
        : DateTime.parse(json['fechaUltimoMensaje'] as String),
    sinLeer: json['sinLeer'] as int? ?? 0,
  );
}