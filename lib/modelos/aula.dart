/// Modelos del aula virtual: tareas, materiales y mensajería.
library;

DateTime? _fecha(dynamic valor) {
  if (valor == null) return null;
  return DateTime.tryParse(valor as String);
}

double? _decimal(dynamic valor) =>
    valor == null ? null : (valor as num).toDouble();

/// Estados que el backend calcula para cada tarea del estudiante.
enum EstadoTarea {
  pendiente,
  entregada,
  calificada,
  vencida;

  static EstadoTarea desde(String? valor) => switch (valor) {
    'ENTREGADA' => EstadoTarea.entregada,
    'CALIFICADA' => EstadoTarea.calificada,
    'VENCIDA' => EstadoTarea.vencida,
    _ => EstadoTarea.pendiente,
  };

  String get etiqueta => switch (this) {
    EstadoTarea.pendiente => 'Pendiente',
    EstadoTarea.entregada => 'Entregada',
    EstadoTarea.calificada => 'Calificada',
    EstadoTarea.vencida => 'Vencida',
  };
}

class Tarea {
  const Tarea({
    required this.id,
    required this.seccionId,
    required this.materia,
    required this.codigoMateria,
    required this.titulo,
    required this.fechaEntrega,
    required this.estado,
    required this.entregada,
    this.descripcion,
    this.archivoAdjuntoUrl,
    this.fechaEnvio,
    this.archivoEntregadoUrl,
    this.calificacion,
    this.comentariosProfesor,
  });

  final int id;
  final int seccionId;
  final String materia;
  final String codigoMateria;
  final String titulo;
  final String? descripcion;
  final DateTime fechaEntrega;
  final String? archivoAdjuntoUrl;
  final EstadoTarea estado;
  final bool entregada;
  final DateTime? fechaEnvio;
  final String? archivoEntregadoUrl;
  final double? calificacion;
  final String? comentariosProfesor;

  /// Se entregó después de la fecha límite.
  bool get entregaTardia =>
      fechaEnvio != null && fechaEnvio!.isAfter(fechaEntrega);

  factory Tarea.desdeJson(Map<String, dynamic> json) => Tarea(
    id: json['id'] as int,
    seccionId: json['seccionId'] as int,
    materia: json['materia'] as String? ?? '',
    codigoMateria: json['codigoMateria'] as String? ?? '',
    titulo: json['titulo'] as String? ?? '',
    descripcion: json['descripcion'] as String?,
    fechaEntrega: _fecha(json['fechaEntrega']) ?? DateTime.now(),
    archivoAdjuntoUrl: json['archivoAdjuntoUrl'] as String?,
    estado: EstadoTarea.desde(json['estado'] as String?),
    entregada: json['entregada'] as bool? ?? false,
    fechaEnvio: _fecha(json['fechaEnvio']),
    archivoEntregadoUrl: json['archivoEntregadoUrl'] as String?,
    calificacion: _decimal(json['calificacion']),
    comentariosProfesor: json['comentariosProfesor'] as String?,
  );
}

class Material {
  const Material({
    required this.id,
    required this.seccionId,
    required this.materia,
    required this.codigoMateria,
    required this.titulo,
    required this.urlArchivo,
    this.descripcion,
    this.tipoArchivo,
    this.fechaSubida,
  });

  final int id;
  final int seccionId;
  final String materia;
  final String codigoMateria;
  final String titulo;
  final String? descripcion;
  final String? tipoArchivo;
  final String urlArchivo;
  final DateTime? fechaSubida;

  factory Material.desdeJson(Map<String, dynamic> json) => Material(
    id: json['id'] as int,
    seccionId: json['seccionId'] as int,
    materia: json['materia'] as String? ?? '',
    codigoMateria: json['codigoMateria'] as String? ?? '',
    titulo: json['titulo'] as String? ?? '',
    descripcion: json['descripcion'] as String?,
    tipoArchivo: json['tipoArchivo'] as String?,
    urlArchivo: json['urlArchivo'] as String? ?? '',
    fechaSubida: _fecha(json['fechaSubida']),
  );
}

/// Resumen de una conversación para la bandeja de mensajes.
class Conversacion {
  const Conversacion({
    required this.usuarioId,
    required this.nombre,
    required this.rol,
    required this.sinLeer,
    this.ultimoMensaje,
    this.fechaUltimoMensaje,
  });

  final int usuarioId;
  final String nombre;
  final String rol;
  final String? ultimoMensaje;
  final DateTime? fechaUltimoMensaje;
  final int sinLeer;

  factory Conversacion.desdeJson(Map<String, dynamic> json) => Conversacion(
    usuarioId: json['usuarioId'] as int,
    nombre: json['nombre'] as String? ?? '',
    rol: json['rol'] as String? ?? '',
    ultimoMensaje: json['ultimoMensaje'] as String?,
    fechaUltimoMensaje: _fecha(json['fechaUltimoMensaje']),
    sinLeer: (json['sinLeer'] as num?)?.toInt() ?? 0,
  );
}

class Mensaje {
  const Mensaje({
    required this.id,
    required this.remitenteId,
    required this.remitente,
    required this.destinatarioId,
    required this.destinatario,
    required this.cuerpo,
    required this.leido,
    required this.propio,
    this.asunto,
    this.fechaEnvio,
  });

  final int id;
  final int remitenteId;
  final String remitente;
  final int destinatarioId;
  final String destinatario;
  final String? asunto;
  final String cuerpo;
  final bool leido;

  /// Lo envió el usuario autenticado: decide el lado de la burbuja en el chat.
  final bool propio;
  final DateTime? fechaEnvio;

  factory Mensaje.desdeJson(Map<String, dynamic> json) => Mensaje(
    id: json['id'] as int,
    remitenteId: json['remitenteId'] as int,
    remitente: json['remitente'] as String? ?? '',
    destinatarioId: json['destinatarioId'] as int,
    destinatario: json['destinatario'] as String? ?? '',
    asunto: json['asunto'] as String?,
    cuerpo: json['cuerpo'] as String? ?? '',
    leido: json['leido'] as bool? ?? false,
    propio: json['propio'] as bool? ?? false,
    fechaEnvio: _fecha(json['fechaEnvio']),
  );
}
