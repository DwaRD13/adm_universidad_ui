import 'package:flutter/material.dart';
import '../modelos/carrera.dart';
import '../modelos/materia.dart';
import '../servicios/admin_servicio.dart';

class MateriasProveedor extends ChangeNotifier {
  final AdminServicio _admin;

  MateriasProveedor({required AdminServicio admin}) : _admin = admin;

  bool _cargando = false;
  bool get cargando => _cargando;
  String? _error;
  String? get error => _error;

  List<Materia> _materias = [];
  List<Materia> get materias => _materias;
  List<Materia> _todasLasMaterias = [];

  List<Carrera> _carreras = [];
  List<Carrera> get carreras => _carreras;
  Carrera? _carreraSeleccionada;
  Carrera? get carreraSeleccionada => _carreraSeleccionada;

  String _textoBusqueda = '';

  Future<void> cargar({bool silencioso = false}) async {
    if (!silencioso) {
      _cargando = true;
      _error = null;
      notifyListeners();
    }
    try {
      final data = await _admin.get('/materias') as List;
      _todasLasMaterias = data
          .map((e) => Materia.fromJson(e as Map<String, dynamic>))
          .toList();
      _aplicarFiltro();
      _cargando = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> cargarCarreras() async {
    try {
      final data = await _admin.get('/carreras') as List;
      _carreras = data
          .map((e) => Carrera.fromJson(e as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (_) {}
  }

  void filtrarTexto(String texto) {
    _textoBusqueda = texto.toLowerCase();
    _aplicarFiltro();
    notifyListeners();
  }

  void filtrarPorCarrera(Carrera? carrera) {
    _carreraSeleccionada = carrera;
    _aplicarFiltro();
    notifyListeners();
  }

  void _aplicarFiltro() {
    var lista = _todasLasMaterias;
    if (_carreraSeleccionada != null) {
      lista = lista
          .where((m) => m.carreraId == _carreraSeleccionada!.id)
          .toList();
    }
    if (_textoBusqueda.isNotEmpty) {
      lista = lista
          .where(
            (m) =>
                m.nombre.toLowerCase().contains(_textoBusqueda) ||
                m.codigo.toLowerCase().contains(_textoBusqueda),
          )
          .toList();
    }
    _materias = lista;
  }
}
