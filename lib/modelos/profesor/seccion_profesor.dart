class SeccionProfesor {
  const SeccionProfesor({
    required this.seccionId,
    required this.materia,
    required this.codigoMateria,
    required this.creditos,
    required this.periodo,
    this.aula,
    this.horarioDescripcion,
    required this.dias,
    this.horaInicio,
    this.horaFin,
    this.estado,
    required this.cupoMaximo,
    required this.inscritos,
  });

  final int seccionId;
  final String materia;
  final String codigoMateria;
  final int creditos;
  final String periodo;
  final String? aula;
  final String? horarioDescripcion;
  final List<String> dias;
  final String? horaInicio;
  final String? horaFin;
  final String? estado;
  final int cupoMaximo;
  final int inscritos;

  factory SeccionProfesor.desdeJson(Map<String, dynamic> json) => SeccionProfesor(
    seccionId: json['seccionId'] as int,
    materia: json['materia'] as String? ?? '',
    codigoMateria: json['codigoMateria'] as String? ?? '',
    creditos: json['creditos'] as int? ?? 0,
    periodo: json['periodo'] as String? ?? '',
    aula: json['aula'] as String?,
    horarioDescripcion: json['horarioDescripcion'] as String?,
    dias: (json['dias'] as List<dynamic>? ?? []).map((e) => e as String).toList(),
    horaInicio: json['horaInicio'] as String?,
    horaFin: json['horaFin'] as String?,
    estado: json['estado'] as String?,
    cupoMaximo: json['cupoMaximo'] as int? ?? 0,
    inscritos: json['inscritos'] as int? ?? 0,
  );
}