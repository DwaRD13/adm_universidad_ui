import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/tema.dart';
import '../../modelos/profesor/asistencia_profesor.dart';
import '../../proveedores/asistencia_profesor_proveedor.dart';
import '../../widgets/comunes.dart';
import '../../widgets/estado_vista.dart';
import 'asistencia_detalle_profesor_pantalla.dart';

class AsistenciaProfesorPantalla extends StatefulWidget {
  const AsistenciaProfesorPantalla({super.key});

  @override
  State<AsistenciaProfesorPantalla> createState() =>
      _AsistenciaProfesorPantallaState();
}

class _AsistenciaProfesorPantallaState
    extends State<AsistenciaProfesorPantalla> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AsistenciaProfesorProveedor>().cargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final proveedor =
        context.watch<AsistenciaProfesorProveedor>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistencia'),
      ),
      body: VistaEstado(
        cargando:
            proveedor.cargando &&
            !proveedor.cargadoAlgunaVez,
        error: proveedor.error,
        vacio: proveedor.vacio,
        alReintentar: proveedor.cargar,
        skeleton: const CargandoSkeleton(
          lineas: 4,
          altura: 110,
        ),
        vistaVacia: const EstadoVacio(
          icono: Icons.how_to_reg_rounded,
          titulo: 'Sin registros',
          mensaje:
              'Todavía no existen datos de asistencia para tus materias.',
        ),
        contenido: (context) => RefreshIndicator(
          onRefresh: () =>
              proveedor.cargar(silencioso: true),
          child: ContenidoCentrado(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                32,
              ),
              children: [
                _ResumenAsistencia(
                  datos: proveedor.asistencias,
                ),

                const SizedBox(height: 24),

                const EncabezadoSeccion(
                  titulo: 'Por materia',
                  subtitulo:
                      'Porcentaje promedio de asistencia',
                ),

                const SizedBox(height: 12),

                for (var i = 0;
                    i < proveedor.asistencias.length;
                    i++)
                  EntradaAnimada(
                    indice: i,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: _TarjetaAsistencia(
                        asistencia:
                            proveedor.asistencias[i],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResumenAsistencia extends StatelessWidget {
  const _ResumenAsistencia({
    required this.datos,
  });

  final List<AsistenciaProfesor> datos;

  @override
  Widget build(BuildContext context) {
    final conDatos = datos
        .where((e) => e.porcentajePromedio != null)
        .toList();

    final promedioGeneral = conDatos.isEmpty
        ? 0.0
        : conDatos
                .map((e) => e.porcentajePromedio!)
                .reduce((a, b) => a + b) /
            conDatos.length;

    final totalEstudiantes = datos.fold<int>(
      0,
      (suma, e) => suma + e.estudiantes,
    );

    final color = promedioGeneral >= 80
        ? context.estados.exito
        : promedioGeneral >= 60
            ? context.estados.advertencia
            : context.estados.error;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            AnilloProgreso(
              valor: promedioGeneral,
              etiqueta: 'promedio',
              color: color,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Asistencia general',
                    style: context.textos.titleSmall
                        ?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${datos.length} materias · '
                    '$totalEstudiantes estudiantes',
                    style: context.textos.bodySmall
                        ?.copyWith(
                      color: context
                          .colores
                          .onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Promedio de asistencia de todas tus secciones.',
                    style: context.textos.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaAsistencia extends StatelessWidget {
  const _TarjetaAsistencia({
    required this.asistencia,
  });

  final AsistenciaProfesor asistencia;

  @override
  Widget build(BuildContext context) {    
    final porcentaje =
        asistencia.porcentajePromedio ?? 0;

    final color = porcentaje >= 80
        ? context.estados.exito
        : porcentaje >= 60
            ? context.estados.advertencia
            : context.estados.error;

return Card(
  child: InkWell(
    borderRadius: BorderRadius.circular(12),
    onTap: () async {
      final actualizado =
        await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
          AsistenciaDetalleProfesorPantalla(
            seccionId: asistencia.seccionId,
            materia: asistencia.materia,
      ),
    ),
  );

  if (actualizado == true && context.mounted) {
    context
        .read<AsistenciaProfesorProveedor>()
        .cargar(silencioso: true);
  }
},
    child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              asistencia.materia,
              style: context.textos.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              asistencia.codigoMateria,
              style: context.textos.bodySmall?.copyWith(
                color: context.colores.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Text(
                  '${porcentaje.toStringAsFixed(0)}%',
                  style: context.textos.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ChipEstado(
                  texto:
                      '${asistencia.estudiantes} estudiantes',
                  tono: TonoEstado.info,
                ),
              ],
            ),

            const SizedBox(height: 12),

            BarraProgreso(
              valor: porcentaje / 100,
              color: color,
            ),

            const SizedBox(height: 12),

            Text(
              porcentaje == 0
                  ? 'Sin registros de asistencia'
                  : 'Promedio registrado para la sección',
              style: context.textos.bodySmall?.copyWith(
                color: context.colores.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
    