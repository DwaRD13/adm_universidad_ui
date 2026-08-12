import 'seccion_profesor.dart';

class ResumenDashboardProfesor {
  const ResumenDashboardProfesor({
    required this.periodo,
    required this.totalSecciones,
    required this.totalEstudiantes,
    required this.tareasPendientesPorCalificar,
    required this.mensajesSinLeer,
    required this.clasesHoy,
  });

  final String periodo;
  final int totalSecciones;
  final int totalEstudiantes;
  final int tareasPendientesPorCalificar;
  final int mensajesSinLeer;
  final List<SeccionProfesor> clasesHoy;

  factory ResumenDashboardProfesor.desdeJson(Map<String, dynamic> json) =>
      ResumenDashboardProfesor(
        periodo: json['periodo'] as String? ?? '',
        totalSecciones: json['totalSecciones'] as int? ?? 0,
        totalEstudiantes: json['totalEstudiantes'] as int? ?? 0,
        tareasPendientesPorCalificar: json['tareasPendientesPorCalificar'] as int? ?? 0,
        mensajesSinLeer: json['mensajesSinLeer'] as int? ?? 0,
        clasesHoy: (json['clasesHoy'] as List<dynamic>? ?? [])
            .map((e) => SeccionProfesor.desdeJson(e as Map<String, dynamic>))
            .toList(),
      );
}