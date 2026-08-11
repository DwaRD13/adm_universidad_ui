import 'package:flutter/material.dart';
import '../modelos/seccion.dart';
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
    // Los periodos ya se obtienen en cargar().
  }

  void filtrarTexto(String texto) {
    _textoBusqueda = texto.toLowerCase();
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
    var lista = _todasLasSecciones;
    if (_periodoSeleccionado != null) {
      lista = lista.where((s) => s.periodo == _periodoSeleccionado).toList();
    }
    if (_estadoSeleccionado != null) {
      lista = lista.where((s) => s.estado == _estadoSeleccionado).toList();
    }
    if (_textoBusqueda.isNotEmpty) {
      lista = lista
          .where(
            (s) =>
                (s.materiaNombre ?? '').toLowerCase().contains(
                  _textoBusqueda,
                ) ||
                (s.profesorNombre ?? '').toLowerCase().contains(
                  _textoBusqueda,
                ) ||
                (s.aula ?? '').toLowerCase().contains(_textoBusqueda),
          )
          .toList();
    }
    _secciones = lista;
  }
}
