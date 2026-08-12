import 'package:flutter/material.dart';
import '../modelos/materia.dart';
import '../modelos/seccion.dart';
import '../modelos/usuario.dart';
import '../servicios/admin_servicio.dart';

class SeccionesProveedor extends ChangeNotifier {
  final AdminServicio _admin;

  SeccionesProveedor({required AdminServicio admin}) : _admin = admin;

  bool _cargando = false;
  bool get cargando => _cargando;
  String? _error;
  String? get error => _error;

  List<Seccion> _secciones = [];
  List<Seccion> get secciones => _secciones;
  List<Seccion> _todasLasSecciones = [];

  List<String> _periodos = [];
  List<String> get periodos => _periodos;

  String? _periodoSeleccionado;
  String? get periodoSeleccionado => _periodoSeleccionado;
  String? _estadoSeleccionado;
  String? get estadoSeleccionado => _estadoSeleccionado;
  String _textoBusqueda = '';

  // Catálogos para el formulario de creación
  List<Materia> _materias = [];
  List<Materia> get materias => _materias;
  List<Usuario> _profesores = [];
  List<Usuario> get profesores => _profesores;

  Future<void> cargar({bool silencioso = false}) async {
    if (!silencioso) {
      _cargando = true;
      _error = null;
      notifyListeners();
    }
    try {
      final data = await _admin.get('/secciones') as List;
      _todasLasSecciones = data
          .map((e) => Seccion.fromJson(e as Map<String, dynamic>))
          .toList();
      _periodos = _todasLasSecciones.map((s) => s.periodo).toSet().toList()
        ..sort();
      _aplicarFiltro();
      _cargando = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> cargarCatalogos() async {
    try {
      final materiasData = await _admin.get('/materias') as List;
      _materias = materiasData
          .map((e) => Materia.fromJson(e as Map<String, dynamic>))
          .toList();

      final profesoresData = await _admin.get('/usuarios/rol/profesor') as List;
      _profesores = profesoresData
          .map((e) => Usuario.desdeJson(e as Map<String, dynamic>))
          .toList();

      notifyListeners();
    } catch (e) {
      // Podrías notificar el error o simplemente dejar las listas vacías
      debugPrint('Error cargando catálogos: $e');
    }
  }

  Future<void> crearSeccion(Map<String, dynamic> data) async {
    await _admin.post('/secciones', body: data);
    await cargar();
  }

  Future<Seccion?> obtenerSeccion(int id) async {
    // Buscamos el índice en todas las secciones (sin importar los filtros actuales)
    final index = _todasLasSecciones.indexWhere((s) => s.id == id);

    if (index != -1) return _todasLasSecciones[index];

    try {
      final data = await _admin.get('/secciones/${id}'); 
      return Seccion.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Error obteniendo sección $id: $e');
      return null;
    }
  }

  void filtrarTexto(String texto) {
    _textoBusqueda = texto;
    _aplicarFiltro();
    notifyListeners();
  }

  void filtrarPorPeriodo(String? periodo) {
    _periodoSeleccionado = periodo;
    _aplicarFiltro();
    notifyListeners();
  }

  void filtrarPorEstado(String? estado) {
    _estadoSeleccionado = estado;
    _aplicarFiltro();
    notifyListeners();
  }

  void _aplicarFiltro() {
    _secciones = _todasLasSecciones.where((s) {
      // 1. Filtro de búsqueda por texto
      if (_textoBusqueda.trim().isNotEmpty) {
        final b = _textoBusqueda.toLowerCase();
        final match =
            (s.materiaNombre?.toLowerCase().contains(b) ?? false) ||
            (s.profesorNombre?.toLowerCase().contains(b) ?? false) ||
            (s.aula?.toLowerCase().contains(b) ?? false);
        if (!match) return false;
      }

      // 2. Filtro por periodo
      if (_periodoSeleccionado != null && s.periodo != _periodoSeleccionado) {
        return false;
      }

      // 3. Filtro por estado (Usamos toUpperCase para igualar lo que manda el Backend)
      if (_estadoSeleccionado != null) {
        if (s.estado?.toUpperCase() != _estadoSeleccionado!.toUpperCase()) {
          return false;
        }
      }

      return true;
    }).toList();
  }
}
