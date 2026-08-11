// Si ActividadReciente usa íconos, necesitas importar material.dart
import 'package:flutter/material.dart';

class AdminResumen {
  final int totalEstudiantes;
  final int estudiantesActivos;
  final int totalProfesores;
  final int profesoresActivos;
  final int seccionesActivas;
  final List<ActividadReciente> ultimasActividades;

  AdminResumen({
    required this.totalEstudiantes,
    required this.estudiantesActivos,
    required this.totalProfesores,
    required this.profesoresActivos,
    required this.seccionesActivas,
    required this.ultimasActividades,
  });

  factory AdminResumen.fromJson(Map<String, dynamic> json) {
    return AdminResumen(
      totalEstudiantes: json['totalEstudiantes'] ?? 0,
      estudiantesActivos: json['estudiantesActivos'] ?? 0,
      totalProfesores: json['totalProfesores'] ?? 0,
      profesoresActivos: json['profesoresActivos'] ?? 0,
      seccionesActivas: json['seccionesActivas'] ?? 0,
      ultimasActividades:
          (json['ultimasActividades'] as List<dynamic>?)
              ?.map((e) => ActividadReciente.fromJson(e))
              .toList() ??
          [],
    );
  }
}


class ActividadReciente {
  final IconData icono;
  final String titulo;
  final String descripcion;
  final String hora;

  ActividadReciente({
    required this.icono,
    required this.titulo,
    required this.descripcion,
    required this.hora,
  });

  factory ActividadReciente.fromJson(Map<String, dynamic> json) {
    return ActividadReciente(
      icono: _obtenerIcono(json['icono']),
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      hora: json['hora'] ?? '',
    );
  }

  static IconData _obtenerIcono(String? nombreIcono) {
    return Icons.notifications;
  }
}
