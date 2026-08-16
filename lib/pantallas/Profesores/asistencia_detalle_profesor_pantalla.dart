import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/tema.dart';
import '../../modelos/profesor/registro_asistencia_profesor.dart';
import '../../proveedores/asistencia_detalle_profesor_proveedor.dart';
import '../../widgets/comunes.dart';
import '../../widgets/estado_vista.dart';

class AsistenciaDetalleProfesorPantalla extends StatefulWidget {
  const AsistenciaDetalleProfesorPantalla({
    super.key,
    required this.seccionId,
    required this.materia,
  });

  final int seccionId;
  final String materia;

  @override
  State<AsistenciaDetalleProfesorPantalla> createState() =>
      _AsistenciaDetalleProfesorPantallaState();
}

class _AsistenciaDetalleProfesorPantallaState
    extends State<AsistenciaDetalleProfesorPantalla> {
  late final AsistenciaDetalleProfesorProveedor _proveedor;

  @override
  void initState() {
    super.initState();

    _proveedor = AsistenciaDetalleProfesorProveedor(
      context.read(),
      widget.seccionId,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _proveedor.cargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _proveedor,
      child: Consumer<AsistenciaDetalleProfesorProveedor>(
        builder: (context, proveedor, _) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.materia),
            ),
            body: VistaEstado(
              cargando: proveedor.cargando &&
                  !proveedor.cargadoAlgunaVez,
              error: proveedor.error,
              vacio: proveedor.vacio,
              alReintentar: proveedor.cargar,
              vistaVacia: const EstadoVacio(
                icono: Icons.people_outline,
                titulo: 'Sin estudiantes',
                mensaje:
                    'No hay estudiantes inscritos en esta sección.',
              ),
              contenido: (context) => ContenidoCentrado(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        16,
                        16,
                        0,
                      ),
                      child: Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.calendar_month_rounded,
                          ),
                          title: Text(
                            proveedor.fechaSeleccionada
                                .toString()
                                .split(' ')
                                .first,
                          ),
                          subtitle: Text(
                            '${proveedor.estudiantes.length} estudiantes',
                          ),
                          trailing: const Icon(
                            Icons.edit_calendar_rounded,
                          ),
                          onTap: () async {
                            final fecha =
                                await showDatePicker(
                              context: context,
                              initialDate:
                                  proveedor.fechaSeleccionada,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );

                            if (fecha != null) {
                              await proveedor.cambiarFecha(
                                fecha,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount:
                            proveedor.estudiantes.length,
                        itemBuilder: (context, index) {
                          final estudiante =
                              proveedor.estudiantes[index];

                          final registro =
                              proveedor.registros[
                                  estudiante.inscripcionId]!;

                          return _TarjetaEstudiante(
                            nombre: estudiante.nombre,
                            registro: registro,
                            alCambiarEstado: (valor) {
                              proveedor.actualizarEstado(
                                estudiante.inscripcionId,
                                valor,
                              );
                            },
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: FilledButton.icon(
                        onPressed: () =>
                            _guardar(context, proveedor),
                        icon: const Icon(
                          Icons.save_rounded,
                        ),
                        label: const Text(
                          'Guardar asistencia',
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
    AsistenciaDetalleProfesorProveedor proveedor,
  ) async {
    try {
      await proveedor.guardar();

      if (!mounted) return;

      mostrarAviso(
        context,
        'Asistencia guardada correctamente.',
      );

      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;

      mostrarAviso(
        context,
        'No se pudo guardar la asistencia.',
        esError: true,
      );
    }
  }
}

class _TarjetaEstudiante extends StatelessWidget {
  const _TarjetaEstudiante({
    required this.nombre,
    required this.registro,
    required this.alCambiarEstado,
  });

  final String nombre;
  final RegistroAsistenciaProfesor registro;
  final ValueChanged<String> alCambiarEstado;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    nombre,
                    style:
                        context.textos.titleMedium
                            ?.copyWith(
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Wrap(
                  spacing: 6,
                  children: [
                    ChoiceChip(
                      showCheckmark: false,
                      label: const Icon(
                        Icons.check,
                        size: 18,
                      ),
                      selected:
                          registro.estado ==
                          'PRESENTE',
                      selectedColor:
                          context.estados.exito,
                      onSelected: (_) =>
                          alCambiarEstado(
                        'PRESENTE',
                      ),
                    ),

                    ChoiceChip(
                      showCheckmark: false,
                      label: const Icon(
                        Icons.close,
                        size: 18,
                      ),
                      selected:
                          registro.estado ==
                          'AUSENTE',
                      selectedColor:
                          context.estados.error,
                      onSelected: (_) =>
                          alCambiarEstado(
                        'AUSENTE',
                      ),
                    ),

                    ChoiceChip(
                      showCheckmark: false,
                      label: const Icon(
                        Icons.schedule,
                        size: 18,
                      ),
                      selected:
                          registro.estado ==
                          'TARDANZA',
                      selectedColor:
                          context
                              .estados
                              .advertencia,
                      onSelected: (_) =>
                          alCambiarEstado(
                        'TARDANZA',
                      ),
                    ),

                    ChoiceChip(
                      showCheckmark: false,
                      label: const Icon(
                        Icons.description,
                        size: 18,
                      ),
                      selected:
                          registro.estado ==
                          'EXCUSA',
                      selectedColor:
                          Colors.blue,
                      onSelected: (_) =>
                          alCambiarEstado(
                        'EXCUSA',
                      ),
                    ),
                  ],
                ),
              ],
            ),

            if (registro.estado == 'EXCUSA') ...[
              const SizedBox(height: 12),

              TextFormField(
                initialValue: registro.observaciones,
                decoration: const InputDecoration(
                  labelText: 'Observación',
                  hintText: 'Motivo de la excusa',
                ),
                maxLines: 2,
                onChanged: (valor) {
                  registro.observaciones =
                      valor.trim().isEmpty
                          ? null
                          : valor.trim();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}