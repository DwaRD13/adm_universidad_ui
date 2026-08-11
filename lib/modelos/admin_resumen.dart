class AdminResumen {
  final int totalEstudiantes;
  final int totalProfesores;
  final int seccionesActivas;

  AdminResumen({
    required this.totalEstudiantes,
    required this.totalProfesores,
    required this.seccionesActivas,
  });

  factory AdminResumen.fromJson(Map<String, dynamic> json) => AdminResumen(
    totalEstudiantes: json['totalEstudiantes'] as int,
    totalProfesores: json['totalProfesores'] as int,
    seccionesActivas: json['seccionesActivas'] as int,
  );
}
