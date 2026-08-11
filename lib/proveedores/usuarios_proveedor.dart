import 'package:flutter/material.dart';
import '../modelos/usuario_admin.dart';
import '../servicios/admin_servicio.dart';

class UsuariosProveedor extends ChangeNotifier {
  final AdminServicio _admin;

  UsuariosProveedor({required AdminServicio admin}) : _admin = admin;

  bool _cargando = false;
  bool get cargando => _cargando;
  String? _error;
  String? get error => _error;

  List<UsuarioAdmin> _usuarios = [];
  List<UsuarioAdmin> get usuarios => _usuarios;

  List<UsuarioAdmin> _todosLosUsuarios = [];

  String? _filtroRol;
  String? get filtroRol => _filtroRol;

  String? _filtroEstado;
  String? get filtroEstado => _filtroEstado;

  String _textoBusqueda = '';

  Future<void> cargarUsuarios({bool silencioso = false}) async {
    if (!silencioso) {
      _cargando = true;
      _error = null;
      notifyListeners();
    }
    try {
      final data = await _admin.get('/usuarios') as List;
      _todosLosUsuarios = data
          .map((e) => UsuarioAdmin.desdeJson(e as Map<String, dynamic>))
          .toList();
      _aplicarFiltros();
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  void filtrar(String texto) {
    _textoBusqueda = texto.toLowerCase().trim();
    _aplicarFiltros();
    notifyListeners();
  }

  void cambiarFiltroRol(String? rol) {
    _filtroRol = rol;
    _aplicarFiltros();
    notifyListeners();
  }

  void cambiarFiltroEstado(String? estado) {
    _filtroEstado = estado;
    _aplicarFiltros();
    notifyListeners();
  }

  void _aplicarFiltros() {
    var lista = _todosLosUsuarios;
    if (_filtroRol != null) {
      lista = lista.where((u) => u.rol == _filtroRol).toList();
    }
    if (_filtroEstado != null) {
      lista = lista.where((u) => u.estado == _filtroEstado).toList();
    }
    if (_textoBusqueda.isNotEmpty) {
      lista = lista
          .where(
            (u) =>
                u.nombreCompleto.toLowerCase().contains(_textoBusqueda) ||
                u.email.toLowerCase().contains(_textoBusqueda) ||
                (u.matriculaEmpleadoId ?? '').toLowerCase().contains(
                  _textoBusqueda,
                ),
          )
          .toList();
    }
    _usuarios = lista;
  }
}
