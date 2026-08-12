import 'package:flutter/material.dart';
import '../modelos/admin_resumen.dart';
import '../servicios/admin_servicio.dart';

class AdminDashboardProveedor extends ChangeNotifier {
  final AdminServicio _admin;

  AdminDashboardProveedor({required AdminServicio admin}) : _admin = admin;

  bool _cargando = false;
  bool get cargando => _cargando;
  String? _error;
  String? get error => _error;

  AdminResumen? _resumen;
  AdminResumen? get resumen => _resumen;

  Future<void> cargar({bool silencioso = false}) async {
    if (!silencioso) {
      _cargando = true;
      _error = null;
      notifyListeners();
    }
    try {
      final data =
          await _admin.get('/dashboard/estadisticas') as Map<String, dynamic>;
      _resumen = AdminResumen.fromJson(data);
      _cargando = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _cargando = false;
      notifyListeners();
    }
  }
}
