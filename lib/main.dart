import 'package:adm_universidad_ui/proveedores/admin_dashboard_proveedor.dart';
import 'package:adm_universidad_ui/proveedores/carreras_proveedor.dart';
import 'package:adm_universidad_ui/proveedores/inscripciones_proveedor.dart';
import 'package:adm_universidad_ui/proveedores/materias_proveedor.dart';
import 'package:adm_universidad_ui/proveedores/reportes_proveedor.dart';
import 'package:adm_universidad_ui/proveedores/secciones_proveedor.dart';
import 'package:adm_universidad_ui/proveedores/usuarios_proveedor.dart';
import 'package:adm_universidad_ui/servicios/admin_servicio.dart';
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
import 'proveedores/calificaciones_profesor_proveedor.dart';
import 'proveedores/materias_profesor_proveedor.dart';
import 'proveedores/asistencia_profesor_proveedor.dart';
import 'proveedores/sesion_proveedor.dart';
import 'proveedores/tareas_proveedor.dart';
import 'proveedores/tema_proveedor.dart';
import 'servicios/archivo_servicio.dart';
import 'servicios/auth_servicio.dart';
import 'servicios/estudiante_servicio.dart';
import 'servicios/profesor_servicio.dart';



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
  late final ProfesorServicio _profesor = ProfesorServicio(_api);
  late final ArchivoServicio _archivos = ArchivoServicio(_api);
  late final SesionProveedor _sesion = SesionProveedor(
    api: _api,
    auth: AuthServicio(_api),
  );
  late final AdminServicio _admin = AdminServicio(_api);
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
        ChangeNotifierProvider(create: (_) => MateriasProfesorProveedor(_profesor),),
        ChangeNotifierProvider(create: (_) => AsistenciaProfesorProveedor(_profesor),),
        ChangeNotifierProvider(create: (_) => CalificacionesProfesorProveedor(_profesor),),

        Provider<AdminServicio>(create: (_) => _admin),
        
        Provider<ProfesorServicio>.value(value: _profesor,),
        // Administrativo
        ChangeNotifierProvider(
          create: (_) => AdminDashboardProveedor(admin: _admin),
        ),
        ChangeNotifierProvider(create: (_) => CarrerasProveedor(admin: _admin)),
        ChangeNotifierProvider(create: (_) => MateriasProveedor(admin: _admin)),
        ChangeNotifierProvider(
          create: (_) => SeccionesProveedor(admin: _admin),
        ),
        ChangeNotifierProvider(
          create: (_) => InscripcionesProveedor(admin: _admin),
        ),
        ChangeNotifierProvider(create: (_) => ReportesProveedor(admin: _admin)),
        ChangeNotifierProvider(create: (_) => UsuariosProveedor(admin: _admin)),
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
