import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router.dart';
import '../../../app/tema.dart';
import '../../../modelos/aula.dart';
import '../../../modelos/resumen_dashboard.dart';
import '../../../nucleo/formato.dart';
import '../../../proveedores/dashboard_proveedor.dart';
import '../../../proveedores/sesion_proveedor.dart';
import '../../../widgets/comunes.dart';
import '../../../widgets/estado_vista.dart';

/// Pantalla de inicio del estudiante: resumen del periodo, indicadores,
/// próximas entregas y accesos rápidos al resto de módulos.
class DashboardPantalla extends StatefulWidget {
  const DashboardPantalla({super.key});

  @override
  State<DashboardPantalla> createState() => _DashboardPantallaState();
}

class _DashboardPantallaState extends State<DashboardPantalla> {
  @override
  void initState() {
    super.initState();
    // Se pide tras el primer frame para no notificar durante la construcción.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProveedor>().cargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final proveedor = context.watch<DashboardProveedor>();
    final usuario = context.watch<SesionProveedor>().usuario;
    final resumen = proveedor.resumen;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => proveedor.cargar(silencioso: true),
          child: VistaEstado(
            cargando: proveedor.cargando && resumen == null,
            error: resumen == null ? proveedor.error : null,
            vacio: false,
            alReintentar: proveedor.cargar,
            vistaVacia: const SizedBox.shrink(),
            skeleton: const CargandoSkeleton(lineas: 5, altura: 110),
            contenido: (context) => ContenidoCentrado(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [
                  TarjetaHero(
                    child: _Saludo(
                      nombre: usuario?.nombres ?? '',
                      matricula: usuario?.matricula,
                      periodo: resumen?.periodoActivo ?? '',
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (resumen != null) ...[
                    _FilaIndicadores(resumen: resumen),
                    const SizedBox(height: 20),

                    if (resumen.sinActividad)
                      _SinInscripciones(
                        alInscribirse: () => context.push(Rutas.inscripcion),
                      )
                    else ...[
                      _TarjetaRendimiento(resumen: resumen),
                      const SizedBox(height: 20),
                      _ProximasEntregas(entregas: resumen.proximasEntregas),
                      const SizedBox(height: 20),
                    ],

                    const EncabezadoSeccion(
                      titulo: 'Accesos rápidos',
                      subtitulo: 'El resto de tus módulos',
                    ),
                    const SizedBox(height: 12),
                    _CuadriculaModulos(resumen: resumen),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Saludo extends StatelessWidget {
  const _Saludo({required this.nombre, required this.periodo, this.matricula});

  final String nombre;
  final String? matricula;
  final String periodo;

  String get _franja {
    final hora = DateTime.now().hour;
    if (hora < 12) return 'Buenos días';
    if (hora < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    final colores = context.colores;
    // Va sobre la tarjeta hero azul, así que el texto usa el par de contraste
    // del contenedor y no el de la superficie.
    final sobreAzul = colores.onPrimaryContainer;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _franja,
                style: context.textos.bodyMedium?.copyWith(
                  color: sobreAzul.withValues(alpha: 0.75),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                nombre,
                style: context.textos.headlineMedium?.copyWith(
                  color: sobreAzul,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (matricula != null)
                    _Insignia(texto: matricula!, color: sobreAzul),
                  if (periodo.isNotEmpty)
                    _Insignia(
                      texto: 'Periodo $periodo',
                      color: sobreAzul,
                      icono: Icons.event_note_rounded,
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 54,
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colores.primary,
            shape: BoxShape.circle,
          ),
          child: Text(
            Formato.iniciales(nombre),
            style: context.textos.titleLarge?.copyWith(
              color: colores.onPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Etiqueta translúcida para usar sobre la tarjeta hero, donde los tonos suaves
/// de [ChipEstado] no tendrían contraste suficiente.
class _Insignia extends StatelessWidget {
  const _Insignia({required this.texto, required this.color, this.icono});

  final String texto;
  final Color color;
  final IconData? icono;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icono != null) ...[
            Icon(icono, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            texto,
            style: context.textos.labelMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

/// Tres indicadores en fila: materias, promedio y asistencia.
class _FilaIndicadores extends StatelessWidget {
  const _FilaIndicadores({required this.resumen});

  final ResumenDashboard resumen;

  @override
  Widget build(BuildContext context) {
    final estados = context.estados;

    return Row(
      children: [
        Expanded(
          child: _Indicador(
            icono: Icons.menu_book_rounded,
            valor: '${resumen.materiasInscritas}',
            etiqueta: 'Materias',
            detalle: '${resumen.creditosInscritos} créditos',
            color: context.colores.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _Indicador(
            icono: Icons.workspace_premium_rounded,
            valor: Formato.nota(resumen.promedioGeneral),
            etiqueta: 'Promedio',
            detalle: 'General',
            color: estados.exito,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _Indicador(
            icono: Icons.how_to_reg_rounded,
            valor: Formato.porcentaje(resumen.porcentajeAsistencia),
            etiqueta: 'Asistencia',
            detalle: 'Del periodo',
            color: estados.info,
          ),
        ),
      ],
    );
  }
}

class _Indicador extends StatelessWidget {
  const _Indicador({
    required this.icono,
    required this.valor,
    required this.etiqueta,
    required this.detalle,
    required this.color,
  });

  final IconData icono;
  final String valor;
  final String etiqueta;
  final String detalle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icono, size: 18, color: color),
            ),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(valor, style: context.textos.headlineSmall),
            ),
            const SizedBox(height: 2),
            Text(
              etiqueta,
              style: context.textos.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              detalle,
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

/// Anillo de asistencia junto al gráfico de promedios por materia.
class _TarjetaRendimiento extends StatelessWidget {
  const _TarjetaRendimiento({required this.resumen});

  final ResumenDashboard resumen;

  @override
  Widget build(BuildContext context) {
    final estados = context.estados;
    final asistencia = resumen.porcentajeAsistencia;
    final promedios = resumen.promediosPorMateria;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const EncabezadoSeccion(
              titulo: 'Tu rendimiento',
              subtitulo: 'Asistencia del periodo y notas publicadas',
            ),
            const SizedBox(height: 20),
            if (asistencia != null)
              Center(
                child: AnilloProgreso(
                  valor: asistencia,
                  etiqueta: 'asistencia',
                  color: asistencia >= 80
                      ? estados.exito
                      : asistencia >= 60
                      ? estados.advertencia
                      : estados.error,
                ),
              )
            else
              Center(
                child: Text(
                  'Aún no hay clases registradas en este periodo.',
                  style: context.textos.bodySmall?.copyWith(
                    color: context.colores.onSurfaceVariant,
                  ),
                ),
              ),
            if (promedios.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Promedio por materia',
                style: context.textos.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: _GraficoPromedios(promedios: promedios),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GraficoPromedios extends StatelessWidget {
  const _GraficoPromedios({required this.promedios});

  final List<PromedioMateria> promedios;

  @override
  Widget build(BuildContext context) {
    final colores = context.colores;
    final estados = context.estados;

    // Se limita a las seis materias más recientes para que las barras respiren.
    final datos = promedios.take(6).toList();

    return BarChart(
      BarChartData(
        maxY: 100,
        minY: 0,
        alignment: BarChartAlignment.spaceAround,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (_) => FlLine(
            color: colores.outlineVariant.withValues(alpha: 0.4),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: 25,
              getTitlesWidget: (valor, _) => Text(
                valor.toInt().toString(),
                style: context.textos.labelSmall?.copyWith(
                  color: colores.onSurfaceVariant,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (valor, _) {
                final indice = valor.toInt();
                if (indice < 0 || indice >= datos.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    datos[indice].codigoMateria,
                    style: context.textos.labelSmall?.copyWith(fontSize: 9),
                  ),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (grupo, _, barra, _) => BarTooltipItem(
              '${datos[grupo.x].materia}\n${Formato.nota(barra.toY)}',
              context.textos.labelSmall!.copyWith(
                color: colores.onInverseSurface,
              ),
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < datos.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: datos[i].promedio,
                  width: 22,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                  // Azul cuando la nota está bien y ámbar cuando no: dentro de
                  // la paleta y sin el semáforo verde/rojo, que aquí gritaba.
                  color: datos[i].promedio >= 70
                      ? colores.primary
                      : estados.advertencia,
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: 100,
                    color: colores.surfaceContainerHigh,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ProximasEntregas extends StatelessWidget {
  const _ProximasEntregas({required this.entregas});

  final List<Tarea> entregas;

  @override
  Widget build(BuildContext context) {
    if (entregas.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.task_alt_rounded, color: context.estados.exito),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'No tienes entregas próximas. Vas al día.',
                  style: context.textos.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EncabezadoSeccion(
          titulo: 'Próximas entregas',
          subtitulo: 'Lo que vence primero',
          accion: TextButton(
            onPressed: () => context.push(Rutas.tareas),
            child: const Text('Ver todas'),
          ),
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < entregas.length; i++)
          EntradaAnimada(
            indice: i,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _FilaEntrega(tarea: entregas[i]),
            ),
          ),
      ],
    );
  }
}

class _FilaEntrega extends StatelessWidget {
  const _FilaEntrega({required this.tarea});

  final Tarea tarea;

  @override
  Widget build(BuildContext context) {
    final dias = tarea.fechaEntrega.difference(DateTime.now()).inDays;
    final urgente = dias <= 2;
    final color = urgente ? context.estados.error : context.estados.advertencia;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(Rutas.tareas),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 44,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tarea.titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textos.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tarea.materia,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textos.bodySmall?.copyWith(
                        color: context.colores.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ChipEstado(
                texto: Formato.tiempoRestante(tarea.fechaEntrega),
                tono: urgente ? TonoEstado.error : TonoEstado.advertencia,
                icono: Icons.schedule_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CuadriculaModulos extends StatelessWidget {
  const _CuadriculaModulos({required this.resumen});

  final ResumenDashboard resumen;

  @override
  Widget build(BuildContext context) {
    final estados = context.estados;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.45,
      children: [
        TarjetaModulo(
          icono: Icons.assignment_outlined,
          titulo: 'Tareas',
          insignia: resumen.tareasPendientes,
          color: estados.advertencia,
          alPulsar: () => context.push(Rutas.tareas),
        ),
        TarjetaModulo(
          icono: Icons.how_to_reg_outlined,
          titulo: 'Asistencia',
          color: estados.info,
          alPulsar: () => context.push(Rutas.asistencia),
        ),
        TarjetaModulo(
          icono: Icons.folder_open_rounded,
          titulo: 'Materiales',
          color: context.colores.tertiary,
          alPulsar: () => context.push(Rutas.materiales),
        ),
        TarjetaModulo(
          icono: Icons.playlist_add_rounded,
          titulo: 'Inscripción',
          color: estados.exito,
          alPulsar: () => context.push(Rutas.inscripcion),
        ),
      ],
    );
  }
}

/// Estado inicial del estudiante que todavía no se ha inscrito en nada.
class _SinInscripciones extends StatelessWidget {
  const _SinInscripciones({required this.alInscribirse});

  final VoidCallback alInscribirse;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.auto_stories_rounded,
              size: 48,
              color: context.colores.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Aún no tienes materias este periodo',
              textAlign: TextAlign.center,
              style: context.textos.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Inscríbete en las secciones disponibles para ver aquí tu horario, '
              'tus tareas y tu asistencia.',
              textAlign: TextAlign.center,
              style: context.textos.bodySmall?.copyWith(
                color: context.colores.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: alInscribirse,
              icon: const Icon(Icons.playlist_add_rounded),
              label: const Text('Ir a inscripción'),
            ),
          ],
        ),
      ),
    );
  }
}
