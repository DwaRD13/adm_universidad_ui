class Inscripcion {
  final int? id;
  final int estudianteId;
  final int seccionId;
  final String? fechaInscripcion;
  final String estado;

  // Campos de visualización
  final String? estudianteNombre;
  final String? materiaNombre;
  final String? codigoMateria;
  final String? periodo;
  final double? notaFinal;

  Inscripcion({
    this.id,
    required this.estudianteId,
    required this.seccionId,
    this.fechaInscripcion,
    required this.estado,
    this.estudianteNombre,
    this.materiaNombre,
    this.codigoMateria,
    this.periodo,
    this.notaFinal,
  });

  factory Inscripcion.fromJson(Map<String, dynamic> json) => Inscripcion(
    id: json['id'] as int?,
    estudianteId: json['estudiante_id'] as int,
    seccionId: json['seccion_id'] as int,
    fechaInscripcion: json['fecha_inscripcion'] as String?,
    estado: json['estado'] as String,
    estudianteNombre: json['estudiante_nombre'] as String?,
    materiaNombre: json['materia_nombre'] as String?,
    codigoMateria: json['codigo_materia'] as String?,
    periodo: json['periodo'] as String?,
    notaFinal: (json['nota_numerica'] as num?)?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'estudiante_id': estudianteId,
    'seccion_id': seccionId,
    'fecha_inscripcion': fechaInscripcion,
    'estado': estado,
  };
}
