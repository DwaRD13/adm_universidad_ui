import 'package:flutter/material.dart';
import '../modelos/inscripcion.dart';
import '../servicios/admin_servicio.dart';

class InscripcionesProveedor extends ChangeNotifier {
  final AdminServicio _admin;

  InscripcionesProveedor({required AdminServicio admin}) : _admin = admin;

  bool _cargando = false;
  bool get cargando => _cargando;
  String? _error;
  String? get error => _error;

  List<Inscripcion> _inscripciones = [];
  List<Inscripcion> get inscripciones => _inscripciones;
  List<Inscripcion> _todasLasInscripciones = [];

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
      final data = await _admin.get('/inscripciones') as List;
      _todasLasInscripciones = data
          .map((e) => Inscripcion.fromJson(e as Map<String, dynamic>))
          .toList();
      _periodos =
          _todasLasInscripciones.map((i) => i.periodo ?? '').toSet().toList()
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
    // Periodos se obtienen en cargar()
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
    var lista = _todasLasInscripciones;
    if (_periodoSeleccionado != null) {
      lista = lista.where((i) => i.periodo == _periodoSeleccionado).toList();
    }
    if (_estadoSeleccionado != null) {
      lista = lista.where((i) => i.estado == _estadoSeleccionado).toList();
    }
    if (_textoBusqueda.isNotEmpty) {
      lista = lista
          .where(
            (i) =>
                (i.estudianteNombre ?? '').toLowerCase().contains(
                  _textoBusqueda,
                ) ||
                (i.codigoMateria ?? '').toLowerCase().contains(_textoBusqueda),
          )
          .toList();
    }
    _inscripciones = lista;
  }
}
