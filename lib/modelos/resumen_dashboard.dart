import 'aula.dart';

/// Todo lo que pinta el dashboard, en una sola respuesta del backend.
class ResumenDashboard {
  const ResumenDashboard({
    required this.periodoActivo,
    required this.materiasInscritas,
    required this.creditosInscritos,
    required this.tareasPendientes,
    required this.mensajesSinLeer,
    required this.proximasEntregas,
    required this.promediosPorMateria,
    this.promedioGeneral,
    this.porcentajeAsistencia,
  });

  final String periodoActivo;
  final int materiasInscritas;
  final int creditosInscritos;
  final double? promedioGeneral;
  final double? porcentajeAsistencia;
  final int tareasPendientes;
  final int mensajesSinLeer;
  final List<Tarea> proximasEntregas;
  final List<PromedioMateria> promediosPorMateria;

  /// Sin materias inscritas no hay nada real que mostrar en el dashboard.
  bool get sinActividad => materiasInscritas == 0;

  factory ResumenDashboard.desdeJson(
    Map<String, dynamic> json,
  ) => ResumenDashboard(
    periodoActivo: json['periodoActivo'] as String? ?? '',
    materiasInscritas: json['materiasInscritas'] as int? ?? 0,
    creditosInscritos: json['creditosInscritos'] as int? ?? 0,
    promedioGeneral: (json['promedioGeneral'] as num?)?.toDouble(),
    porcentajeAsistencia: (json['porcentajeAsistencia'] as num?)?.toDouble(),
    tareasPendientes: json['tareasPendientes'] as int? ?? 0,
    mensajesSinLeer: json['mensajesSinLeer'] as int? ?? 0,
    proximasEntregas: (json['proximasEntregas'] as List<dynamic>? ?? const [])
        .map((t) => Tarea.desdeJson(t as Map<String, dynamic>))
        .toList(),
    promediosPorMateria:
        (json['promediosPorMateria'] as List<dynamic>? ?? const [])
            .map((p) => PromedioMateria.desdeJson(p as Map<String, dynamic>))
            .toList(),
  );
}

class PromedioMateria {
  const PromedioMateria({
    required this.materia,
    required this.codigoMateria,
    required this.promedio,
  });

  final String materia;
  final String codigoMateria;
  final double promedio;

  factory PromedioMateria.desdeJson(Map<String, dynamic> json) =>
      PromedioMateria(
        materia: json['materia'] as String? ?? '',
        codigoMateria: json['codigoMateria'] as String? ?? '',
        promedio: (json['promedio'] as num?)?.toDouble() ?? 0,
      );
}
