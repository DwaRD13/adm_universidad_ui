import '../modelos/aula.dart';
import '../modelos/usuario.dart';
import '../nucleo/excepciones.dart';
import '../servicios/estudiante_servicio.dart';
import 'proveedor_base.dart';

class MensajesProveedor extends ProveedorBase {
  MensajesProveedor(this._servicio);

  final EstudianteServicio _servicio;

  List<Conversacion> _conversaciones = const [];
  List<Usuario> _contactos = const [];

  /// Hilo abierto actualmente, indexado por el id del interlocutor.
  List<Mensaje> _hilo = const [];
  int? _interlocutorActual;
  bool _cargandoHilo = false;
  bool _enviando = false;

  List<Conversacion> get conversaciones => _conversaciones;
  List<Usuario> get contactos => _contactos;
  List<Mensaje> get hilo => _hilo;
  int? get interlocutorActual => _interlocutorActual;
  bool get cargandoHilo => _cargandoHilo;
  bool get enviando => _enviando;
  bool get vacio => _conversaciones.isEmpty;

  int get totalSinLeer =>
      _conversaciones.fold(0, (suma, c) => suma + c.sinLeer);

  @override
  Future<void> cargar({bool silencioso = false}) => ejecutar(() async {
    final resultados = await Future.wait([
      _servicio.conversaciones(),
      _servicio.contactos(),
    ]);
    _conversaciones = resultados[0] as List<Conversacion>;
    _contactos = resultados[1] as List<Usuario>;
  }, silencioso: silencioso);

  /// Abre el hilo con un usuario. El backend marca como leídos sus mensajes.
  Future<void> abrirHilo(int usuarioId) async {
    _interlocutorActual = usuarioId;
    _cargandoHilo = true;
    _hilo = const [];
    notifyListeners();

    try {
      _hilo = await _servicio.hilo(usuarioId);
      // La bandeja cambia al marcarse como leídos, así que se refresca en silencio.
      await cargar(silencioso: true);
    } on ErrorApi {
      _hilo = const [];
    } finally {
      _cargandoHilo = false;
      notifyListeners();
    }
  }

  void cerrarHilo() {
    _interlocutorActual = null;
    _hilo = const [];
  }

  /// Devuelve null si el mensaje se envió, o el error para mostrarlo.
  Future<String?> enviar(
    int destinatarioId,
    String cuerpo, {
    String? asunto,
  }) async {
    _enviando = true;
    notifyListeners();

    try {
      final mensaje = await _servicio.enviarMensaje(
        destinatarioId,
        cuerpo,
        asunto: asunto,
      );
      // Se añade al final del hilo abierto para que aparezca sin esperar recarga.
      if (_interlocutorActual == destinatarioId) {
        _hilo = [..._hilo, mensaje];
      }
      await cargar(silencioso: true);
      return null;
    } on ErrorApi catch (e) {
      return e.mensaje;
    } catch (_) {
      return 'No se pudo enviar el mensaje. Inténtalo de nuevo.';
    } finally {
      _enviando = false;
      notifyListeners();
    }
  }

  /// Nombre del interlocutor, buscándolo en conversaciones o contactos.
  String nombreDe(int usuarioId) {
    for (final conversacion in _conversaciones) {
      if (conversacion.usuarioId == usuarioId) return conversacion.nombre;
    }
    for (final contacto in _contactos) {
      if (contacto.id == usuarioId) return contacto.nombreCompleto;
    }
    return 'Conversación';
  }
}
