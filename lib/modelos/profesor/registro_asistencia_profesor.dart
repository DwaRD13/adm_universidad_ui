class RegistroAsistenciaProfesor {
  RegistroAsistenciaProfesor({
    required this.inscripcionId,
    required this.estado,
    this.observaciones,
  });

  final int inscripcionId;
  String estado;
  String? observaciones;

  Map<String, dynamic> aJson() => {
        'inscripcionId': inscripcionId,
        'estado': estado,
        'observaciones': observaciones,
      };
}