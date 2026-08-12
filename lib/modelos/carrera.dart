// lib/modelos/carrera.dart
class Carrera {
  final int? id;
  final String nombre;
  final String codigo;
  final String? descripcion;
  final int duracionPeriodos;

  Carrera({
    this.id,
    required this.nombre,
    required this.codigo,
    this.descripcion,
    required this.duracionPeriodos,
  });

  factory Carrera.fromJson(Map<String, dynamic> json) {
    return Carrera(
      id: json['id'] as int?,
      nombre: json['nombre'] as String? ?? '',
      codigo: json['codigo'] as String? ?? '',
      descripcion: json['descripcion'] as String?,
      duracionPeriodos: json['duracionPeriodos'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'codigo': codigo,
      'descripcion': descripcion,
      'duracionPeriodos': duracionPeriodos,
    };
  }

  Carrera copyWith({
    int? id,
    String? nombre,
    String? codigo,
    String? descripcion,
    int? duracionPeriodos,
  }) {
    return Carrera(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      codigo: codigo ?? this.codigo,
      descripcion: descripcion ?? this.descripcion,
      duracionPeriodos: duracionPeriodos ?? this.duracionPeriodos,
    );
  }
}
