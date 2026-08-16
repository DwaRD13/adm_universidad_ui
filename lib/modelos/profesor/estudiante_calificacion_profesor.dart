class EstudianteCalificacionProfesor {
  const EstudianteCalificacionProfesor({
    required this.inscripcionId,
    required this.estudianteId,
    required this.nombre,
    required this.nota,
  });

  final int inscripcionId;
  final int estudianteId;
  final String nombre;
  final num? nota;

  factory EstudianteCalificacionProfesor.desdeJson(
    Map<String, dynamic> json,
  ) =>
      EstudianteCalificacionProfesor(
        inscripcionId:
            json['inscripcionId'] as int,
        estudianteId:
            json['estudianteId'] as int,
        nombre:
            json['nombre'] as String? ?? '',
        nota:
            json['nota'] as num?,
      );
}