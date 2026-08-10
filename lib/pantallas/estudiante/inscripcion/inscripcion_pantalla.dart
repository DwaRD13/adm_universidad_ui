import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/tema.dart';
import '../../../modelos/academico.dart';
import '../../../nucleo/formato.dart';
import '../../../proveedores/inscripcion_proveedor.dart';
import '../../../widgets/comunes.dart';
import '../../../widgets/estado_vista.dart';

/// Catálogo de secciones abiertas del periodo y gestión de las inscripciones
/// propias (inscribirse y retirarse).
class InscripcionPantalla extends StatefulWidget {
  const InscripcionPantalla({super.key});

  @override
  State<InscripcionPantalla> createState() => _InscripcionPantallaState();
}

class _InscripcionPantallaState extends State<InscripcionPantalla> {
  final _buscador = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InscripcionProveedor>().cargar();
    });
  }

  @override
  void dispose() {
    _buscador.dispose();
    super.dispose();
  }

  Future<void> _inscribir(SeccionDisponible seccion) async {
    final proveedor = context.read<InscripcionProveedor>();

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogo) => AlertDialog(
        title: const Text('Confirmar inscripción'),
        content: Text(
          '¿Deseas inscribirte en ${seccion.materia} (${seccion.codigoMateria}) '
          'con ${seccion.profesor}?\n\n'
          '${seccion.horarioDescripcion ?? 'Horario por definir'}'
          '${seccion.aula != null ? ' · Aula ${seccion.aula}' : ''}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogo, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogo, true),
            child: const Text('Inscribirme'),
          ),
        ],
      ),
    );

    if (confirmado != true || !mounted) return;

    final error = await proveedor.inscribir(seccion.seccionId);
    if (!mounted) return;

    mostrarAviso(
      context,
      error ?? 'Te inscribiste en ${seccion.materia}.',
      esError: error != null,
    );
  }

  Future<void> _retirar(Inscripcion inscripcion) async {
    final proveedor = context.read<InscripcionProveedor>();

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogo) => AlertDialog(
        title: const Text('Retirar materia'),
        content: Text(
          '¿Seguro que deseas retirarte de ${inscripcion.materia}? '
          'La materia dejará de aparecer en tu horario.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogo, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogo, true),
            style: FilledButton.styleFrom(
              backgroundColor: context.colores.error,
              foregroundColor: context.colores.onError,
            ),
            child: const Text('Retirarme'),
          ),
        ],
      ),
    );

    if (confirmado != true || !mounted) return;

    final error = await proveedor.retirar(inscripcion.id);
    if (!mounted) return;

    mostrarAviso(
      context,
      error ?? 'Te retiraste de ${inscripcion.materia}.',
      esError: error != null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final proveedor = context.watch<InscripcionProveedor>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Inscripción'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Disponibles'),
              Tab(text: 'Mis materias'),
            ],
          ),
        ),
        body: VistaEstado(
          cargando: proveedor.cargando && !proveedor.cargadoAlgunaVez,
          error: proveedor.error,
          vacio: false,
          alReintentar: proveedor.cargar,
          skeleton: const CargandoSkeleton(lineas: 4, altura: 130),
          vistaVacia: const SizedBox.shrink(),
          contenido: (context) => TabBarView(
            children: [
              _PestanaCatalogo(
                proveedor: proveedor,
                buscador: _buscador,
                alInscribir: _inscribir,
              ),
              _PestanaMisMaterias(proveedor: proveedor, alRetirar: _retirar),
            ],
          ),
        ),
      ),
    );
  }
}

class _PestanaCatalogo extends StatelessWidget {
  const _PestanaCatalogo({
    required this.proveedor,
    required this.buscador,
    required this.alInscribir,
  });

  final InscripcionProveedor proveedor;
  final TextEditingController buscador;
  final Future<void> Function(SeccionDisponible) alInscribir;

  @override
  Widget build(BuildContext context) {
    final secciones = proveedor.disponibles;

    return Column(
      children: [
        ContenidoCentrado(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: buscador,
              onChanged: proveedor.buscar,
              decoration: InputDecoration(
                hintText: 'Buscar materia, código o profesor',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: proveedor.busqueda.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          buscador.clear();
                          proveedor.buscar('');
                        },
                      ),
              ),
            ),
          ),
        ),
        if (proveedor.carreras.length > 1)
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                FilterChip(
                  label: const Text('Todas'),
                  selected: proveedor.carreraFiltro == null,
                  onSelected: (_) => proveedor.filtrarPorCarrera(null),
                ),
                const SizedBox(width: 8),
                for (final carrera in proveedor.carreras) ...[
                  FilterChip(
                    label: Text(carrera),
                    selected: proveedor.carreraFiltro == carrera,
                    onSelected: (seleccionada) => proveedor.filtrarPorCarrera(
                      seleccionada ? carrera : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        Expanded(
          child: secciones.isEmpty
              ? const EstadoVacio(
                  icono: Icons.search_off_rounded,
                  titulo: 'Sin resultados',
                  mensaje:
                      'No hay secciones abiertas que coincidan con tu búsqueda.',
                )
              : RefreshIndicator(
                  onRefresh: () => proveedor.cargar(silencioso: true),
                  child: ContenidoCentrado(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                      itemCount: secciones.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, indice) => EntradaAnimada(
                        indice: indice,
                        child: _TarjetaSeccion(
                          seccion: secciones[indice],
                          procesando:
                              proveedor.seccionEnProceso ==
                              secciones[indice].seccionId,
                          alInscribir: () => alInscribir(secciones[indice]),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _TarjetaSeccion extends StatelessWidget {
  const _TarjetaSeccion({
    required this.seccion,
    required this.procesando,
    required this.alInscribir,
  });

  final SeccionDisponible seccion;
  final bool procesando;
  final VoidCallback alInscribir;

  @override
  Widget build(BuildContext context) {
    final estados = context.estados;
    final colorCupo = seccion.sinCupo
        ? estados.error
        : seccion.ocupacion > 0.8
        ? estados.advertencia
        : estados.exito;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    seccion.materia,
                    style: context.textos.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ChipEstado(
                  texto: seccion.codigoMateria,
                  tono: TonoEstado.neutro,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${seccion.creditos} créditos'
              '${seccion.carrera != null ? ' · ${seccion.carrera}' : ''}',
              style: context.textos.bodySmall?.copyWith(
                color: context.colores.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            _Dato(icono: Icons.person_outline_rounded, texto: seccion.profesor),
            _Dato(
              icono: Icons.schedule_rounded,
              texto: seccion.horarioDescripcion ?? 'Horario por definir',
            ),
            if (seccion.aula != null)
              _Dato(
                icono: Icons.meeting_room_outlined,
                texto: 'Aula ${seccion.aula}',
              ),
            const SizedBox(height: 14),

            Row(
              children: [
                Text(
                  'Cupo ${seccion.cupoOcupado}/${seccion.cupoMaximo}',
                  style: context.textos.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorCupo,
                  ),
                ),
                const Spacer(),
                Text(
                  seccion.sinCupo
                      ? 'Sin cupo'
                      : '${seccion.cupoDisponible} disponibles',
                  style: context.textos.labelSmall?.copyWith(
                    color: context.colores.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            BarraProgreso(valor: seccion.ocupacion, color: colorCupo),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: seccion.yaInscrito
                  ? OutlinedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.check_circle_rounded, size: 18),
                      label: const Text('Ya estás inscrito'),
                    )
                  : FilledButton.icon(
                      onPressed: seccion.sinCupo || procesando
                          ? null
                          : alInscribir,
                      icon: procesando
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add_rounded, size: 20),
                      label: Text(
                        seccion.sinCupo ? 'Sin cupo disponible' : 'Inscribirme',
                      ),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(46),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PestanaMisMaterias extends StatelessWidget {
  const _PestanaMisMaterias({required this.proveedor, required this.alRetirar});

  final InscripcionProveedor proveedor;
  final Future<void> Function(Inscripcion) alRetirar;

  @override
  Widget build(BuildContext context) {
    final inscripciones = proveedor.misInscripciones;

    if (inscripciones.isEmpty) {
      return const EstadoVacio(
        icono: Icons.playlist_add_rounded,
        titulo: 'Sin materias inscritas',
        mensaje:
            'Explora las secciones disponibles y elige tus materias del periodo.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => proveedor.cargar(silencioso: true),
      child: ContenidoCentrado(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          itemCount: inscripciones.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, indice) {
            final inscripcion = inscripciones[indice];
            return EntradaAnimada(
              indice: indice,
              child: _TarjetaInscripcion(
                inscripcion: inscripcion,
                procesando: proveedor.inscripcionEnProceso == inscripcion.id,
                alRetirar: () => alRetirar(inscripcion),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TarjetaInscripcion extends StatelessWidget {
  const _TarjetaInscripcion({
    required this.inscripcion,
    required this.procesando,
    required this.alRetirar,
  });

  final Inscripcion inscripcion;
  final bool procesando;
  final VoidCallback alRetirar;

  (TonoEstado, IconData) get _apariencia => switch (inscripcion.estado) {
    'Aprobado' => (TonoEstado.exito, Icons.check_circle_outline_rounded),
    'Reprobado' => (TonoEstado.error, Icons.cancel_outlined),
    'Retirado' => (TonoEstado.neutro, Icons.remove_circle_outline_rounded),
    _ => (TonoEstado.info, Icons.play_circle_outline_rounded),
  };

  @override
  Widget build(BuildContext context) {
    final (tono, icono) = _apariencia;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        inscripcion.materia,
                        style: context.textos.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${inscripcion.codigoMateria} · ${inscripcion.periodo ?? ''}',
                        style: context.textos.bodySmall?.copyWith(
                          color: context.colores.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ChipEstado(
                  texto: inscripcion.estado ?? 'Inscrito',
                  tono: tono,
                  icono: icono,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _Dato(
              icono: Icons.person_outline_rounded,
              texto: inscripcion.profesor,
            ),
            _Dato(
              icono: Icons.schedule_rounded,
              texto: inscripcion.horarioDescripcion ?? 'Horario por definir',
            ),
            _Dato(
              icono: Icons.event_available_rounded,
              texto:
                  'Inscrita el ${Formato.fecha(inscripcion.fechaInscripcion)}',
            ),
            if (inscripcion.puedeRetirarse) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: procesando ? null : alRetirar,
                  icon: procesando
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(
                          Icons.remove_circle_outline_rounded,
                          size: 18,
                        ),
                  label: const Text('Retirarme'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.colores.error,
                    side: BorderSide(
                      color: context.colores.error.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato({required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Icon(icono, size: 15, color: context.colores.onSurfaceVariant),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              texto,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textos.bodySmall?.copyWith(
                color: context.colores.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
