/// Espejo de MaterialDto (dto/estudiante). Nombres de campo inferidos del orden de
/// construcción en ServicioMateriales; si algo llega null, confirma el .java real.
class MaterialProfesor {
  const MaterialProfesor({
    required this.id,
    required this.seccionId,
    required this.materia,
    required this.codigoMateria,
    required this.titulo,
    this.descripcion,
    this.tipoArchivo,
    required this.urlArchivo,
    required this.fechaSubida,
  });

  final int id;
  final int seccionId;
  final String materia;
  final String codigoMateria;
  final String titulo;
  final String? descripcion;
  final String? tipoArchivo;
  final String urlArchivo;
  final DateTime fechaSubida;

  factory MaterialProfesor.desdeJson(Map<String, dynamic> json) => MaterialProfesor(
    id: json['id'] as int,
    seccionId: json['seccionId'] as int,
    materia: json['materia'] as String? ?? '',
    codigoMateria: json['codigoMateria'] as String? ?? '',
    titulo: json['titulo'] as String? ?? '',
    descripcion: json['descripcion'] as String?,
    tipoArchivo: json['tipoArchivo'] as String?,
    urlArchivo: json['urlArchivo'] as String? ?? '',
    fechaSubida: DateTime.parse(json['fechaSubida'] as String),
  );
}