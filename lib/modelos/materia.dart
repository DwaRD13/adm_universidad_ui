class Materia {
  final int? id;
  final int? carreraId;
  final String nombre;
  final String codigo;
  final int creditos;
  final String? carreraNombre; // campo calculado / join

  Materia({
    this.id,
    this.carreraId,
    required this.nombre,
    required this.codigo,
    required this.creditos,
    this.carreraNombre,
  });

  factory Materia.fromJson(Map<String, dynamic> json) => Materia(
    id: json['id'] as int?,
    carreraId: json['carrera_id'] as int?,
    nombre: json['nombre'] as String,
    codigo: json['codigo'] as String,
    creditos: json['creditos'] as int,
    carreraNombre: json['carrera_nombre'] as String?,
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'carrera_id': carreraId,
    'nombre': nombre,
    'codigo': codigo,
    'creditos': creditos,
    'carrera_nombre': carreraNombre,
  };
}
