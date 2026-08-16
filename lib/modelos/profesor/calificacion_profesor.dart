class CalificacionProfesor {
  const CalificacionProfesor({
    required this.seccionId,
    required this.materia,
    required this.codigoMateria,
    required this.estudiantes,
    required this.aprobados,
    required this.reprobados,
    this.promedio,
  });

  final int seccionId;
  final String materia;
  final String codigoMateria;
  final int estudiantes;
  final int aprobados;
  final int reprobados;
  final double? promedio;

  factory CalificacionProfesor.desdeJson(
    Map<String, dynamic> json,
  ) => CalificacionProfesor(
        seccionId: json['seccionId'] as int,
        materia: json['materia'] as String? ?? '',
        codigoMateria: json['codigoMateria'] as String? ?? '',
        estudiantes: json['estudiantes'] as int? ?? 0,
        aprobados: json['aprobados'] as int? ?? 0,
        reprobados: json['reprobados'] as int? ?? 0,
        promedio: (json['promedio'] as num?)?.toDouble(),
      );
}