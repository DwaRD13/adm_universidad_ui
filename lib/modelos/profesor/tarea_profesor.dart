class TareaProfesor {
  const TareaProfesor({
    required this.id,
    required this.seccionId,
    required this.materia,
    required this.codigoMateria,
    required this.titulo,
    this.descripcion,
    required this.fechaEntrega,
    this.archivoAdjuntoUrl,
    required this.totalEstudiantes,
    required this.entregadas,
    required this.pendientesPorCalificar,
  });

  final int id;
  final int seccionId;
  final String materia;
  final String codigoMateria;
  final String titulo;
  final String? descripcion;
  final DateTime fechaEntrega;
  final String? archivoAdjuntoUrl;
  final int totalEstudiantes;
  final int entregadas;
  final int pendientesPorCalificar;

  factory TareaProfesor.desdeJson(Map<String, dynamic> json) => TareaProfesor(
    id: json['id'] as int,
    seccionId: json['seccionId'] as int,
    materia: json['materia'] as String? ?? '',
    codigoMateria: json['codigoMateria'] as String? ?? '',
    titulo: json['titulo'] as String? ?? '',
    descripcion: json['descripcion'] as String?,
    fechaEntrega: DateTime.parse(json['fechaEntrega'] as String),
    archivoAdjuntoUrl: json['archivoAdjuntoUrl'] as String?,
    totalEstudiantes: json['totalEstudiantes'] as int? ?? 0,
    entregadas: json['entregadas'] as int? ?? 0,
    pendientesPorCalificar: json['pendientesPorCalificar'] as int? ?? 0,
  );
}