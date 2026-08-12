import 'package:flutter/material.dart';
import '../modelos/admin_resumen.dart';
import '../servicios/admin_servicio.dart';

class ReportesProveedor extends ChangeNotifier {
  final AdminServicio _admin;

  ReportesProveedor({required AdminServicio admin}) : _admin = admin;

  bool _cargando = false;
  bool get cargando => _cargando;
  String? _error;
  String? get error => _error;

  AdminResumen? _resumen;
  AdminResumen? get resumen => _resumen;

  Future<void> cargarResumen({bool silencioso = false}) async {
    if (!silencioso) {
      _cargando = true;
      _error = null;
      notifyListeners();
    }
    try {
      final data =
          await _admin.get('/dashboard/estadisticas') as Map<String, dynamic>;
      _resumen = AdminResumen.fromJson(data);
    } catch (e) {
      _error = e.toString();
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }
}
