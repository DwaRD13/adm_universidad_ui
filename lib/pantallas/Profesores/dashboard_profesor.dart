import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';

/// ============================================================
/// DASHBOARD DEL PROFESOR
/// ============================================================
///
/// Dashboard principal del módulo de profesores.
///
/// La navegación utiliza GoRouter y las rutas definidas en:
/// lib/app/router.dart
///
/// Rutas disponibles:
/// /profesor
/// /profesor/agenda
/// /profesor/tareas
/// /profesor/materiales
/// /profesor/mensajes
///
class DashboardProfesor extends StatelessWidget {
  const DashboardProfesor({super.key});

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Panel de Docente',
        ),

        actions: [
          IconButton(
            tooltip: 'Mensajes',
            icon: const Icon(
              Icons.notifications_none_rounded,
            ),
            onPressed: () {
              context.go(Rutas.mensajesProfesor);
            },
          ),

          const SizedBox(width: 8),
        ],
      ),

      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),

        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Center(
            child: Container(
              width: double.infinity,

              constraints: const BoxConstraints(
                maxWidth: 1000,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  // ==================================================
                  // BIENVENIDA
                  // ==================================================

                  Container(
                    width: double.infinity,

                    padding: const EdgeInsets.all(24),

                    decoration: BoxDecoration(
                      color: colores.primaryContainer,
                      borderRadius:
                          BorderRadius.circular(18),
                    ),

                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.center,

                      children: [
                        Container(
                          width: 64,
                          height: 64,

                          decoration: BoxDecoration(
                            color: colores.primary,
                            shape: BoxShape.circle,
                          ),

                          child: Icon(
                            Icons.person_rounded,
                            color: colores.onPrimary,
                            size: 34,
                          ),
                        ),

                        const SizedBox(width: 18),

                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [
                            Text(
                              '¡Bienvenido de nuevo!',
                              style:
                                  textos.bodyMedium?.copyWith(
                                color:
                                    colores.onPrimaryContainer,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              'Profesor',
                              style:
                                  textos.headlineSmall?.copyWith(
                                fontWeight:
                                    FontWeight.bold,
                                color:
                                    colores.onPrimaryContainer,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              'Administra tus clases y actividades.',
                              style:
                                  textos.bodySmall?.copyWith(
                                color:
                                    colores.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ==================================================
                  // NAVEGACIÓN
                  // ==================================================

                  Text(
                    'Módulos',
                    style: textos.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Accede rápidamente a las diferentes secciones.',
                    style: textos.bodyMedium?.copyWith(
                      color:
                          colores.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // AGENDA
                  // ==================================================

                  _BotonNavegacion(
                    icono: Icons.calendar_month_rounded,
                    titulo: 'Agenda',
                    descripcion:
                        'Consulta y administra tus horarios.',
                    color: colores.primary,
                    onTap: () {
                      context.go(
                        Rutas.agendaProfesor,
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // ==================================================
                  // TAREAS
                  // ==================================================

                  _BotonNavegacion(
                    icono:
                        Icons.assignment_rounded,
                    titulo: 'Tareas',
                    descripcion:
                        'Gestiona tareas y actividades.',
                    color: colores.secondary,
                    onTap: () {
                      context.go(
                        Rutas.tareasProfesor,
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // ==================================================
                  // MATERIALES
                  // ==================================================

                  _BotonNavegacion(
                    icono:
                        Icons.folder_rounded,
                    titulo: 'Materiales',
                    descripcion:
                        'Administra los recursos de tus clases.',
                    color: colores.tertiary,
                    onTap: () {
                      context.go(
                        Rutas.materialesProfesor,
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // ==================================================
                  // MENSAJES
                  // ==================================================

                  _BotonNavegacion(
                    icono:
                        Icons.message_rounded,
                    titulo: 'Mensajes',
                    descripcion:
                        'Consulta y responde tus mensajes.',
                    color: colores.primary,
                    onTap: () {
                      context.go(
                        Rutas.mensajesProfesor,
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // ==================================================
                  // RESUMEN
                  // ==================================================

                  Text(
                    'Resumen',
                    style: textos.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Información general de tu actividad.',
                    style: textos.bodyMedium?.copyWith(
                      color:
                          colores.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // ASIGNATURAS
                  // ==================================================

                  _TarjetaResumen(
                    icono:
                        Icons.menu_book_rounded,
                    valor: '3',
                    titulo: 'Asignaturas',
                    color:
                        colores.primary,
                  ),

                  const SizedBox(height: 12),

                  // ==================================================
                  // ESTUDIANTES
                  // ==================================================

                  _TarjetaResumen(
                    icono:
                        Icons.groups_rounded,
                    valor: '85',
                    titulo: 'Estudiantes',
                    color:
                        colores.secondary,
                  ),

                  const SizedBox(height: 12),

                  // ==================================================
                  // PENDIENTES
                  // ==================================================

                  _TarjetaResumen(
                    icono:
                        Icons.assignment_late_rounded,
                    valor: '12',
                    titulo:
                        'Actividades pendientes',
                    color:
                        colores.tertiary,
                  ),

                  const SizedBox(height: 32),

                  // ==================================================
                  // CLASES DE HOY
                  // ==================================================

                  Text(
                    'Clases de hoy',
                    style: textos.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Tus próximas clases programadas.',
                    style: textos.bodyMedium?.copyWith(
                      color:
                          colores.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // CLASE 1
                  // ==================================================

                  _TarjetaClase(
                    materia:
                        'Programación Orientada a Objetos',
                    horario:
                        '08:00 AM - 10:00 AM',
                    aula:
                        'Aula A-204',
                    estudiantes:
                        '28 estudiantes',
                  ),

                  const SizedBox(height: 12),

                  // ==================================================
                  // CLASE 2
                  // ==================================================

                  _TarjetaClase(
                    materia:
                        'Bases de Datos II',
                    horario:
                        '10:15 AM - 12:15 PM',
                    aula:
                        'Laboratorio L-102',
                    estudiantes:
                        '32 estudiantes',
                  ),

                  const SizedBox(height: 32),

                  // ==================================================
                  // ACCIONES RÁPIDAS
                  // ==================================================

                  Text(
                    'Acciones rápidas',
                    style: textos.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  _BotonNavegacion(
                    icono:
                        Icons.assignment_turned_in_rounded,
                    titulo:
                        'Gestionar tareas',
                    descripcion:
                        'Revisa las actividades pendientes.',
                    color:
                        colores.primary,
                    onTap: () {
                      context.go(
                        Rutas.tareasProfesor,
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  _BotonNavegacion(
                    icono:
                        Icons.upload_file_rounded,
                    titulo:
                        'Gestionar materiales',
                    descripcion:
                        'Administra los recursos de tus clases.',
                    color:
                        colores.secondary,
                    onTap: () {
                      context.go(
                        Rutas.materialesProfesor,
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  _BotonNavegacion(
                    icono:
                        Icons.chat_rounded,
                    titulo:
                        'Ver mensajes',
                    descripcion:
                        'Revisa tus conversaciones.',
                    color:
                        colores.tertiary,
                    onTap: () {
                      context.go(
                        Rutas.mensajesProfesor,
                      );
                    },
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// BOTÓN DE NAVEGACIÓN
// ============================================================

class _BotonNavegacion extends StatelessWidget {
  const _BotonNavegacion({
    required this.icono,
    required this.titulo,
    required this.descripcion,
    required this.color,
    required this.onTap,
  });

  final IconData icono;
  final String titulo;
  final String descripcion;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colores =
        Theme.of(context).colorScheme;
    final textos =
        Theme.of(context).textTheme;

    return Material(
      color: colores.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),

      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(16),

        child: Container(
          width: double.infinity,

          padding: const EdgeInsets.all(18),

          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(16),

            border: Border.all(
              color:
                  colores.outlineVariant,
            ),
          ),

          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,

                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius:
                      BorderRadius.circular(14),
                ),

                child: Icon(
                  icono,
                  color: color,
                  size: 27,
                ),
              ),

              const SizedBox(width: 16),

              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    titulo,
                    style:
                        textos.titleMedium?.copyWith(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    descripcion,
                    style:
                        textos.bodySmall?.copyWith(
                      color:
                          colores.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 17,
                color:
                    colores.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// TARJETA DE RESUMEN
// ============================================================

class _TarjetaResumen extends StatelessWidget {
  const _TarjetaResumen({
    required this.icono,
    required this.valor,
    required this.titulo,
    required this.color,
  });

  final IconData icono;
  final String valor;
  final String titulo;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colores =
        Theme.of(context).colorScheme;
    final textos =
        Theme.of(context).textTheme;

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color:
            colores.surfaceContainerHighest,

        borderRadius:
            BorderRadius.circular(16),

        border: Border.all(
          color:
              colores.outlineVariant,
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,

            decoration: BoxDecoration(
              color:
                  color.withOpacity(0.12),

              borderRadius:
                  BorderRadius.circular(12),
            ),

            child: Icon(
              icono,
              color: color,
              size: 26,
            ),
          ),

          const SizedBox(width: 16),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Text(
                valor,
                style:
                    textos.headlineMedium?.copyWith(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              Text(
                titulo,
                style:
                    textos.bodyMedium?.copyWith(
                  color:
                      colores.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// TARJETA DE CLASE
// ============================================================

class _TarjetaClase extends StatelessWidget {
  const _TarjetaClase({
    required this.materia,
    required this.horario,
    required this.aula,
    required this.estudiantes,
  });

  final String materia;
  final String horario;
  final String aula;
  final String estudiantes;

  @override
  Widget build(BuildContext context) {
    final colores =
        Theme.of(context).colorScheme;
    final textos =
        Theme.of(context).textTheme;

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: colores.surface,

        borderRadius:
            BorderRadius.circular(16),

        border: Border.all(
          color:
              colores.outlineVariant,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Text(
            materia,
            style:
                textos.titleMedium?.copyWith(
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 18,
                color:
                    colores.onSurfaceVariant,
              ),

              const SizedBox(width: 8),

              Text(
                horario,
                style:
                    textos.bodyMedium?.copyWith(
                  color:
                      colores.onSurfaceVariant,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Icon(
                Icons.room_rounded,
                size: 18,
                color:
                    colores.onSurfaceVariant,
              ),

              const SizedBox(width: 8),

              Text(
                aula,
                style:
                    textos.bodyMedium?.copyWith(
                  color:
                      colores.onSurfaceVariant,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),

            decoration: BoxDecoration(
              color:
                  Colors.green.withOpacity(0.12),

              borderRadius:
                  BorderRadius.circular(20),
            ),

            child: Text(
              estudiantes,
              style: const TextStyle(
                color: Colors.green,
                fontWeight:
                    FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}