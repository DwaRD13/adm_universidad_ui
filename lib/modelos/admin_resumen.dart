class AdminResumen {
  final int totalCarreras;
  final int totalMaterias;
  final int totalSecciones;
  final int totalInscripciones;
  final int totalEstudiantes; 
  final int totalProfesores;

  AdminResumen({
    required this.totalCarreras,
    required this.totalMaterias,
    required this.totalSecciones,
    required this.totalInscripciones,
    required this.totalEstudiantes,
    required this.totalProfesores,
  });

  factory AdminResumen.fromJson(Map<String, dynamic> json) {
    return AdminResumen(
      totalCarreras: json['totalCarreras'] ?? 0,
      totalMaterias: json['totalMaterias'] ?? 0,
      totalSecciones: json['totalSecciones'] ?? 0,
      totalInscripciones: json['totalInscripciones'] ?? 0,
      totalEstudiantes: json['totalEstudiantes'] ?? 0, 
      totalProfesores: json['totalProfesores'] ?? 0,
    );
  }
}
