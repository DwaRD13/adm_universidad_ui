import 'package:adm_universidad_ui/pantallas/administrativo/carreras/carreras_pantalla.dart';
import 'package:adm_universidad_ui/pantallas/administrativo/dashboard/admin_dashboard_pantalla.dart';
import 'package:adm_universidad_ui/pantallas/administrativo/inscripciones/inscripciones_pantalla.dart';
import 'package:adm_universidad_ui/pantallas/administrativo/materias/materias_pantalla.dart';
import 'package:adm_universidad_ui/pantallas/administrativo/reportes/reportes_pantalla.dart';
import 'package:adm_universidad_ui/pantallas/administrativo/secciones/secciones_pantalla.dart';
import 'package:adm_universidad_ui/pantallas/administrativo/usuarios/usuarios_pantalla.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../pantallas/arranque_pantalla.dart';
import '../pantallas/estudiante/asistencia/asistencia_pantalla.dart';
import '../pantallas/estudiante/calificaciones/calificaciones_pantalla.dart';
import '../pantallas/estudiante/cascaron.dart';
import '../pantallas/estudiante/dashboard/dashboard_pantalla.dart';
import '../pantallas/estudiante/horario/horario_pantalla.dart';
import '../pantallas/estudiante/inscripcion/inscripcion_pantalla.dart';
import '../pantallas/estudiante/materiales/materiales_pantalla.dart';
import '../pantallas/estudiante/mensajes/hilo_pantalla.dart';
import '../pantallas/estudiante/mensajes/mensajes_pantalla.dart';
import '../pantallas/estudiante/perfil/perfil_pantalla.dart';
import '../pantallas/estudiante/tareas/tareas_pantalla.dart';
import '../pantallas/login/login_pantalla.dart';
import '../pantallas/rol_pendiente_pantalla.dart';
import '../proveedores/sesion_proveedor.dart';

/// Rutas de la aplicación.
class Rutas {
  const Rutas._();

  // Genéricas
  static const arranque = '/';
  static const login = '/login';
  static const rolPendiente = '/rol-pendiente';

  // Estudiante
  static const dashboard = '/estudiante';
  static const horario = '/estudiante/horario';
  static const calificaciones = '/estudiante/calificaciones';
  static const mensajes = '/estudiante/mensajes';
  static const perfil = '/estudiante/perfil';
  static const inscripcion = '/estudiante/inscripcion';
  static const asistencia = '/estudiante/asistencia';
  static const tareas = '/estudiante/tareas';
  static const materiales = '/estudiante/materiales';

  static String hilo(int usuarioId) => '/estudiante/mensajes/$usuarioId';

  // Administrativo
  static const adminDashboard = '/admin';
  static const adminUsuarios = '/admin/usuarios';
  static const adminCarreras = '/admin/carreras';
  static const adminMaterias = '/admin/materias';
  static const adminSecciones = '/admin/secciones';
  static const adminInscripciones = '/admin/inscripciones';
  static const adminReportes = '/admin/reportes';

  // Detalles y creación (se deben implementar las pantallas correspondientes)
  static const nuevoUsuario = '/admin/usuarios/nuevo';
  static String detalleUsuario(int id) => '/admin/usuarios/$id';

  static const nuevaCarrera = '/admin/carreras/nueva';
  static String detalleCarrera(int id) => '/admin/carreras/$id';

  static const nuevaMateria = '/admin/materias/nueva';
  static String detalleMateria(int id) => '/admin/materias/$id';

  static const nuevaSeccion = '/admin/secciones/nueva';
  static String detalleSeccion(int id) => '/admin/secciones/$id';

  static String detalleInscripcion(int id) => '/admin/inscripciones/$id';

  // Reportes específicos (puedes cambiar las rutas según tus pantallas)
  static const reporteRendimiento = '/admin/reportes/rendimiento';
  static const reporteAsistencia = '/admin/reportes/asistencia';
  static const reporteInscripciones = '/admin/reportes/inscripciones';
  static const reporteDemografia = '/admin/reportes/demografia';
  static const reporteCargaHoraria = '/admin/reportes/carga-horaria';
  static const reporteCalificaciones = '/admin/reportes/calificaciones';
}

/// Construye el router escuchando a la sesión.
GoRouter crearRouter(SesionProveedor sesion) {
  return GoRouter(
    initialLocation: Rutas.arranque,
    refreshListenable: sesion,
    redirect: (context, estado) {
      final ruta = estado.matchedLocation;

      // Mientras se restaura la sesión guardada no se decide nada.
      if (sesion.comprobando) {
        return ruta == Rutas.arranque ? null : Rutas.arranque;
      }

      if (!sesion.autenticado) {
        return ruta == Rutas.login ? null : Rutas.login;
      }

      final usuario = sesion.usuario!;

      // Redirigir según el rol
      if (usuario.esAdministrativo) {
        // Si ya está en una ruta admin o en login/arranque, permitir (y redirigir a admin si está en login)
        if (ruta.startsWith('/admin') ||
            ruta == Rutas.login ||
            ruta == Rutas.arranque) {
          if (ruta == Rutas.login || ruta == Rutas.arranque) {
            return Rutas.adminDashboard;
          }
          return null; // ya está en admin
        }
        // Si está en rutas de estudiante o rol pendiente, llevarlo al dashboard admin
        return Rutas.adminDashboard;
      }

      if (usuario.esEstudiante) {
        if (ruta.startsWith('/estudiante')) {
          if (ruta == Rutas.login || ruta == Rutas.arranque) {
            return Rutas.dashboard;
          }
          return null;
        }
        if (ruta.startsWith('/admin')) {
          return Rutas.dashboard;
        }
        return ruta == Rutas.login || ruta == Rutas.arranque
            ? Rutas.dashboard
            : null;
      }

      // Profesor u otros roles no implementados → rol pendiente
      return ruta == Rutas.rolPendiente ? null : Rutas.rolPendiente;
    },
    routes: [
      // -----------------------------------------------------------------------
      // Genéricas
      // -----------------------------------------------------------------------
      GoRoute(
        path: Rutas.arranque,
        builder: (_, __) => const ArranquePantalla(),
      ),
      GoRoute(path: Rutas.login, builder: (_, __) => const LoginPantalla()),
      GoRoute(
        path: Rutas.rolPendiente,
        builder: (_, __) => const RolPendientePantalla(),
      ),

      // -----------------------------------------------------------------------
      // Rutas de Estudiante (con barra inferior)
      // -----------------------------------------------------------------------
      ShellRoute(
        builder: (context, estado, hijo) =>
            CascaronEstudiante(rutaActual: estado.matchedLocation, child: hijo),
        routes: [
          GoRoute(
            path: Rutas.dashboard,
            pageBuilder: (_, estado) =>
                _sinTransicion(estado, const DashboardPantalla()),
          ),
          GoRoute(
            path: Rutas.horario,
            pageBuilder: (_, estado) =>
                _sinTransicion(estado, const HorarioPantalla()),
          ),
          GoRoute(
            path: Rutas.calificaciones,
            pageBuilder: (_, estado) =>
                _sinTransicion(estado, const CalificacionesPantalla()),
          ),
          GoRoute(
            path: Rutas.mensajes,
            pageBuilder: (_, estado) =>
                _sinTransicion(estado, const MensajesPantalla()),
          ),
          GoRoute(
            path: Rutas.perfil,
            pageBuilder: (_, estado) =>
                _sinTransicion(estado, const PerfilPantalla()),
          ),
        ],
      ),

      // Módulos secundarios de estudiante
      GoRoute(
        path: Rutas.inscripcion,
        builder: (_, __) => const InscripcionPantalla(),
      ),
      GoRoute(
        path: Rutas.asistencia,
        builder: (_, __) => const AsistenciaPantalla(),
      ),
      GoRoute(path: Rutas.tareas, builder: (_, __) => const TareasPantalla()),
      GoRoute(
        path: Rutas.materiales,
        builder: (_, __) => const MaterialesPantalla(),
      ),
      GoRoute(
        path: '/estudiante/mensajes/:usuarioId',
        builder: (_, estado) => HiloPantalla(
          usuarioId: int.parse(estado.pathParameters['usuarioId']!),
        ),
      ),

      // -----------------------------------------------------------------------
      // Rutas de Administrativo
      // -----------------------------------------------------------------------
      // Dashboard
      GoRoute(
        path: Rutas.adminDashboard,
        builder: (_, __) => const AdminDashboardPantalla(),
      ),

      // Usuarios
      GoRoute(
        path: Rutas.adminUsuarios,
        builder: (_, __) => const UsuariosPantalla(),
      ),
      GoRoute(
        path: Rutas.nuevoUsuario,
        builder: (_, __) =>
            const _PantallaEnConstruccion(titulo: 'Nuevo usuario'),
      ),
      GoRoute(
        path: '/admin/usuarios/:id',
        builder: (_, estado) => _PantallaEnConstruccion(
          titulo: 'Detalle usuario ${estado.pathParameters['id']}',
        ),
      ),

      // Carreras
      GoRoute(
        path: Rutas.adminCarreras,
        builder: (_, __) => const CarrerasPantalla(),
      ),
      GoRoute(
        path: Rutas.nuevaCarrera,
        builder: (_, __) =>
            const _PantallaEnConstruccion(titulo: 'Nueva carrera'),
      ),
      GoRoute(
        path: '/admin/carreras/:id',
        builder: (_, estado) => _PantallaEnConstruccion(
          titulo: 'Detalle carrera ${estado.pathParameters['id']}',
        ),
      ),

      // Materias
      GoRoute(
        path: Rutas.adminMaterias,
        builder: (_, __) => const MateriasPantalla(),
      ),
      GoRoute(
        path: Rutas.nuevaMateria,
        builder: (_, __) =>
            const _PantallaEnConstruccion(titulo: 'Nueva materia'),
      ),
      GoRoute(
        path: '/admin/materias/:id',
        builder: (_, estado) => _PantallaEnConstruccion(
          titulo: 'Detalle materia ${estado.pathParameters['id']}',
        ),
      ),

      // Secciones
      GoRoute(
        path: Rutas.adminSecciones,
        builder: (_, __) => const SeccionesPantalla(),
      ),
      GoRoute(
        path: Rutas.nuevaSeccion,
        builder: (_, __) =>
            const _PantallaEnConstruccion(titulo: 'Nueva sección'),
      ),
      GoRoute(
        path: '/admin/secciones/:id',
        builder: (_, estado) => _PantallaEnConstruccion(
          titulo: 'Detalle sección ${estado.pathParameters['id']}',
        ),
      ),

      // Inscripciones
      GoRoute(
        path: Rutas.adminInscripciones,
        builder: (_, __) => const InscripcionesPantalla(),
      ),
      GoRoute(
        path: '/admin/inscripciones/:id',
        builder: (_, estado) => _PantallaEnConstruccion(
          titulo: 'Detalle inscripción ${estado.pathParameters['id']}',
        ),
      ),

      // Reportes
      GoRoute(
        path: Rutas.adminReportes,
        builder: (_, __) => const ReportesPantalla(),
      ),
      // Reportes específicos (placeholder)
      GoRoute(
        path: Rutas.reporteRendimiento,
        builder: (_, __) =>
            const _PantallaEnConstruccion(titulo: 'Rendimiento académico'),
      ),
      GoRoute(
        path: Rutas.reporteAsistencia,
        builder: (_, __) => const _PantallaEnConstruccion(titulo: 'Asistencia'),
      ),
      GoRoute(
        path: Rutas.reporteInscripciones,
        builder: (_, __) =>
            const _PantallaEnConstruccion(titulo: 'Inscripciones'),
      ),
      GoRoute(
        path: Rutas.reporteDemografia,
        builder: (_, __) => const _PantallaEnConstruccion(titulo: 'Demografía'),
      ),
      GoRoute(
        path: Rutas.reporteCargaHoraria,
        builder: (_, __) =>
            const _PantallaEnConstruccion(titulo: 'Carga horaria'),
      ),
      GoRoute(
        path: Rutas.reporteCalificaciones,
        builder: (_, __) =>
            const _PantallaEnConstruccion(titulo: 'Calificaciones finales'),
      ),
    ],
  );
}

/// Cambiar de pestaña en la barra inferior no debe animar como si fuera una
/// pantalla nueva: se mantiene el cambio instantáneo.
CustomTransitionPage<void> _sinTransicion(GoRouterState estado, Widget hijo) {
  return CustomTransitionPage(
    key: estado.pageKey,
    child: hijo,
    transitionsBuilder: (_, animacion, _, hijo) =>
        FadeTransition(opacity: animacion, child: hijo),
    transitionDuration: const Duration(milliseconds: 180),
  );
}

/// Pantalla de placeholder para rutas aún no implementadas.
/// Reemplázala por las pantallas reales cuando las desarrolles.
class _PantallaEnConstruccion extends StatelessWidget {
  final String titulo;
  const _PantallaEnConstruccion({required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.construction, size: 64, color: Colors.orange),
            SizedBox(height: 16),
            Text('Pantalla en construcción', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
