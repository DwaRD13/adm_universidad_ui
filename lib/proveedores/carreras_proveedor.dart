// lib/proveedores/carreras_proveedor.dart
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

  List<Carrera> _todasLasCarreras = [];
  String _textoBusqueda = '';

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

  Future<Carrera?> obtenerCarrera(int id) async {
    final index = _todasLasCarreras.indexWhere((c) => c.id == id);
    if (index != -1) return _todasLasCarreras[index];

    try {
      final data = await _admin.get('/carreras/$id');
      return Carrera.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Error obteniendo carrera $id: $e');
      return null;
    }
  }

  Future<bool> crearCarrera(Carrera carrera) async {
    try {
      await _admin.post('/carreras', body: carrera.toJson());
      await cargar(silencioso: true);
      return true;
    } catch (e) {
      debugPrint('Error creando carrera: $e');
      return false;
    }
  }

  Future<bool> actualizarCarrera(int id, Carrera carrera) async {
    try {
      await _admin.put('/carreras/$id', body: carrera.toJson());
      await cargar(silencioso: true);
      return true;
    } catch (e) {
      debugPrint('Error actualizando carrera $id: $e');
      return false;
    }
  }

  Future<bool> eliminarCarrera(int id) async {
    try {
      await _admin.delete('/carreras/$id');
      await cargar(silencioso: true);
      return true;
    } catch (e) {
      debugPrint('Error eliminando carrera $id: $e');
      return false;
    }
  }

  void filtrarTexto(String texto) {
    _textoBusqueda = texto.toLowerCase();
    _aplicarFiltro();
    notifyListeners();
  }

  void _aplicarFiltro() {
    if (_textoBusqueda.isEmpty) {
      _carreras = _todasLasCarreras;
    } else {
      _carreras = _todasLasCarreras.where((c) {
        return c.nombre.toLowerCase().contains(_textoBusqueda) ||
            c.codigo.toLowerCase().contains(_textoBusqueda) ||
            (c.descripcion?.toLowerCase().contains(_textoBusqueda) ?? false);
      }).toList();
    }
  }
}
