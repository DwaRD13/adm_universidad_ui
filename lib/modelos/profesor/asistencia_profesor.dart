class AsistenciaProfesor {
  const AsistenciaProfesor({
    required this.seccionId,
    required this.materia,
    required this.codigoMateria,
    required this.estudiantes,
    this.porcentajePromedio,
  });

  final int seccionId;
  final String materia;
  final String codigoMateria;
  final int estudiantes;
  final double? porcentajePromedio;

  factory AsistenciaProfesor.desdeJson(
    Map<String, dynamic> json,
  ) => AsistenciaProfesor(
        seccionId: json['seccionId'] as int,
        materia: json['materia'] as String? ?? '',
        codigoMateria: json['codigoMateria'] as String? ?? '',
        estudiantes: json['estudiantes'] as int? ?? 0,
        porcentajePromedio:
            (json['porcentajePromedio'] as num?)?.toDouble(),
      );
}