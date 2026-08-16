import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/tema.dart';
import '../../modelos/profesor/calificacion_profesor.dart';
import '../../proveedores/calificaciones_profesor_proveedor.dart';
import '../../widgets/comunes.dart';
import '../../widgets/estado_vista.dart';
import 'calificacion_detalle_profesor_pantalla.dart';

class CalificacionesProfesorPantalla
    extends StatefulWidget {
  const CalificacionesProfesorPantalla({
    super.key,
  });

  @override
  State<CalificacionesProfesorPantalla>
      createState() =>
          _CalificacionesProfesorPantallaState();
}

class _CalificacionesProfesorPantallaState
    extends State<
        CalificacionesProfesorPantalla> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      context
          .read<
              CalificacionesProfesorProveedor>()
          .cargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final proveedor = context.watch<
        CalificacionesProfesorProveedor>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calificaciones',
        ),
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
          icono: Icons.grade_rounded,
          titulo: 'Sin registros',
          mensaje:
              'Todavía no existen calificaciones para tus materias.',
        ),
        contenido: (context) =>
            RefreshIndicator(
          onRefresh: () =>
              proveedor.cargar(
            silencioso: true,
          ),
          child: ContenidoCentrado(
            child: ListView(
              padding:
                  const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                32,
              ),
              children: [
                _ResumenCalificaciones(
                  datos:
                      proveedor.calificaciones,
                ),

                const SizedBox(
                  height: 24,
                ),

                const EncabezadoSeccion(
                  titulo: 'Por materia',
                  subtitulo:
                      'Promedio académico por sección',
                ),

                const SizedBox(
                  height: 12,
                ),

                for (
                  var i = 0;
                  i <
                      proveedor
                          .calificaciones
                          .length;
                  i++
                )
                  EntradaAnimada(
                    indice: i,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child:
                          _TarjetaCalificacion(
                        calificacion:
                            proveedor
                                    .calificaciones[
                                i],
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
class _ResumenCalificaciones
    extends StatelessWidget {
  const _ResumenCalificaciones({
    required this.datos,
  });

  final List<CalificacionProfesor> datos;

  @override
  Widget build(BuildContext context) {
    final conDatos = datos
        .where(
          (e) => e.promedio != null,
        )
        .toList();

    final promedioGeneral =
        conDatos.isEmpty
            ? 0.0
            : conDatos
                    .map(
                      (e) => e.promedio!,
                    )
                    .reduce(
                      (a, b) => a + b,
                    ) /
                conDatos.length;

    final totalEstudiantes =
        datos.fold<int>(
      0,
      (suma, e) =>
          suma + e.estudiantes,
    );

    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(20),
        child: Row(
          children: [
            AnilloProgreso(
              valor: promedioGeneral,
              etiqueta: 'promedio',
              color:
                  context.estados.info,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    'Promedio general',
                    style: context
                        .textos
                        .titleSmall
                        ?.copyWith(
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  Text(
                    '${datos.length} materias · '
                    '$totalEstudiantes estudiantes',
                    style: context
                        .textos
                        .bodySmall,
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Text(
                    'Resumen de rendimiento académico de todas tus secciones.',
                    style: context
                        .textos
                        .bodySmall,
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
class _TarjetaCalificacion
    extends StatelessWidget {
  const _TarjetaCalificacion({
    required this.calificacion,
  });

  final CalificacionProfesor
      calificacion;

  @override
  Widget build(BuildContext context) {
    final promedio =
        calificacion.promedio ?? 0;

    return Card(
      child: InkWell(
        borderRadius:
            BorderRadius.circular(12),
        onTap: () async {
          final actualizado =
              await Navigator.of(context)
                  .push(
            MaterialPageRoute(
              builder: (_) =>
                  CalificacionDetalleProfesorPantalla(
                seccionId:
                    calificacion.seccionId,
                materia:
                    calificacion.materia,
              ),
            ),
          );

          if (actualizado == true &&
              context.mounted) {
            context
                .read<
                    CalificacionesProfesorProveedor>()
                .cargar(
                  silencioso: true,
                );
          }
        },
        child: Padding(
          padding:
              const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              Text(
                calificacion.materia,
                style: context
                    .textos.titleMedium
                    ?.copyWith(
                  fontWeight:
                      FontWeight.w700,
                ),
              ),

              const SizedBox(
                height: 4,
              ),

              Text(
                calificacion
                    .codigoMateria,
                style: context
                    .textos.bodySmall
                    ?.copyWith(
                  color: context
                      .colores
                      .onSurfaceVariant,
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              Row(
                children: [
                  Text(
                    promedio
                        .toStringAsFixed(
                      1,
                    ),
                    style: context
                        .textos
                        .headlineSmall
                        ?.copyWith(
                      color: context
                          .estados.info,
                      fontWeight:
                          FontWeight
                              .bold,
                    ),
                  ),
                  const Spacer(),
                  ChipEstado(
                    texto:
                        '${calificacion.estudiantes} estudiantes',
                    tono:
                        TonoEstado.info,
                  ),
                ],
              ),

              const SizedBox(
                height: 12,
              ),

              Text(
                'Toca para registrar o editar calificaciones',
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