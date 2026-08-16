class EstudianteAsistenciaProfesor {
  const EstudianteAsistenciaProfesor({
    required this.inscripcionId,
    required this.estudianteId,
    required this.nombre,
    required this.estado,
    this.observaciones,
  });

  final int inscripcionId;
  final int estudianteId;
  final String nombre;
  final String estado;
  final String? observaciones;

  factory EstudianteAsistenciaProfesor.desdeJson(
    Map<String, dynamic> json,
  ) =>
      EstudianteAsistenciaProfesor(
        inscripcionId: json['inscripcionId'] as int,
        estudianteId: json['estudianteId'] as int,
        nombre: json['nombre'] as String? ?? '',
        estado:
            json['estado'] as String? ?? 'PRESENTE',
        observaciones:
            json['observaciones'] as String?,
      );
}