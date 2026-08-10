import '../modelos/academico.dart';
import '../modelos/aula.dart';
import '../modelos/resumen_dashboard.dart';
import '../modelos/usuario.dart';
import '../nucleo/api_cliente.dart';

/// Acceso a todos los endpoints del panel de estudiante.
///
/// Ninguna llamada envía el id del estudiante: el backend lo toma del token, de
/// modo que un estudiante no puede pedir datos de otro ni siquiera manipulando la app.
class EstudianteServicio {
  const EstudianteServicio(this._api);

  final ApiCliente _api;

  static const _base = '/api/estudiante';

  Future<ResumenDashboard> resumen() async {
    final json = await _api.get('$_base/resumen') as Map<String, dynamic>;
    return ResumenDashboard.desdeJson(json);
  }

  Future<List<ClaseHorario>> horario() async {
    final lista = await _api.get('$_base/horario') as List<dynamic>;
    return lista
        .map((e) => ClaseHorario.desdeJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Inscripcion>> inscripciones() async {
    final lista = await _api.get('$_base/inscripciones') as List<dynamic>;
    return lista
        .map((e) => Inscripcion.desdeJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<SeccionDisponible>> seccionesDisponibles() async {
    final lista =
        await _api.get('$_base/secciones-disponibles') as List<dynamic>;
    return lista
        .map((e) => SeccionDisponible.desdeJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Inscripcion> inscribir(int seccionId) async {
    final json =
        await _api.post('$_base/inscripciones', {'seccionId': seccionId})
            as Map<String, dynamic>;
    return Inscripcion.desdeJson(json);
  }

  Future<Inscripcion> retirar(int inscripcionId) async {
    final json =
        await _api.delete('$_base/inscripciones/$inscripcionId')
            as Map<String, dynamic>;
    return Inscripcion.desdeJson(json);
  }

  Future<Calificaciones> calificaciones() async {
    final json =
        await _api.get('$_base/calificaciones') as Map<String, dynamic>;
    return Calificaciones.desdeJson(json);
  }

  Future<Asistencia> asistencias() async {
    final json = await _api.get('$_base/asistencias') as Map<String, dynamic>;
    return Asistencia.desdeJson(json);
  }

  Future<List<Tarea>> tareas() async {
    final lista = await _api.get('$_base/tareas') as List<dynamic>;
    return lista
        .map((e) => Tarea.desdeJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Tarea> entregarTarea(int tareaId, String archivoUrl) async {
    final json =
        await _api.post('$_base/tareas/$tareaId/entrega', {
              'archivoUrl': archivoUrl,
            })
            as Map<String, dynamic>;
    return Tarea.desdeJson(json);
  }

  Future<List<Material>> materiales() async {
    final lista = await _api.get('$_base/materiales') as List<dynamic>;
    return lista
        .map((e) => Material.desdeJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Conversacion>> conversaciones() async {
    final lista = await _api.get('$_base/mensajes') as List<dynamic>;
    return lista
        .map((e) => Conversacion.desdeJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Mensaje>> hilo(int usuarioId) async {
    final lista = await _api.get('$_base/mensajes/$usuarioId') as List<dynamic>;
    return lista
        .map((e) => Mensaje.desdeJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Mensaje> enviarMensaje(
    int destinatarioId,
    String cuerpo, {
    String? asunto,
  }) async {
    final json =
        await _api.post('$_base/mensajes', {
              'destinatarioId': destinatarioId,
              'asunto': asunto,
              'cuerpo': cuerpo,
            })
            as Map<String, dynamic>;
    return Mensaje.desdeJson(json);
  }

  Future<List<Usuario>> contactos() async {
    final lista = await _api.get('$_base/contactos') as List<dynamic>;
    return lista
        .map((e) => Usuario.desdeJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Usuario> perfil() async {
    final json = await _api.get('$_base/perfil') as Map<String, dynamic>;
    return Usuario.desdeJson(json);
  }

  Future<Usuario> actualizarPerfil({
    String? telefono,
    String? passwordActual,
    String? passwordNueva,
  }) async {
    final json =
        await _api.put('$_base/perfil', {
              'telefono': telefono,
              'passwordActual': passwordActual,
              'passwordNueva': passwordNueva,
            })
            as Map<String, dynamic>;
    return Usuario.desdeJson(json);
  }
}
