import '../modelos/profesor/conversacion.dart';
import '../modelos/profesor/entrega_profesor.dart';
import '../modelos/profesor/material_profesor.dart';
import '../modelos/profesor/mensaje.dart';
import '../modelos/profesor/resumen_dashboard_profesor.dart';
import '../modelos/profesor/seccion_profesor.dart';
import '../modelos/profesor/tarea_profesor.dart';
import '../modelos/usuario.dart';
import '../nucleo/api_cliente.dart';
import '../modelos/profesor/materia_profesor.dart';
import '../modelos/profesor/asistencia_profesor.dart';
import '../modelos/profesor/calificacion_profesor.dart';
import '../modelos/profesor/estudiante_asistencia_profesor.dart';
import '../modelos/profesor/registro_asistencia_profesor.dart';
import '../modelos/profesor/estudiante_calificacion_profesor.dart';
import '../modelos/profesor/registro_calificacion_profesor.dart';


class ProfesorServicio {
  const ProfesorServicio(this._api);

  final ApiCliente _api;

  Future<ResumenDashboardProfesor> dashboard() async {
    final json = await _api.get('/api/profesor/dashboard') as Map<String, dynamic>;
    return ResumenDashboardProfesor.desdeJson(json);
  }

  Future<List<SeccionProfesor>> secciones() async {
    final json = await _api.get('/api/profesor/secciones') as List<dynamic>;
    return json.map((e) => SeccionProfesor.desdeJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<MateriaProfesor>> materias() async {
    final json = await _api.get('/api/profesor/materias') as List<dynamic>;
    return json.map((e) => MateriaProfesor.desdeJson(e as Map<String, dynamic>,),).toList();
    }
  
  Future<List<AsistenciaProfesor>> asistencia() async {
  final json = await _api.get('/api/profesor/asistencia') as List<dynamic>;
      return json.map((e) => AsistenciaProfesor.desdeJson(e as Map<String, dynamic>,),).toList();
}

Future<List<EstudianteAsistenciaProfesor>> estudiantesDeSeccion(int seccionId, DateTime fecha) async {
  final json = await _api.get('/api/profesor/secciones/$seccionId/estudiantes'
'?fecha=${fecha.toIso8601String().split('T').first}',) as List<dynamic>;
  return json.map((e) => EstudianteAsistenciaProfesor.desdeJson(e as Map<String, dynamic>,),).toList();
}

Future<List<CalificacionProfesor>> calificaciones() async {
  final json = await _api.get('/api/profesor/calificaciones') as List<dynamic>;
      return json.map((e) => CalificacionProfesor.desdeJson(e as Map<String, dynamic>,),).toList();
}

Future<List<EstudianteCalificacionProfesor>>calificacionesSeccion(int seccionId,) async {
  final json = await _api.get('/api/profesor/secciones/$seccionId/calificaciones',) as List<dynamic>;
  return json.map((e) => EstudianteCalificacionProfesor.desdeJson(e as Map<String, dynamic>,),).toList();
}

Future<void> registrarAsistencia({
  required int seccionId,
  required DateTime fecha,
  required List<RegistroAsistenciaProfesor> registros,
}) async {
    await _api.post('/api/profesor/asistencia',{
      'seccionId': seccionId,
      'fecha': fecha.toIso8601String().split('T').first,
      'registros': registros.map((e) => e.aJson()).toList(),
    },
  );
}

Future<void> registrarCalificaciones({
  required int seccionId,
  required List<
          RegistroCalificacionProfesor>
      registros,
}) async {
  await _api.post(
    '/api/profesor/calificaciones',
    {
      'seccionId': seccionId,
      'registros':
          registros.map((e) => e.aJson()).toList(),
    },
  );
}

  Future<List<Usuario>> contactos() async {
    final json = await _api.get('/api/profesor/contactos') as List<dynamic>;
    return json.map((e) => Usuario.desdeJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<TareaProfesor>> tareas() async {
    final json = await _api.get('/api/profesor/tareas') as List<dynamic>;
    return json.map((e) => TareaProfesor.desdeJson(e as Map<String, dynamic>)).toList();
  }

  Future<TareaProfesor> crearTarea({
    required int seccionId,
    required String titulo,
    String? descripcion,
    required DateTime fechaEntrega,
    String? archivoAdjuntoUrl,
  }) async {
    final json = await _api.post('/api/profesor/tareas', {
      'seccionId': seccionId,
      'titulo': titulo,
      'descripcion': descripcion,
      'fechaEntrega': fechaEntrega.toIso8601String(),
      'archivoAdjuntoUrl': archivoAdjuntoUrl,
    }) as Map<String, dynamic>;
    return TareaProfesor.desdeJson(json);
  }

  Future<TareaProfesor> actualizarTarea({
    required int tareaId,
    required int seccionId,
    required String titulo,
    String? descripcion,
    required DateTime fechaEntrega,
    String? archivoAdjuntoUrl,
  }) async {
    final json = await _api.put('/api/profesor/tareas/$tareaId', {
      'seccionId': seccionId,
      'titulo': titulo,
      'descripcion': descripcion,
      'fechaEntrega': fechaEntrega.toIso8601String(),
      'archivoAdjuntoUrl': archivoAdjuntoUrl,
    }) as Map<String, dynamic>;
    return TareaProfesor.desdeJson(json);
  }

  Future<void> eliminarTarea(int tareaId) async {
    await _api.delete('/api/profesor/tareas/$tareaId');
  }

  Future<List<EntregaProfesor>> entregas(int tareaId) async {
    final json = await _api.get('/api/profesor/tareas/$tareaId/entregas') as List<dynamic>;
    return json.map((e) => EntregaProfesor.desdeJson(e as Map<String, dynamic>)).toList();
  }

  Future<EntregaProfesor> calificar({
    required int entregaId,
    required double calificacion,
    String? comentarios,
  }) async {
    final json = await _api.put('/api/profesor/entregas/$entregaId/calificar', {
      'calificacion': calificacion,
      'comentarios': comentarios,
    }) as Map<String, dynamic>;
    return EntregaProfesor.desdeJson(json);
  }

  Future<List<MaterialProfesor>> materiales() async {
    final json = await _api.get('/api/profesor/materiales') as List<dynamic>;
    return json.map((e) => MaterialProfesor.desdeJson(e as Map<String, dynamic>)).toList();
  }

  Future<MaterialProfesor> crearMaterial({
    required int seccionId,
    required String titulo,
    String? descripcion,
    String? tipoArchivo,
    required String urlArchivo,
  }) async {
    final json = await _api.post('/api/profesor/materiales', {
      'seccionId': seccionId,
      'titulo': titulo,
      'descripcion': descripcion,
      'tipoArchivo': tipoArchivo,
      'urlArchivo': urlArchivo,
    }) as Map<String, dynamic>;
    return MaterialProfesor.desdeJson(json);
  }

  Future<MaterialProfesor> actualizarMaterial({
    required int materialId,
    required int seccionId,
    required String titulo,
    String? descripcion,
    String? tipoArchivo,
    required String urlArchivo,
  }) async {
    final json = await _api.put('/api/profesor/materiales/$materialId', {
      'seccionId': seccionId,
      'titulo': titulo,
      'descripcion': descripcion,
      'tipoArchivo': tipoArchivo,
      'urlArchivo': urlArchivo,
    }) as Map<String, dynamic>;
    return MaterialProfesor.desdeJson(json);
  }

  Future<void> eliminarMaterial(int materialId) async {
    await _api.delete('/api/profesor/materiales/$materialId');
  }

  Future<List<Conversacion>> conversaciones() async {
    final json = await _api.get('/api/profesor/mensajes') as List<dynamic>;
    return json.map((e) => Conversacion.desdeJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Mensaje>> hilo(int otroId) async {
    final json = await _api.get('/api/profesor/mensajes/$otroId') as List<dynamic>;
    return json.map((e) => Mensaje.desdeJson(e as Map<String, dynamic>)).toList();
  }

  Future<Mensaje> enviarMensaje({
    required int destinatarioId,
    String? asunto,
    required String cuerpo,
  }) async {
    final json = await _api.post('/api/profesor/mensajes', {
      'destinatarioId': destinatarioId,
      'asunto': asunto,
      'cuerpo': cuerpo,
    }) as Map<String, dynamic>;
    return Mensaje.desdeJson(json);
  }

  Future<String> subirArchivo(List<int> bytes, String nombreArchivo) async {
    final json = await _api.subirArchivo('/api/archivos', bytes, nombreArchivo)
        as Map<String, dynamic>;
    return json['url'] as String;
  }
}