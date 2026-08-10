import '../modelos/resumen_dashboard.dart';
import '../servicios/estudiante_servicio.dart';
import 'proveedor_base.dart';

class DashboardProveedor extends ProveedorBase {
  DashboardProveedor(this._servicio);

  final EstudianteServicio _servicio;

  ResumenDashboard? _resumen;

  ResumenDashboard? get resumen => _resumen;

  @override
  Future<void> cargar({bool silencioso = false}) => ejecutar(
    () async => _resumen = await _servicio.resumen(),
    silencioso: silencioso,
  );
}
