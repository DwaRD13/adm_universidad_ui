class Seccion {
  final int? id;
  final int materiaId;
  final int profesorId;
  final String periodo;
  final int cupoMaximo;
  final String? aula;
  final String? horario;
  final String estado;

  // Campos de visualización (join)
  final String? materiaNombre;
  final String? profesorNombre;
  final int? inscritos;

  Seccion({
    this.id,
    required this.materiaId,
    required this.profesorId,
    required this.periodo,
    required this.cupoMaximo,
    this.aula,
    this.horario,
    required this.estado,
    this.materiaNombre,
    this.profesorNombre,
    this.inscritos,
  });

  factory Seccion.fromJson(Map<String, dynamic> json) => Seccion(
    id: json['id'] as int?,
    materiaId: json['materia_id'] as int,
    profesorId: json['profesor_id'] as int,
    periodo: json['periodo'] as String,
    cupoMaximo: json['cupo_maximo'] as int,
    aula: json['aula'] as String?,
    horario: json['horario_descripcion'] as String?,
    estado: json['estado'] as String,
    materiaNombre: json['materia_nombre'] as String?,
    profesorNombre: json['profesor_nombre'] as String?,
    inscritos: json['inscritos'] as int?,
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'materia_id': materiaId,
    'profesor_id': profesorId,
    'periodo': periodo,
    'cupo_maximo': cupoMaximo,
    'aula': aula,
    'horario_descripcion': horario,
    'estado': estado,
    'materia_nombre': materiaNombre,
    'profesor_nombre': profesorNombre,
    'inscritos': inscritos,
  };
}
