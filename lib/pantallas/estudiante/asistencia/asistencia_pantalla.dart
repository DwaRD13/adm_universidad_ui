import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/tema.dart';
import '../../../modelos/academico.dart';
import '../../../nucleo/formato.dart';
import '../../../proveedores/asistencia_proveedor.dart';
import '../../../widgets/comunes.dart';
import '../../../widgets/estado_vista.dart';

/// Asistencia del estudiante, agrupada por materia y solo de lectura.
class AsistenciaPantalla extends StatefulWidget {
  const AsistenciaPantalla({super.key});

  @override
  State<AsistenciaPantalla> createState() => _AsistenciaPantallaState();
}

class _AsistenciaPantallaState extends State<AsistenciaPantalla> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AsistenciaProveedor>().cargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final proveedor = context.watch<AsistenciaProveedor>();
    final datos = proveedor.datos;

    return Scaffold(
      appBar: AppBar(title: const Text('Asistencia')),
      body: VistaEstado(
        cargando: proveedor.cargando && !proveedor.cargadoAlgunaVez,
        error: proveedor.error,
        vacio: proveedor.vacio,
        alReintentar: proveedor.cargar,
        skeleton: const CargandoSkeleton(lineas: 4, altura: 110),
        vistaVacia: const EstadoVacio(
          icono: Icons.how_to_reg_rounded,
          titulo: 'Sin registros de asistencia',
          mensaje:
              'Cuando tus profesores empiecen a pasar lista, verás aquí el '
              'detalle de cada clase.',
        ),
        contenido: (context) => RefreshIndicator(
          onRefresh: () => proveedor.cargar(silencioso: true),
          child: ContenidoCentrado(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                _ResumenGeneral(datos: datos!),
                const SizedBox(height: 24),
                const EncabezadoSeccion(
                  titulo: 'Por materia',
                  subtitulo:
                      'Toca una materia para ver el detalle de cada clase',
                ),
                const SizedBox(height: 12),
                for (var i = 0; i < datos.materias.length; i++)
                  EntradaAnimada(
                    indice: i,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _TarjetaMateria(materia: datos.materias[i]),
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

class _ResumenGeneral extends StatelessWidget {
  const _ResumenGeneral({required this.datos});

  final Asistencia datos;

  @override
  Widget build(BuildContext context) {
    final porcentaje = datos.porcentajeGeneral ?? 0;
    final estados = context.estados;
    final color = porcentaje >= 80
        ? estados.exito
        : porcentaje >= 60
        ? estados.advertencia
        : estados.error;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            AnilloProgreso(
              valor: porcentaje,
              etiqueta: 'general',
              tamano: 110,
              color: color,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Asistencia del periodo',
                    style: context.textos.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${datos.totalClases} clases registradas en '
                    '${datos.materias.length} materias.',
                    style: context.textos.bodySmall?.copyWith(
                      color: context.colores.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    porcentaje >= 80
                        ? 'Vas muy bien, mantén el ritmo.'
                        : porcentaje >= 60
                        ? 'Cuida tus ausencias para no comprometer el periodo.'
                        : 'Tu asistencia está baja. Habla con tus profesores.',
                    style: context.textos.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
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

class _TarjetaMateria extends StatelessWidget {
  const _TarjetaMateria({required this.materia});

  final MateriaAsistencia materia;

  @override
  Widget build(BuildContext context) {
    final estados = context.estados;
    final porcentaje = materia.porcentaje ?? 0;
    final color = porcentaje >= 80
        ? estados.exito
        : porcentaje >= 60
        ? estados.advertencia
        : estados.error;

    return Card(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          shape: const Border(),
          title: Text(
            materia.materia,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.textos.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      Formato.porcentaje(materia.porcentaje),
                      style: context.textos.labelLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${materia.totalClases} clases',
                      style: context.textos.labelSmall?.copyWith(
                        color: context.colores.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                BarraProgreso(valor: porcentaje / 100, color: color),
              ],
            ),
          ),
          children: [
            const Divider(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Conteo(
                  etiqueta: 'Presente',
                  valor: materia.presentes,
                  tono: TonoEstado.exito,
                ),
                _Conteo(
                  etiqueta: 'Tardanza',
                  valor: materia.tardanzas,
                  tono: TonoEstado.advertencia,
                ),
                _Conteo(
                  etiqueta: 'Excusa',
                  valor: materia.excusas,
                  tono: TonoEstado.info,
                ),
                _Conteo(
                  etiqueta: 'Ausente',
                  valor: materia.ausentes,
                  tono: TonoEstado.error,
                ),
              ],
            ),
            if (materia.registros.isNotEmpty) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Detalle de clases',
                  style: context.textos.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              for (final registro in materia.registros)
                _FilaRegistro(registro: registro),
            ],
          ],
        ),
      ),
    );
  }
}

class _Conteo extends StatelessWidget {
  const _Conteo({
    required this.etiqueta,
    required this.valor,
    required this.tono,
  });

  final String etiqueta;
  final int valor;
  final TonoEstado tono;

  @override
  Widget build(BuildContext context) {
    return ChipEstado(texto: '$etiqueta: $valor', tono: tono);
  }
}

class _FilaRegistro extends StatelessWidget {
  const _FilaRegistro({required this.registro});

  final RegistroAsistencia registro;

  (TonoEstado, IconData) get _apariencia => switch (registro.estado) {
    'Presente' => (TonoEstado.exito, Icons.check_circle_rounded),
    'Tardanza' => (TonoEstado.advertencia, Icons.schedule_rounded),
    'Excusa' => (TonoEstado.info, Icons.assignment_turned_in_rounded),
    _ => (TonoEstado.error, Icons.cancel_rounded),
  };

  @override
  Widget build(BuildContext context) {
    final (tono, icono) = _apariencia;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${Formato.diaSemana(registro.fecha)}, ${Formato.fecha(registro.fecha)}',
                  style: context.textos.bodySmall,
                ),
                if (registro.observaciones != null)
                  Text(
                    registro.observaciones!,
                    style: context.textos.labelSmall?.copyWith(
                      color: context.colores.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ChipEstado(texto: registro.estado, tono: tono, icono: icono),
        ],
      ),
    );
  }
}
