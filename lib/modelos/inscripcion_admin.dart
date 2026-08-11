/// Modelo de inscripción para el panel administrativo.
class InscripcionAdmin {
  const InscripcionAdmin({
    required this.id,
    required this.estado,
    required this.estudianteNombre,
    required this.materiaNombre,
    required this.codigoMateria,
    required this.seccionId,
    required this.periodo,
    this.notaFinal,
    this.fechaInscripcion,
  });

  final int id;
  final String estado;
  final String estudianteNombre;
  final String materiaNombre;
  final String codigoMateria;
  final int seccionId;
  final String periodo;
  final double? notaFinal;
  final DateTime? fechaInscripcion;

  factory InscripcionAdmin.desdeJson(Map<String, dynamic> json) {
    return InscripcionAdmin(
      id: json['id'] as int,
      estado: json['estado'] as String? ?? '',
      estudianteNombre: json['estudiante'] is Map
          ? (json['estudiante']['nombreCompleto'] as String? ?? '')
          : '',
      materiaNombre: json['seccion'] is Map
          ? (json['seccion']['materia']['nombre'] as String? ?? '')
          : '',
      codigoMateria: json['seccion'] is Map
          ? (json['seccion']['materia']['codigo'] as String? ?? '')
          : '',
      seccionId: json['seccion'] is Map
          ? (json['seccion']['id'] as int? ?? 0)
          : 0,
      periodo: json['seccion'] is Map
          ? (json['seccion']['periodo'] as String? ?? '')
          : '',
      notaFinal: json['notaFinal'] != null
          ? (json['notaFinal'] as num).toDouble()
          : null,
      fechaInscripcion: json['fechaInscripcion'] != null
          ? DateTime.parse(json['fechaInscripcion'] as String)
          : null,
    );
  }

  Map<String, dynamic> aJson() => {
    'id': id,
    'estado': estado,
    'estudianteNombre': estudianteNombre,
    'materiaNombre': materiaNombre,
    'codigoMateria': codigoMateria,
    'seccionId': seccionId,
    'periodo': periodo,
    'notaFinal': notaFinal,
    'fechaInscripcion': fechaInscripcion?.toIso8601String(),
  };
}
