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

  factory Carrera.fromJson(Map<String, dynamic> json) => Carrera(
    id: json['id'] as int,
    nombre: json['nombre'] as String,
    codigo: json['codigo'] as String,
    descripcion: json['descripcion'] as String?,
    duracionPeriodos: json['duracion_periodos'] as int,
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'nombre': nombre,
    'codigo': codigo,
    'descripcion': descripcion,
    'duracion_periodos': duracionPeriodos,
  };
}
