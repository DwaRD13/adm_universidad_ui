class Seccion {
  final int? id;
  final int materiaId;
  final String materiaNombre;
  final int profesorId;
  final String profesorNombre;
  final String periodo;
  final int cupoMaximo;
  final String? aula;
  final String? horarioDescripcion;
  final String estado;
  final int inscritos;

  Seccion({
    this.id,
    required this.materiaId,
    required this.materiaNombre,
    required this.profesorId,
    required this.profesorNombre,
    required this.periodo,
    required this.cupoMaximo,
    this.aula,
    this.horarioDescripcion,
    required this.estado,
    this.inscritos = 0,
  });

  factory Seccion.fromJson(Map<String, dynamic> json) {
    return Seccion(
      id: json['id'] as int?,
      materiaId: json['materiaId'] as int? ?? 0,
      materiaNombre: json['materiaNombre'] as String? ?? '',
      profesorId: json['profesorId'] as int? ?? 0,
      profesorNombre: json['profesorNombre'] as String? ?? '',
      periodo: json['periodo'] as String? ?? '',
      cupoMaximo: json['cupoMaximo'] as int? ?? 0,
      aula: json['aula'] as String?,
      horarioDescripcion: json['horarioDescripcion'] as String?,
      estado: json['estado'] as String? ?? '',
      inscritos: json['inscritos'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'materiaId': materiaId,
      'materiaNombre': materiaNombre,
      'profesorId': profesorId,
      'profesorNombre': profesorNombre,
      'periodo': periodo,
      'cupoMaximo': cupoMaximo,
      'aula': aula,
      'horarioDescripcion': horarioDescripcion,
      'estado': estado,
      'inscritos': inscritos,
    };
  }
}
