import 'package:flutter/material.dart';
import '../modelos/carrera.dart';
import '../servicios/admin_servicio.dart';

class CarrerasProveedor extends ChangeNotifier {
  final AdminServicio _admin;

  CarrerasProveedor({required AdminServicio admin}) : _admin = admin;

  bool _cargando = false;
  bool get cargando => _cargando;
  String? _error;
  String? get error => _error;

  List<Carrera> _carreras = [];
  List<Carrera> get carreras => _carreras;

  String _textoBusqueda = '';
  List<Carrera> _todasLasCarreras = [];

  Future<void> cargar({bool silencioso = false}) async {
    if (!silencioso) {
      _cargando = true;
      _error = null;
      notifyListeners();
    }
    try {
      final data = await _admin.get('/carreras') as List;
      _todasLasCarreras = data
          .map((e) => Carrera.fromJson(e as Map<String, dynamic>))
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

  void filtrar(String texto) {
    _textoBusqueda = texto.toLowerCase();
    _aplicarFiltro();
    notifyListeners();
  }

  void _aplicarFiltro() {
    if (_textoBusqueda.isEmpty) {
      _carreras = _todasLasCarreras;
    } else {
      _carreras = _todasLasCarreras
          .where(
            (c) =>
                c.nombre.toLowerCase().contains(_textoBusqueda) ||
                c.codigo.toLowerCase().contains(_textoBusqueda),
          )
          .toList();
    }
  }
}
