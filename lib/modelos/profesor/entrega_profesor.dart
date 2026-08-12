class EntregaProfesor {
  const EntregaProfesor({
    required this.id,
    required this.estudianteId,
    required this.estudianteNombre,
    required this.archivoUrl,
    required this.fechaEnvio,
    this.calificacion,
    this.comentariosProfesor,
  });

  final int id;
  final int estudianteId;
  final String estudianteNombre;
  final String archivoUrl;
  final DateTime fechaEnvio;
  final double? calificacion;
  final String? comentariosProfesor;

  bool get calificada => calificacion != null;

  factory EntregaProfesor.desdeJson(Map<String, dynamic> json) => EntregaProfesor(
    id: json['id'] as int,
    estudianteId: json['estudianteId'] as int,
    estudianteNombre: json['estudianteNombre'] as String? ?? '',
    archivoUrl: json['archivoUrl'] as String? ?? '',
    fechaEnvio: DateTime.parse(json['fechaEnvio'] as String),
    calificacion: (json['calificacion'] as num?)?.toDouble(),
    comentariosProfesor: json['comentariosProfesor'] as String?,
  );
}