/// Modelos del área académica del estudiante: horario, inscripciones,
/// calificaciones y asistencia. Cada uno refleja un DTO del backend.
library;

/// Convierte una fecha ISO del backend; devuelve null si viene vacía.
DateTime? _fecha(dynamic valor) {
  if (valor == null) return null;
  return DateTime.tryParse(valor as String);
}

/// Los decimales llegan como num y se normalizan a double para la interfaz.
double? _decimal(dynamic valor) =>
    valor == null ? null : (valor as num).toDouble();

/// Una clase del horario semanal. Días y horas vienen ya interpretados del backend.
class ClaseHorario {
  const ClaseHorario({
    required this.inscripcionId,
    required this.seccionId,
    required this.materia,
    required this.codigoMateria,
    required this.creditos,
    required this.profesor,
    required this.dias,
    this.aula,
    this.periodo,
    this.horarioDescripcion,
    this.horaInicio,
    this.horaFin,
  });

  final int inscripcionId;
  final int seccionId;
  final String materia;
  final String codigoMateria;
  final int creditos;
  final String profesor;
  final String? aula;
  final String? periodo;
  final String? horarioDescripcion;

  /// Códigos de día: Lu, Ma, Mi, Ju, Vi, Sa.
  final List<String> dias;
  final String? horaInicio;
  final String? horaFin;

  String get rangoHorario {
    if (horaInicio == null) return horarioDescripcion ?? 'Horario por definir';
    if (horaFin == null) return horaInicio!;
    return '$horaInicio - $horaFin';
  }

  factory ClaseHorario.desdeJson(Map<String, dynamic> json) => ClaseHorario(
    inscripcionId: json['inscripcionId'] as int,
    seccionId: json['seccionId'] as int,
    materia: json['materia'] as String? ?? '',
    codigoMateria: json['codigoMateria'] as String? ?? '',
    creditos: json['creditos'] as int? ?? 0,
    profesor: json['profesor'] as String? ?? '',
    aula: json['aula'] as String?,
    periodo: json['periodo'] as String?,
    horarioDescripcion: json['horarioDescripcion'] as String?,
    dias: (json['dias'] as List<dynamic>? ?? const [])
        .map((d) => '$d')
        .toList(),
    horaInicio: json['horaInicio'] as String?,
    horaFin: json['horaFin'] as String?,
  );
}

/// Sección del catálogo de inscripción, con su cupo real.
class SeccionDisponible {
  const SeccionDisponible({
    required this.seccionId,
    required this.materia,
    required this.codigoMateria,
    required this.creditos,
    required this.profesor,
    required this.cupoMaximo,
    required this.cupoOcupado,
    required this.cupoDisponible,
    required this.yaInscrito,
    this.carrera,
    this.aula,
    this.periodo,
    this.horarioDescripcion,
  });

  final int seccionId;
  final String materia;
  final String codigoMateria;
  final int creditos;
  final String? carrera;
  final String profesor;
  final String? aula;
  final String? periodo;
  final String? horarioDescripcion;
  final int cupoMaximo;
  final int cupoOcupado;
  final int cupoDisponible;
  final bool yaInscrito;

  bool get sinCupo => cupoDisponible <= 0;

  /// Proporción de plazas ocupadas (0..1), para la barra de cupo.
  double get ocupacion =>
      cupoMaximo == 0 ? 0 : (cupoOcupado / cupoMaximo).clamp(0.0, 1.0);

  factory SeccionDisponible.desdeJson(Map<String, dynamic> json) =>
      SeccionDisponible(
        seccionId: json['seccionId'] as int,
        materia: json['materia'] as String? ?? '',
        codigoMateria: json['codigoMateria'] as String? ?? '',
        creditos: json['creditos'] as int? ?? 0,
        carrera: json['carrera'] as String?,
        profesor: json['profesor'] as String? ?? '',
        aula: json['aula'] as String?,
        periodo: json['periodo'] as String?,
        horarioDescripcion: json['horarioDescripcion'] as String?,
        cupoMaximo: json['cupoMaximo'] as int? ?? 0,
        cupoOcupado: json['cupoOcupado'] as int? ?? 0,
        cupoDisponible: json['cupoDisponible'] as int? ?? 0,
        yaInscrito: json['yaInscrito'] as bool? ?? false,
      );
}

/// Una inscripción del estudiante en una sección.
class Inscripcion {
  const Inscripcion({
    required this.id,
    required this.seccionId,
    required this.materia,
    required this.codigoMateria,
    required this.creditos,
    required this.profesor,
    this.aula,
    this.periodo,
    this.horarioDescripcion,
    this.estado,
    this.fechaInscripcion,
  });

  final int id;
  final int seccionId;
  final String materia;
  final String codigoMateria;
  final int creditos;
  final String profesor;
  final String? aula;
  final String? periodo;
  final String? horarioDescripcion;
  final String? estado;
  final DateTime? fechaInscripcion;

  bool get estaActiva => estado == 'Inscrito';
  bool get puedeRetirarse => estado == 'Inscrito';

  factory Inscripcion.desdeJson(Map<String, dynamic> json) => Inscripcion(
    id: json['id'] as int,
    seccionId: json['seccionId'] as int,
    materia: json['materia'] as String? ?? '',
    codigoMateria: json['codigoMateria'] as String? ?? '',
    creditos: json['creditos'] as int? ?? 0,
    profesor: json['profesor'] as String? ?? '',
    aula: json['aula'] as String?,
    periodo: json['periodo'] as String?,
    horarioDescripcion: json['horarioDescripcion'] as String?,
    estado: json['estado'] as String?,
    fechaInscripcion: _fecha(json['fechaInscripcion']),
  );
}

/// Calificaciones publicadas con el promedio ya calculado por el backend.
class Calificaciones {
  const Calificaciones({
    required this.materiasAprobadas,
    required this.materiasReprobadas,
    required this.calificaciones,
    this.promedioGeneral,
  });

  final double? promedioGeneral;
  final int materiasAprobadas;
  final int materiasReprobadas;
  final List<Calificacion> calificaciones;

  bool get vacio => calificaciones.isEmpty;

  factory Calificaciones.desdeJson(Map<String, dynamic> json) => Calificaciones(
    promedioGeneral: _decimal(json['promedioGeneral']),
    materiasAprobadas: json['materiasAprobadas'] as int? ?? 0,
    materiasReprobadas: json['materiasReprobadas'] as int? ?? 0,
    calificaciones: (json['calificaciones'] as List<dynamic>? ?? const [])
        .map((c) => Calificacion.desdeJson(c as Map<String, dynamic>))
        .toList(),
  );
}

class Calificacion {
  const Calificacion({
    required this.id,
    required this.materia,
    required this.codigoMateria,
    required this.creditos,
    required this.profesor,
    required this.periodo,
    required this.nota,
    this.literal,
    this.estadoInscripcion,
    this.fechaPublicacion,
  });

  final int id;
  final String materia;
  final String codigoMateria;
  final int creditos;
  final String profesor;
  final String periodo;
  final double nota;
  final String? literal;
  final String? estadoInscripcion;
  final DateTime? fechaPublicacion;

  bool get aprobada => estadoInscripcion == 'Aprobado';
  bool get reprobada => estadoInscripcion == 'Reprobado';

  factory Calificacion.desdeJson(Map<String, dynamic> json) => Calificacion(
    id: json['id'] as int,
    materia: json['materia'] as String? ?? '',
    codigoMateria: json['codigoMateria'] as String? ?? '',
    creditos: json['creditos'] as int? ?? 0,
    profesor: json['profesor'] as String? ?? '',
    periodo: json['periodo'] as String? ?? '',
    nota: _decimal(json['nota']) ?? 0,
    literal: json['literal'] as String?,
    estadoInscripcion: json['estadoInscripcion'] as String?,
    fechaPublicacion: _fecha(json['fechaPublicacion']),
  );
}

/// Asistencia agrupada por materia.
class Asistencia {
  const Asistencia({
    required this.totalClases,
    required this.materias,
    this.porcentajeGeneral,
  });

  final double? porcentajeGeneral;
  final int totalClases;
  final List<MateriaAsistencia> materias;

  bool get vacio => totalClases == 0;

  factory Asistencia.desdeJson(Map<String, dynamic> json) => Asistencia(
    porcentajeGeneral: _decimal(json['porcentajeGeneral']),
    totalClases: json['totalClases'] as int? ?? 0,
    materias: (json['materias'] as List<dynamic>? ?? const [])
        .map((m) => MateriaAsistencia.desdeJson(m as Map<String, dynamic>))
        .toList(),
  );
}

class MateriaAsistencia {
  const MateriaAsistencia({
    required this.inscripcionId,
    required this.materia,
    required this.codigoMateria,
    required this.profesor,
    required this.totalClases,
    required this.presentes,
    required this.ausentes,
    required this.tardanzas,
    required this.excusas,
    required this.registros,
    this.porcentaje,
  });

  final int inscripcionId;
  final String materia;
  final String codigoMateria;
  final String profesor;
  final int totalClases;
  final int presentes;
  final int ausentes;
  final int tardanzas;
  final int excusas;
  final double? porcentaje;
  final List<RegistroAsistencia> registros;

  factory MateriaAsistencia.desdeJson(Map<String, dynamic> json) =>
      MateriaAsistencia(
        inscripcionId: json['inscripcionId'] as int,
        materia: json['materia'] as String? ?? '',
        codigoMateria: json['codigoMateria'] as String? ?? '',
        profesor: json['profesor'] as String? ?? '',
        totalClases: json['totalClases'] as int? ?? 0,
        presentes: json['presentes'] as int? ?? 0,
        ausentes: json['ausentes'] as int? ?? 0,
        tardanzas: json['tardanzas'] as int? ?? 0,
        excusas: json['excusas'] as int? ?? 0,
        porcentaje: _decimal(json['porcentaje']),
        registros: (json['registros'] as List<dynamic>? ?? const [])
            .map((r) => RegistroAsistencia.desdeJson(r as Map<String, dynamic>))
            .toList(),
      );
}

class RegistroAsistencia {
  const RegistroAsistencia({
    required this.id,
    required this.fecha,
    required this.estado,
    this.observaciones,
  });

  final int id;
  final DateTime fecha;
  final String estado;
  final String? observaciones;

  factory RegistroAsistencia.desdeJson(Map<String, dynamic> json) =>
      RegistroAsistencia(
        id: json['id'] as int,
        fecha: _fecha(json['fecha']) ?? DateTime.now(),
        estado: json['estado'] as String? ?? '',
        observaciones: json['observaciones'] as String?,
      );
}
