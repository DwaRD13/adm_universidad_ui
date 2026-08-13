import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../modelos/profesor/seccion_profesor.dart';
import '../../nucleo/excepciones.dart';
import '../../proveedores/sesion_proveedor.dart';
import '../../servicios/profesor_servicio.dart';
import 'widgets_profesor.dart';

class AgendaProfesorScreen extends StatefulWidget {
  const AgendaProfesorScreen({super.key});

  @override
  State<AgendaProfesorScreen> createState() => _AgendaProfesorScreenState();
}

class _AgendaProfesorScreenState extends State<AgendaProfesorScreen> {
  late final ProfesorServicio _servicio;
  bool _cargando = true;
  String? _error;
  List<SeccionProfesor> _secciones = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_cargando && _secciones.isEmpty && _error == null) {
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
      final secciones = await _servicio.secciones();
      if (mounted) setState(() => _secciones = secciones);
    } on ErrorApi catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } catch (_) {
      if (mounted) setState(() => _error = 'No se pudo cargar tu agenda.');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final totalEstudiantes = _secciones.fold<int>(0, (s, c) => s + c.inscritos);

    return Scaffold(
      backgroundColor: colores.surfaceContainerLowest,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          tooltip: 'Volver',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/profesor'),
        ),
        title: const Text('Mi Agenda'),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? VistaErrorProfesor(mensaje: _error!, alReintentar: _cargar)
              : RefreshIndicator(
                  onRefresh: _cargar,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    children: [
                      EncabezadoGradiente(
                        icono: Icons.calendar_month_rounded,
                        titulo: '${_secciones.length} secciones activas',
                        subtitulo: '$totalEstudiantes estudiantes en total este periodo',
                      ),
                      const SizedBox(height: 24),
                      Text('Tus secciones',
                          style: textos.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      if (_secciones.isEmpty)
                        const TarjetaVacia(
                          icono: Icons.menu_book_rounded,
                          mensaje: 'No tienes secciones asignadas este periodo.',
                        )
                      else
                        ..._secciones.map((s) => _TarjetaSeccion(seccion: s)),
                    ],
                  ),
                ),
    );
  }
}

class _TarjetaSeccion extends StatelessWidget {
  const _TarjetaSeccion({required this.seccion});
  final SeccionProfesor seccion;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;
    final horario = [seccion.horaInicio, seccion.horaFin].whereType<String>().join(' - ');
    final dias = seccion.dias.join('-');
    final ocupacion = seccion.cupoMaximo == 0 ? 0.0 : seccion.inscritos / seccion.cupoMaximo;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colores.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colores.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colores.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.menu_book_rounded, color: colores.onPrimaryContainer, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(seccion.materia,
                          style: textos.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text('${seccion.codigoMateria} · ${seccion.creditos} créditos',
                          style: textos.bodySmall?.copyWith(color: colores.onSurfaceVariant)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: colores.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(seccion.estado ?? '',
                      style: textos.labelSmall?.copyWith(
                          color: colores.onPrimaryContainer, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(Icons.event_repeat_rounded, size: 16, color: colores.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(dias.isEmpty ? 'Sin días' : dias,
                    style: textos.bodySmall?.copyWith(color: colores.onSurfaceVariant)),
                const SizedBox(width: 16),
                Icon(Icons.access_time_rounded, size: 16, color: colores.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(horario.isEmpty ? 'Sin horario' : horario,
                    style: textos.bodySmall?.copyWith(color: colores.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 16, color: colores.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(seccion.aula ?? 'Sin aula',
                    style: textos.bodySmall?.copyWith(color: colores.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: ocupacion,
                      minHeight: 6,
                      backgroundColor: colores.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation(colores.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text('${seccion.inscritos}/${seccion.cupoMaximo}',
                    style: textos.labelSmall?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}