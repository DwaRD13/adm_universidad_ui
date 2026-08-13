import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../modelos/profesor/resumen_dashboard_profesor.dart';
import '../../modelos/profesor/seccion_profesor.dart';
import '../../nucleo/excepciones.dart';
import '../../proveedores/sesion_proveedor.dart';
import '../../servicios/profesor_servicio.dart';
import 'widgets_profesor.dart';

class DashboardProfesor extends StatefulWidget {
  const DashboardProfesor({super.key});

  @override
  State<DashboardProfesor> createState() => _DashboardProfesorState();
}

class _DashboardProfesorState extends State<DashboardProfesor> {
  late final ProfesorServicio _servicio;
  bool _cargando = true;
  String? _error;
  ResumenDashboardProfesor? _resumen;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_cargando && _resumen == null && _error == null) {
      _servicio = ProfesorServicio(context.read<SesionProveedor>().api);
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
      final resumen = await _servicio.dashboard();
      if (mounted) setState(() => _resumen = resumen);
    } on ErrorApi catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } catch (_) {
      if (mounted) setState(() => _error = 'No se pudo cargar el panel.');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final nombreUsuario = context.watch<SesionProveedor>().usuario?.nombres ?? 'Profesor';

    return Scaffold(
      backgroundColor: colores.surfaceContainerLowest,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Icon(Icons.school_rounded, color: colores.primary),
            const SizedBox(width: 8),
            const Text('UniConnect', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Mensajes',
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () => context.go(Rutas.mensajesProfesor),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? VistaErrorProfesor(mensaje: _error!, alReintentar: _cargar)
              : RefreshIndicator(
                  onRefresh: _cargar,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              EncabezadoGradiente(
                                icono: Icons.person_rounded,
                                titulo: '¡Hola, $nombreUsuario!',
                                subtitulo: 'Periodo académico ${_resumen!.periodo}',
                                trailing: Row(
                                  children: [
                                    ChipEstadistica(
                                        valor: '${_resumen!.totalSecciones}', etiqueta: 'Secciones'),
                                    const SizedBox(width: 8),
                                    ChipEstadistica(
                                        valor: '${_resumen!.totalEstudiantes}', etiqueta: 'Alumnos'),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 28),
                              Text('Accesos rápidos',
                                  style: textos.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('Gestiona tus clases desde aquí.',
                                  style: textos.bodyMedium?.copyWith(color: colores.onSurfaceVariant)),
                              const SizedBox(height: 16),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final columnas = constraints.maxWidth > 640 ? 4 : 2;
                                  return GridView.count(
                                    crossAxisCount: columnas,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    mainAxisSpacing: 12,
                                    crossAxisSpacing: 12,
                                    childAspectRatio: 1.05,
                                    children: [
                                      _TarjetaModulo(
                                        icono: Icons.calendar_month_rounded,
                                        titulo: 'Agenda',
                                        color: colores.primary,
                                        onTap: () => context.go(Rutas.agendaProfesor),
                                      ),
                                      _TarjetaModulo(
                                        icono: Icons.assignment_rounded,
                                        titulo: 'Tareas',
                                        color: colores.secondary,
                                        insignia: _resumen!.tareasPendientesPorCalificar,
                                        onTap: () => context.go(Rutas.tareasProfesor),
                                      ),
                                      _TarjetaModulo(
                                        icono: Icons.folder_rounded,
                                        titulo: 'Materiales',
                                        color: colores.tertiary,
                                        onTap: () => context.go(Rutas.materialesProfesor),
                                      ),
                                      _TarjetaModulo(
                                        icono: Icons.chat_bubble_rounded,
                                        titulo: 'Mensajes',
                                        color: colores.primary,
                                        insignia: _resumen!.mensajesSinLeer,
                                        onTap: () => context.go(Rutas.mensajesProfesor),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 28),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Clases de hoy',
                                      style: textos.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: colores.primaryContainer,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text('${_resumen!.clasesHoy.length}',
                                        style: TextStyle(
                                            color: colores.onPrimaryContainer,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (_resumen!.clasesHoy.isEmpty)
                                const TarjetaVacia(
                                  icono: Icons.event_available_rounded,
                                  mensaje: 'No tienes clases programadas para hoy.',
                                )
                              else
                                for (final clase in _resumen!.clasesHoy) ...[
                                  _TarjetaClaseHoy(clase: clase),
                                  const SizedBox(height: 10),
                                ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}

class _TarjetaModulo extends StatelessWidget {
  const _TarjetaModulo({
    required this.icono,
    required this.titulo,
    required this.color,
    required this.onTap,
    this.insignia = 0,
  });

  final IconData icono;
  final String titulo;
  final Color color;
  final VoidCallback onTap;
  final int insignia;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;

    return Material(
      color: colores.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colores.outlineVariant),
          ),
          padding: const EdgeInsets.all(14),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icono, color: color, size: 24),
                  ),
                  const SizedBox(height: 10),
                  Text(titulo,
                      textAlign: TextAlign.center,
                      style: textos.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
              if (insignia > 0)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: colores.error,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('$insignia',
                        style: TextStyle(
                            color: colores.onError, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TarjetaClaseHoy extends StatelessWidget {
  const _TarjetaClaseHoy({required this.clase});
  final SeccionProfesor clase;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final horario = [clase.horaInicio, clase.horaFin].whereType<String>().join(' - ');

    return Container(
      decoration: BoxDecoration(
        color: colores.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colores.outlineVariant),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: colores.primary,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(clase.materia,
                              style: textos.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.schedule_rounded, size: 14, color: colores.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Text(horario.isEmpty ? 'Sin horario' : horario,
                                  style: textos.bodySmall?.copyWith(color: colores.onSurfaceVariant)),
                              const SizedBox(width: 12),
                              Icon(Icons.room_rounded, size: 14, color: colores.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Text(clase.aula ?? 'Sin aula',
                                  style: textos.bodySmall?.copyWith(color: colores.onSurfaceVariant)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('${clase.inscritos} alumnos',
                          style: const TextStyle(
                              color: Colors.green, fontWeight: FontWeight.w600, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}