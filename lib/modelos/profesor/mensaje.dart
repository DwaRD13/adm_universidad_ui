/// Espejo de MensajeDto (dto/estudiante) — nombres de campo inferidos, no confirmados
/// contra el .java real. Si `esMio` no calza con lo que devuelve el backend,
/// pégame dto/estudiante/MensajeDto.java y lo corrijo en una línea.
class Mensaje {
  const Mensaje({
    required this.id,
    required this.remitenteId,
    required this.remitenteNombre,
    required this.destinatarioId,
    required this.destinatarioNombre,
    this.asunto,
    required this.cuerpo,
    required this.leido,
    required this.esMio,
    required this.fechaEnvio,
  });

  final int id;
  final int remitenteId;
  final String remitenteNombre;
  final int destinatarioId;
  final String destinatarioNombre;
  final String? asunto;
  final String cuerpo;
  final bool leido;
  final bool esMio;
  final DateTime fechaEnvio;

  factory Mensaje.desdeJson(Map<String, dynamic> json) => Mensaje(
    id: json['id'] as int,
    remitenteId: json['remitenteId'] as int,
    remitenteNombre: json['remitenteNombre'] as String? ?? '',
    destinatarioId: json['destinatarioId'] as int,
    destinatarioNombre: json['destinatarioNombre'] as String? ?? '',
    asunto: json['asunto'] as String?,
    cuerpo: json['cuerpo'] as String? ?? '',
    leido: json['leido'] as bool? ?? false,
    esMio: (json['esMio'] ?? json['propio'] ?? json['enviadoPorMi']) as bool? ?? false,
    fechaEnvio: DateTime.parse(json['fechaEnvio'] as String),
  );
}