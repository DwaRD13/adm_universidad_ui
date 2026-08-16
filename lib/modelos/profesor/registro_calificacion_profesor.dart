class RegistroCalificacionProfesor {
  RegistroCalificacionProfesor({
    required this.inscripcionId,
    this.nota,
  });

  final int inscripcionId;
  double? nota;

  Map<String, dynamic> aJson() => {
        'inscripcionId': inscripcionId,
        'nota': nota,
      };
}