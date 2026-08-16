import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/tema.dart';
import '../../proveedores/calificacion_detalle_profesor_proveedor.dart';
import '../../widgets/comunes.dart';
import '../../widgets/estado_vista.dart';

class CalificacionDetalleProfesorPantalla
    extends StatefulWidget {
  const CalificacionDetalleProfesorPantalla({
    super.key,
    required this.seccionId,
    required this.materia,
  });

  final int seccionId;
  final String materia;

  @override
  State<CalificacionDetalleProfesorPantalla>
      createState() =>
          _CalificacionDetalleProfesorPantallaState();
}

class _CalificacionDetalleProfesorPantallaState
    extends State<
        CalificacionDetalleProfesorPantalla> {
  late final CalificacionDetalleProfesorProveedor
      _proveedor;

  @override
  void initState() {
    super.initState();

    _proveedor =
        CalificacionDetalleProfesorProveedor(
      context.read(),
      widget.seccionId,
    );

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      _proveedor.cargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _proveedor,
      child:
          Consumer<
              CalificacionDetalleProfesorProveedor>(
        builder: (
          context,
          proveedor,
          _,
        ) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.materia),
            ),
            body: VistaEstado(
              cargando:
                  proveedor.cargando &&
                  !proveedor.cargadoAlgunaVez,
              error: proveedor.error,
              vacio: proveedor.vacio,
              alReintentar: proveedor.cargar,
              vistaVacia: const EstadoVacio(
                icono:
                    Icons.assessment_outlined,
                titulo: 'Sin estudiantes',
                mensaje:
                    'No hay estudiantes inscritos.',
              ),
              contenido: (context) =>
                  ContenidoCentrado(
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding:
                            const EdgeInsets.all(
                          16,
                        ),
                        itemCount:
                            proveedor
                                .estudiantes
                                .length,
                        itemBuilder:
                            (
                              context,
                              index,
                            ) {
                              final estudiante =
                                  proveedor
                                          .estudiantes[
                                      index];

                              final registro =
                                  proveedor
                                          .registros[
                                      estudiante
                                          .inscripcionId]!;

                              return _TarjetaCalificacion(
                                nombre:
                                    estudiante
                                        .nombre,
                                nota:
                                    registro
                                        .nota,
                                alCambiarNota:
                                    (valor) {
                                  proveedor
                                      .actualizarNota(
                                    estudiante
                                        .inscripcionId,
                                    valor,
                                  );
                                },
                              );
                            },
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.all(
                        16,
                      ),
                      child:
                          FilledButton.icon(
                        onPressed: () =>
                            _guardar(
                          context,
                          proveedor,
                        ),
                        icon: const Icon(
                          Icons.save_rounded,
                        ),
                        label: const Text(
                          'Guardar calificaciones',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _guardar(
    BuildContext context,
    CalificacionDetalleProfesorProveedor
        proveedor,
  ) async {
    try {
      await proveedor.guardar();

      if (!mounted) return;

      mostrarAviso(
        context,
        'Calificaciones guardadas correctamente.',
      );

      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;

      mostrarAviso(
        context,
        'No se pudieron guardar las calificaciones.',
        esError: true,
      );
    }
  }
}
class _TarjetaCalificacion
    extends StatelessWidget {
  const _TarjetaCalificacion({
    required this.nombre,
    required this.nota,
    required this.alCambiarNota,
  });

  final String nombre;
  final double? nota;
  final ValueChanged<double?> alCambiarNota;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                nombre,
                style: context.textos.titleMedium
                    ?.copyWith(
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              width: 90,
              child: TextFormField(
                initialValue:
                    nota?.toString(),
                textAlign:
                    TextAlign.center,
                keyboardType:
                    const TextInputType
                        .numberWithOptions(
                  decimal: true,
                ),
                decoration:
                    const InputDecoration(
                  hintText: '0-100',
                ),
                onChanged: (valor) {
                  alCambiarNota(
                    double.tryParse(
                      valor,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}