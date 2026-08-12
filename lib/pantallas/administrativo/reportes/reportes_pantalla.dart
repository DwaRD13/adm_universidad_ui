import 'package:adm_universidad_ui/modelos/admin_resumen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router.dart';
import '../../../app/tema.dart';
import '../../../proveedores/reportes_proveedor.dart';
import '../../../widgets/comunes.dart';
import '../../../widgets/estado_vista.dart';

/// Pantalla de reportes con acceso a los diferentes informes del sistema.
class ReportesPantalla extends StatefulWidget {
  const ReportesPantalla({super.key});

  @override
  State<ReportesPantalla> createState() => _ReportesPantallaState();
}

class _ReportesPantallaState extends State<ReportesPantalla> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportesProveedor>().cargarResumen();
    });
  }

  @override
  Widget build(BuildContext context) {
    final proveedor = context.watch<ReportesProveedor>();
    final resumen = proveedor.resumen;

    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      body: SafeArea(
        child: VistaEstado(
          cargando: proveedor.cargando && resumen == null,
          error: resumen == null ? proveedor.error : null,
          vacio: false,
          alReintentar: proveedor.cargarResumen,
          vistaVacia: const SizedBox.shrink(),
          skeleton: const CargandoSkeleton(lineas: 5, altura: 130),
          contenido: (context) => RefreshIndicator(
            onRefresh: () => proveedor.cargarResumen(silencioso: true),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                // Resumen rápido
                if (resumen != null) ...[
                  const EncabezadoSeccion(
                    titulo: 'Resumen general',
                    subtitulo: 'Datos del periodo activo',
                  ),
                  const SizedBox(height: 12),
                  _ResumenRapido(resumen: resumen),
                  const SizedBox(height: 20),
                ],
                const EncabezadoSeccion(
                  titulo: 'Informes disponibles',
                  subtitulo: 'Selecciona un reporte para generar',
                ),
                const SizedBox(height: 12),
                _CuadriculaReportes(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResumenRapido extends StatelessWidget {
  const _ResumenRapido({required this.resumen});

  final AdminResumen resumen;

  @override
  Widget build(BuildContext context) {
    final colores = context.colores;
    final estados = context.estados;

    return Row(
      children: [
        Expanded(
          child: _MiniIndicador(
            icono: Icons.people_rounded,
            valor: '${resumen.totalEstudiantes}',
            etiqueta: 'Estudiantes',
            color: estados.info,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MiniIndicador(
            icono: Icons.school_rounded,
            valor: '${resumen.totalProfesores}',
            etiqueta: 'Profesores',
            color: estados.exito,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MiniIndicador(
            icono: Icons.meeting_room_rounded,
            valor: '${resumen.totalSecciones}',
            etiqueta: 'Secciones',
            color: colores.tertiary,
          ),
        ),
      ],
    );
  }
}

class _MiniIndicador extends StatelessWidget {
  const _MiniIndicador({
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icono, size: 20, color: color),
            const SizedBox(height: 10),
            Text(valor, style: context.textos.titleMedium),
            const SizedBox(height: 2),
            Text(
              etiqueta,
              style: context.textos.labelSmall?.copyWith(
                color: context.colores.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CuadriculaReportes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colores = context.colores;
    final estados = context.estados;

    final reportes = [
      _ReporteItem(
        icono: Icons.trending_up_rounded,
        titulo: 'Rendimiento académico',
        descripcion: 'Promedios por carrera, materia y periodo',
        color: colores.primary,
        ruta: Rutas.reporteRendimiento,
      ),
      _ReporteItem(
        icono: Icons.how_to_reg_rounded,
        titulo: 'Asistencia',
        descripcion: 'Resumen de asistencias y ausencias',
        color: estados.info,
        ruta: Rutas.reporteAsistencia,
      ),
      _ReporteItem(
        icono: Icons.assignment_turned_in_rounded,
        titulo: 'Inscripciones',
        descripcion: 'Estadísticas de inscripciones por periodo',
        color: estados.exito,
        ruta: Rutas.reporteInscripciones,
      ),
      _ReporteItem(
        icono: Icons.people_outline_rounded,
        titulo: 'Demografía',
        descripcion: 'Distribución de estudiantes por carrera',
        color: colores.tertiary,
        ruta: Rutas.reporteDemografia,
      ),
      _ReporteItem(
        icono: Icons.timer_rounded,
        titulo: 'Carga horaria',
        descripcion: 'Horas asignadas por profesor y sección',
        color: estados.advertencia,
        ruta: Rutas.reporteCargaHoraria,
      ),
      _ReporteItem(
        icono: Icons.star_rounded,
        titulo: 'Calificaciones finales',
        descripcion: 'Notas literales por materia',
        color: colores.secondary,
        ruta: Rutas.reporteCalificaciones,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: reportes
          .map(
            (r) => Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => context.push(r.ruta),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: r.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(r.icono, color: r.color, size: 24),
                      ),
                      const Spacer(),
                      Text(
                        r.titulo,
                        style: context.textos.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        r.descripcion,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textos.bodySmall?.copyWith(
                          color: context.colores.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ReporteItem {
  final IconData icono;
  final String titulo;
  final String descripcion;
  final Color color;
  final String ruta;

  const _ReporteItem({
    required this.icono,
    required this.titulo,
    required this.descripcion,
    required this.color,
    required this.ruta,
  });
}
