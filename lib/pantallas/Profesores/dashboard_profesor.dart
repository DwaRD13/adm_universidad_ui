import 'package:adm_universidad_ui/widgets/estado_vista.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../app/tema.dart';
import '../../nucleo/excepciones.dart';
import '../../proveedores/sesion_proveedor.dart';
import '../../servicios/profesor_servicio.dart';
import '../../widgets/comunes.dart';

import '../../modelos/profesor/resumen_dashboard_profesor.dart';
import '../../modelos/profesor/seccion_profesor.dart';

class DashboardProfesor extends StatefulWidget {
  const DashboardProfesor({super.key});

  @override
  State<DashboardProfesor> createState() =>
      _DashboardProfesorState();
}

class _DashboardProfesorState
    extends State<DashboardProfesor> {
  late final ProfesorServicio _servicio;

  bool _cargando = true;
  String? _error;

  ResumenDashboardProfesor? _resumen;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_cargando &&
        _resumen == null &&
        _error == null) {
      _servicio = ProfesorServicio(
        context
            .read<SesionProveedor>()
            .api,
      );

      _cargar();
    }
  }

  Future<void> _cargar() async {
    if (!mounted) return;

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final resumen =
          await _servicio.dashboard();

      if (mounted) {
        setState(() {
          _resumen = resumen;
        });
      }
    } on ErrorApi catch (e) {
      if (mounted) {
        setState(() {
          _error = e.mensaje;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error =
              'No se pudo cargar el panel.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuario =
        context.watch<SesionProveedor>()
            .usuario;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _cargar,
          child: _cargando &&
                  _resumen == null
              ? CargandoSkeleton(
                  lineas: 5,
                  altura: 110,
                )
              : _error != null
                  ? Center(
                      child: Padding(
                        padding:
                            const EdgeInsets.all(
                          24,
                        ),
                        child: Column(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons
                                  .cloud_off_rounded,
                              size: 64,
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Text(_error!),
                            const SizedBox(
                              height: 16,
                            ),
                            FilledButton.icon(
                              onPressed: _cargar,
                              icon: const Icon(
                                Icons.refresh,
                              ),
                              label: const Text(
                                'Reintentar',
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ContenidoCentrado(
                      child: ListView(
                        padding:
                            const EdgeInsets
                                .fromLTRB(
                          16,
                          8,
                          16,
                          32,
                        ),
                        children: [
                          TarjetaHero(
                            child:
                                _SaludoProfesor(
                              nombre:
                                  usuario?.nombres ??
                                      '',
                              periodo:
                                  _resumen!
                                      .periodo,
                            ),
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          _FilaIndicadoresProfesor(
                            resumen:
                                _resumen!,
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          const EncabezadoSeccion(
                            titulo:
                                'Clases de hoy',
                            subtitulo:
                                'Secciones programadas para hoy',
                          ),

                          const SizedBox(
                            height: 12,
                          ),

                          if (_resumen!
                              .clasesHoy
                              .isEmpty)
                            const Card(
                              child: Padding(
                                padding:
                                    EdgeInsets.all(
                                  20,
                                ),
                                child: Text(
                                  'No tienes clases programadas hoy.',
                                ),
                              ),
                            )
                          else
                            for (
                              var i = 0;
                              i <
                                  _resumen!
                                      .clasesHoy
                                      .length;
                              i++
                            )
                              Padding(
                                padding:
                                    const EdgeInsets
                                        .only(
                                  bottom: 10,
                                ),
                                child:
                                    _TarjetaClaseHoy(
                                  clase:
                                      _resumen!
                                              .clasesHoy[
                                          i],
                                ),
                              ),

                          const SizedBox(
                            height: 20,
                          ),

                          const EncabezadoSeccion(
                            titulo:
                                'Accesos rápidos',
                            subtitulo:
                                'Herramientas del profesor',
                          ),

                          const SizedBox(
                            height: 12,
                          ),

                          _ModulosProfesor(
                            resumen:
                                _resumen!,
                          ),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }
}

class _SaludoProfesor
    extends StatelessWidget {
  const _SaludoProfesor({
    required this.nombre,
    required this.periodo,
  });

  final String nombre;
  final String periodo;

  String get _franja {
    final hora = DateTime.now().hour;

    if (hora < 12) {
      return 'Buenos días';
    }

    if (hora < 19) {
      return 'Buenas tardes';
    }

    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    final colores = context.colores;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                _franja,
                style:
                    context.textos.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                nombre,
                style: context
                    .textos.headlineMedium,
              ),
              const SizedBox(height: 10),
              ChipEstado(
                texto:
                    'Periodo $periodo',
                tono: TonoEstado.info,
                icono:
                    Icons.event_note_rounded,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        AvatarIniciales(
          nombre: nombre,
          radio: 28,
        ),
      ],
    );
  }
}

class _FilaIndicadoresProfesor
    extends StatelessWidget {
  const _FilaIndicadoresProfesor({
    required this.resumen,
  });

  final ResumenDashboardProfesor
      resumen;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _IndicadorProfesor(
            icono:
                Icons.class_rounded,
            valor:
                '${resumen.totalSecciones}',
            etiqueta:
                'Secciones',
            color:
                context.colores.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _IndicadorProfesor(
            icono:
                Icons.people_alt_rounded,
            valor:
                '${resumen.totalEstudiantes}',
            etiqueta:
                'Alumnos',
            color:
                context.estados.info,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _IndicadorProfesor(
            icono:
                Icons.assignment_late_rounded,
            valor:
                '${resumen.tareasPendientesPorCalificar}',
            etiqueta:
                'Pendientes',
            color: context
                .estados.advertencia,
          ),
        ),
      ],
    );
  }
}

class _IndicadorProfesor
    extends StatelessWidget {
  const _IndicadorProfesor({
    required this.icono,
    required this.valor,
    required this.etiqueta,
    required this.color,
  });

  final IconData icono;
  final String valor;
  final String etiqueta;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Icon(
              icono,
              color: color,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              valor,
              style: context
                  .textos.headlineSmall,
            ),
            Text(etiqueta),
          ],
        ),
      ),
    );
  }
}

class _TarjetaClaseHoy extends StatelessWidget {
  const _TarjetaClaseHoy({
    required this.clase,
  });

  final SeccionProfesor clase;

  @override
  Widget build(BuildContext context) {
    final horario = [
      clase.horaInicio,
      clase.horaFin,
    ].whereType<String>().join(' - ');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(
            Icons.school_rounded,
            color: context.colores.primary,
          ),
        ),
        title: Text(
          clase.materia,
          style: context.textos.titleSmall
              ?.copyWith(
            fontWeight:
                FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              horario.isEmpty
                  ? 'Sin horario'
                  : horario,
            ),
            if (clase.aula != null)
              Text(
                'Aula ${clase.aula}',
              ),
          ],
        ),
        trailing: ChipEstado(
          texto:
              '${clase.inscritos} alumnos',
          tono: TonoEstado.info,
        ),
      ),
    );
  }
}

class _ModulosProfesor
    extends StatelessWidget {
  const _ModulosProfesor({
    required this.resumen,
  });

  final ResumenDashboardProfesor
      resumen;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.45,
      children: [
        TarjetaModulo(
          icono:
              Icons.calendar_month_rounded,
          titulo: 'Agenda',
          color:
              context.colores.primary,
          alPulsar: () => context.go(
            Rutas.agendaProfesor,
          ),
        ),
        TarjetaModulo(
          icono:
              Icons.menu_book_rounded,
          titulo: 'Materias',
          color:
              context.estados.info,
          alPulsar: () => context.go(
            Rutas.materiasProfesor,
          ),
        ),
        TarjetaModulo(
          icono:
              Icons.how_to_reg_rounded,
          titulo: 'Asistencia',
          color:
              context.estados.exito,
          alPulsar: () => context.go(
            Rutas.asistenciaProfesor,
          ),
        ),
        TarjetaModulo(
          icono:
              Icons.grade_rounded,
          titulo:
              'Calificaciones',
          color: Colors.orange,
          alPulsar: () => context.go(
            Rutas
                .calificacionesProfesor,
          ),
        ),
        TarjetaModulo(
          icono:
              Icons.assignment_rounded,
          titulo: 'Tareas',
          color: context
              .estados.advertencia,
          insignia: resumen
              .tareasPendientesPorCalificar,
          alPulsar: () => context.go(
            Rutas.tareasProfesor,
          ),
        ),
        TarjetaModulo(
          icono:
              Icons.folder_rounded,
          titulo: 'Materiales',
          color:
              context.colores.tertiary,
          alPulsar: () => context.go(
            Rutas.materialesProfesor,
          ),
        ),
        TarjetaModulo(
          icono:
              Icons.chat_bubble_rounded,
          titulo: 'Mensajes',
          insignia:
              resumen.mensajesSinLeer,
          color:
              context.colores.primary,
          alPulsar: () => context.go(
            Rutas.mensajesProfesor,
          ),
        ),
      ],
    );
  }
}