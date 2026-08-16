import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/tema.dart';
import '../../modelos/profesor/materia_profesor.dart';
import '../../proveedores/materias_profesor_proveedor.dart';
import '../../widgets/comunes.dart';
import '../../widgets/estado_vista.dart';

class MateriasProfesorPantalla extends StatefulWidget {
  const MateriasProfesorPantalla({super.key});

  @override
  State<MateriasProfesorPantalla> createState() =>
      _MateriasProfesorPantallaState();
}

class _MateriasProfesorPantallaState
    extends State<MateriasProfesorPantalla> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MateriasProfesorProveedor>().cargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final proveedor = context.watch<MateriasProfesorProveedor>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Materias'),
      ),
      body: VistaEstado(
        cargando:
            proveedor.cargando && !proveedor.cargadoAlgunaVez,
        error: proveedor.error,
        vacio: proveedor.vacio,
        alReintentar: proveedor.cargar,
        skeleton: const CargandoSkeleton(
          lineas: 4,
          altura: 110,
        ),
        vistaVacia: const EstadoVacio(
          icono: Icons.menu_book_rounded,
          titulo: 'Sin materias asignadas',
          mensaje:
              'Cuando tengas secciones asignadas aparecerán aquí.',
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
                _ResumenMaterias(
                  materias: proveedor.materias,
                ),
                const SizedBox(height: 24),
                EncabezadoSeccion(
                  titulo: 'Mis materias',
                  subtitulo:
                      '${proveedor.materias.length} secciones activas',
                ),
                const SizedBox(height: 12),
                for (var i = 0;
                    i < proveedor.materias.length;
                    i++)
                  EntradaAnimada(
                    indice: i,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(bottom: 12),
                      child: _TarjetaMateria(
                        materia: proveedor.materias[i],
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

class _ResumenMaterias extends StatelessWidget {
  const _ResumenMaterias({
    required this.materias,
  });

  final List<MateriaProfesor> materias;

  @override
  Widget build(BuildContext context) {
    final totalEstudiantes = materias.fold<int>(
      0,
      (suma, materia) => suma + materia.inscritos,
    );

    return TarjetaHero(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Tus asignaciones',
            style: context.textos.labelLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '${materias.length}',
            style: context.textos.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            materias.length == 1
                ? 'Materia activa'
                : 'Materias activas',
            style: context.textos.titleMedium,
          ),
          const SizedBox(height: 16),
          ChipEstado(
            texto:
                '$totalEstudiantes estudiantes inscritos',
            tono: TonoEstado.info,
          ),
        ],
      ),
    );
  }
}

class _TarjetaMateria extends StatelessWidget {
  const _TarjetaMateria({
    required this.materia,
  });

  final MateriaProfesor materia;

  @override
  Widget build(BuildContext context) {
        return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    materia.materia,
                    style: context.textos.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                ChipEstado(
                  texto: materia.estado ?? 'Activa',
                  tono: TonoEstado.info,
                ),
              ],
            ),

            const SizedBox(height: 6),

            Text(
              materia.codigoMateria,
              style: context.textos.bodySmall?.copyWith(
                color: context.colores.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Icon(
                  Icons.groups_rounded,
                  size: 18,
                  color: context.colores.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  '${materia.inscritos} inscritos',
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Icon(
                  Icons.school_rounded,
                  size: 18,
                  color: context.colores.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  '${materia.creditos} créditos',
                ),
              ],
            ),

            if (materia.aula != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.room_rounded,
                    size: 18,
                    color: context.colores.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(materia.aula!),
                ],
              ),
            ],

            const SizedBox(height: 16),

            Divider(
              color: context.colores.outlineVariant,
            ),

            const SizedBox(height: 8),

            Text(
              'Periodo ${materia.periodo}',
              style: context.textos.bodySmall?.copyWith(
                color: context.colores.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}