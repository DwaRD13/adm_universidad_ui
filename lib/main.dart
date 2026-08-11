import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'app/router.dart';
import 'app/tema.dart';
import 'nucleo/api_cliente.dart';
import 'proveedores/asistencia_proveedor.dart';
import 'proveedores/calificaciones_proveedor.dart';
import 'proveedores/dashboard_proveedor.dart';
import 'proveedores/horario_proveedor.dart';
import 'proveedores/inscripcion_proveedor.dart';
import 'proveedores/materiales_proveedor.dart';
import 'proveedores/mensajes_proveedor.dart';
import 'proveedores/perfil_proveedor.dart';
import 'proveedores/sesion_proveedor.dart';
import 'proveedores/tareas_proveedor.dart';
import 'proveedores/tema_proveedor.dart';
import 'servicios/archivo_servicio.dart';
import 'servicios/auth_servicio.dart';
import 'servicios/estudiante_servicio.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Necesario para que intl formatee fechas y días de la semana en español.
  await initializeDateFormatting('es');

  runApp(const UniConnectApp());
}

class UniConnectApp extends StatefulWidget {
  const UniConnectApp({super.key});

  @override
  State<UniConnectApp> createState() => _UniConnectAppState();
}

class _UniConnectAppState extends State<UniConnectApp> {
  // El cliente HTTP y los servicios se crean una sola vez y se comparten:
  // así el token vive en un único sitio.
  final ApiCliente _api = ApiCliente();
  late final EstudianteServicio _estudiante = EstudianteServicio(_api);
  late final ArchivoServicio _archivos = ArchivoServicio(_api);
  late final SesionProveedor _sesion = SesionProveedor(
    api: _api,
    auth: AuthServicio(_api),
  );
  late final TemaProveedor _tema = TemaProveedor();
  late final GoRouter _router = crearRouter(_sesion);

  // Los dos temas se resuelven una sola vez: el `Consumer` de abajo reconstruye
  // en cada cambio de modo y no tiene sentido rearmarlos (con sus fuentes) ahí.
  final ThemeData _temaClaro = TemaApp.claro();
  final ThemeData _temaOscuro = TemaApp.oscuro();

  @override
  void initState() {
    super.initState();
    _tema.restaurar();
    _sesion.restaurar();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _sesion),
        ChangeNotifierProvider.value(value: _tema),
        ChangeNotifierProvider(create: (_) => DashboardProveedor(_estudiante)),
        ChangeNotifierProvider(create: (_) => HorarioProveedor(_estudiante)),
        ChangeNotifierProvider(
          create: (_) => InscripcionProveedor(_estudiante),
        ),
        ChangeNotifierProvider(
          create: (_) => CalificacionesProveedor(_estudiante),
        ),
        ChangeNotifierProvider(create: (_) => AsistenciaProveedor(_estudiante)),
        ChangeNotifierProvider(
          create: (_) => TareasProveedor(_estudiante, _archivos),
        ),
        ChangeNotifierProvider(create: (_) => MaterialesProveedor(_estudiante)),
        ChangeNotifierProvider(create: (_) => MensajesProveedor(_estudiante)),
        ChangeNotifierProvider(create: (_) => PerfilProveedor(_estudiante)),
      ],
      child: Consumer<TemaProveedor>(
        builder: (context, tema, _) => MaterialApp.router(
          title: 'UniConnect',
          debugShowCheckedModeBanner: false,
          theme: _temaClaro,
          darkTheme: _temaOscuro,
          themeMode: tema.modo,
          routerConfig: _router,
        ),
      ),
    );
  }
}
