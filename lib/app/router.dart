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

  static const arranque = '/';
  static const login = '/login';
  static const dashboard = '/estudiante';
  static const horario = '/estudiante/horario';
  static const calificaciones = '/estudiante/calificaciones';
  static const mensajes = '/estudiante/mensajes';
  static const perfil = '/estudiante/perfil';
  static const inscripcion = '/estudiante/inscripcion';
  static const asistencia = '/estudiante/asistencia';
  static const tareas = '/estudiante/tareas';
  static const materiales = '/estudiante/materiales';
  static const rolPendiente = '/rol-pendiente';

  static String hilo(int usuarioId) => '/estudiante/mensajes/$usuarioId';
}

/// Construye el router escuchando a la sesión: cuando el usuario entra o sale,
/// `refreshListenable` reevalúa el redirect y lleva a la pantalla correcta.
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

      // Los paneles de Profesor y Administrativo aún no existen.
      final usuario = sesion.usuario!;
      if (!usuario.esEstudiante) {
        return ruta == Rutas.rolPendiente ? null : Rutas.rolPendiente;
      }

      if (ruta == Rutas.login ||
          ruta == Rutas.arranque ||
          ruta == Rutas.rolPendiente) {
        return Rutas.dashboard;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: Rutas.arranque,
        builder: (_, _) => const ArranquePantalla(),
      ),
      GoRoute(path: Rutas.login, builder: (_, _) => const LoginPantalla()),
      GoRoute(
        path: Rutas.rolPendiente,
        builder: (_, _) => const RolPendientePantalla(),
      ),

      // Los cinco destinos de la barra inferior comparten cascarón para que la
      // navegación entre ellos no reconstruya el Scaffold.
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

      // Módulos secundarios: se abren sobre el cascarón, con botón de volver.
      GoRoute(
        path: Rutas.inscripcion,
        builder: (_, _) => const InscripcionPantalla(),
      ),
      GoRoute(
        path: Rutas.asistencia,
        builder: (_, _) => const AsistenciaPantalla(),
      ),
      GoRoute(path: Rutas.tareas, builder: (_, _) => const TareasPantalla()),
      GoRoute(
        path: Rutas.materiales,
        builder: (_, _) => const MaterialesPantalla(),
      ),
      GoRoute(
        path: '/estudiante/mensajes/:usuarioId',
        builder: (_, estado) => HiloPantalla(
          usuarioId: int.parse(estado.pathParameters['usuarioId']!),
        ),
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
