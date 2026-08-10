import '../modelos/academico.dart';
import '../nucleo/excepciones.dart';
import '../servicios/estudiante_servicio.dart';
import 'proveedor_base.dart';

/// Catálogo de secciones abiertas y las inscripciones del estudiante.
///
/// Tras inscribirse o retirarse se recargan ambas listas desde el servidor en
/// lugar de modificarlas en memoria: el cupo puede haber cambiado por otro usuario.
class InscripcionProveedor extends ProveedorBase {
  InscripcionProveedor(this._servicio);

  final EstudianteServicio _servicio;

  List<SeccionDisponible> _disponibles = const [];
  List<Inscripcion> _misInscripciones = const [];
  String _busqueda = '';
  String? _carreraFiltro;

  /// Id de la sección sobre la que hay una acción en curso, para el spinner del botón.
  int? _seccionEnProceso;
  int? _inscripcionEnProceso;

  List<Inscripcion> get misInscripciones => _misInscripciones;
  int? get seccionEnProceso => _seccionEnProceso;
  int? get inscripcionEnProceso => _inscripcionEnProceso;
  String get busqueda => _busqueda;
  String? get carreraFiltro => _carreraFiltro;

  /// Carreras presentes en el catálogo, para el filtro.
  List<String> get carreras {
    final nombres =
        _disponibles.map((s) => s.carrera).whereType<String>().toSet().toList()
          ..sort();
    return nombres;
  }

  /// Catálogo tras aplicar búsqueda y filtro de carrera.
  List<SeccionDisponible> get disponibles {
    final texto = _busqueda.trim().toLowerCase();
    return _disponibles.where((s) {
      final coincideCarrera =
          _carreraFiltro == null || s.carrera == _carreraFiltro;
      if (!coincideCarrera) return false;
      if (texto.isEmpty) return true;
      return s.materia.toLowerCase().contains(texto) ||
          s.codigoMateria.toLowerCase().contains(texto) ||
          s.profesor.toLowerCase().contains(texto);
    }).toList();
  }

  List<Inscripcion> get inscripcionesActivas =>
      _misInscripciones.where((i) => i.estaActiva).toList();

  void buscar(String texto) {
    _busqueda = texto;
    notifyListeners();
  }

  void filtrarPorCarrera(String? carrera) {
    _carreraFiltro = carrera;
    notifyListeners();
  }

  @override
  Future<void> cargar({bool silencioso = false}) => ejecutar(() async {
    final resultados = await Future.wait([
      _servicio.seccionesDisponibles(),
      _servicio.inscripciones(),
    ]);
    _disponibles = resultados[0] as List<SeccionDisponible>;
    _misInscripciones = resultados[1] as List<Inscripcion>;
  }, silencioso: silencioso);

  /// Devuelve null si todo fue bien, o el mensaje de error para mostrarlo.
  Future<String?> inscribir(int seccionId) async {
    _seccionEnProceso = seccionId;
    notifyListeners();
    try {
      await _servicio.inscribir(seccionId);
      await cargar(silencioso: true);
      return null;
    } on ErrorApi catch (e) {
      return e.mensaje;
    } finally {
      _seccionEnProceso = null;
      notifyListeners();
    }
  }

  Future<String?> retirar(int inscripcionId) async {
    _inscripcionEnProceso = inscripcionId;
    notifyListeners();
    try {
      await _servicio.retirar(inscripcionId);
      await cargar(silencioso: true);
      return null;
    } on ErrorApi catch (e) {
      return e.mensaje;
    } finally {
      _inscripcionEnProceso = null;
      notifyListeners();
    }
  }
}
