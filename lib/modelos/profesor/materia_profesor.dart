class MateriaProfesor {
  const MateriaProfesor({
    required this.seccionId,
    required this.materia,
    required this.codigoMateria,
    required this.creditos,
    required this.periodo,
    this.aula,
    this.estado,
    required this.inscritos,
  });

  final int seccionId;
  final String materia;
  final String codigoMateria;
  final int creditos;
  final String periodo;
  final String? aula;
  final String? estado;
  final int inscritos;

  factory MateriaProfesor.desdeJson(
    Map<String, dynamic> json,
  ) => MateriaProfesor(
        seccionId: json['seccionId'] as int,
        materia: json['materia'] as String? ?? '',
        codigoMateria: json['codigoMateria'] as String? ?? '',
        creditos: json['creditos'] as int? ?? 0,
        periodo: json['periodo'] as String? ?? '',
        aula: json['aula'] as String?,
        estado: json['estado'] as String?,
        inscritos: json['inscritos'] as int? ?? 0,
      );
}