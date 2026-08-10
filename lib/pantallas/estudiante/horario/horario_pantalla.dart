import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/router.dart';
import '../../../app/tema.dart';
import '../../../modelos/academico.dart';
import '../../../proveedores/horario_proveedor.dart';
import '../../../widgets/comunes.dart';
import '../../../widgets/estado_vista.dart';

/// Horario semanal del estudiante: una pestaña por día con clase, más una
/// pestaña con el listado completo de materias del periodo.
class HorarioPantalla extends StatefulWidget {
  const HorarioPantalla({super.key});

  @override
  State<HorarioPantalla> createState() => _HorarioPantallaState();
}

class _HorarioPantallaState extends State<HorarioPantalla> {
  static const Map<String, String> _nombresDia = {
    'Lu': 'Lunes',
    'Ma': 'Martes',
    'Mi': 'Miércoles',
    'Ju': 'Jueves',
    'Vi': 'Viernes',
    'Sa': 'Sábado',
  };

  /// Código del día de hoy, para abrir la pestaña correspondiente al entrar.
  static const List<String> _codigosPorDiaSemana = [
    'Lu',
    'Ma',
    'Mi',
    'Ju',
    'Vi',
    'Sa',
    'Do',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HorarioProveedor>().cargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final proveedor = context.watch<HorarioProveedor>();
    final dias = proveedor.diasConClase;

    // La primera pestaña seleccionada es la de hoy si hay clase; si no, la primera.
    final hoy = _codigosPorDiaSemana[DateTime.now().weekday - 1];
    final indiceInicial = dias.contains(hoy) ? dias.indexOf(hoy) : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi horario'),
        actions: [
          if (proveedor.clases.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: ChipEstado(
                  texto: '${proveedor.totalCreditos} créditos',
                  tono: TonoEstado.info,
                ),
              ),
            ),
        ],
      ),
      body: VistaEstado(
        cargando: proveedor.cargando && !proveedor.cargadoAlgunaVez,
        error: proveedor.error,
        vacio: proveedor.vacio,
        alReintentar: proveedor.cargar,
        skeleton: const CargandoSkeleton(lineas: 4, altura: 96),
        vistaVacia: EstadoVacio(
          icono: Icons.calendar_today_rounded,
          titulo: 'Tu horario está vacío',
          mensaje:
              'Cuando te inscribas en secciones de este periodo, tus clases '
              'aparecerán organizadas por día.',
          textoAccion: 'Ir a inscripción',
          accion: () => context.push(Rutas.inscripcion),
        ),
        contenido: (context) => DefaultTabController(
          length: dias.length + 1,
          initialIndex: indiceInicial,
          child: Column(
            children: [
              ContenidoCentrado(
                child: TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: [
                    for (final dia in dias) Tab(text: _nombresDia[dia] ?? dia),
                    const Tab(text: 'Todas'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    for (final dia in dias)
                      _ListaClases(
                        clases: proveedor.delDia(dia),
                        alRefrescar: () => proveedor.cargar(silencioso: true),
                      ),
                    _ListaClases(
                      clases: proveedor.clases,
                      mostrarDias: true,
                      alRefrescar: () => proveedor.cargar(silencioso: true),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListaClases extends StatelessWidget {
  const _ListaClases({
    required this.clases,
    required this.alRefrescar,
    this.mostrarDias = false,
  });

  final List<ClaseHorario> clases;
  final Future<void> Function() alRefrescar;
  final bool mostrarDias;

  @override
  Widget build(BuildContext context) {
    if (clases.isEmpty) {
      return const EstadoVacio(
        icono: Icons.free_breakfast_rounded,
        titulo: 'Día libre',
        mensaje: 'No tienes clases programadas este día.',
      );
    }

    return RefreshIndicator(
      onRefresh: alRefrescar,
      child: ContenidoCentrado(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          itemCount: clases.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, indice) => EntradaAnimada(
            indice: indice,
            child: _TarjetaClase(
              clase: clases[indice],
              mostrarDias: mostrarDias,
            ),
          ),
        ),
      ),
    );
  }
}

class _TarjetaClase extends StatelessWidget {
  const _TarjetaClase({required this.clase, required this.mostrarDias});

  final ClaseHorario clase;
  final bool mostrarDias;

  @override
  Widget build(BuildContext context) {
    // Color estable por materia: el mismo código siempre da el mismo tono, aquí
    // y en cualquier otra pantalla que use la paleta académica.
    final color = context.academica.porNombre(clase.codigoMateria);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 5,
              height: 68,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          clase.materia,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.textos.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ChipEstado(
                        texto: clase.codigoMateria,
                        tono: TonoEstado.neutro,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _Detalle(
                    icono: Icons.schedule_rounded,
                    texto: clase.rangoHorario,
                  ),
                  if (clase.aula != null)
                    _Detalle(
                      icono: Icons.meeting_room_outlined,
                      texto: 'Aula ${clase.aula}',
                    ),
                  _Detalle(
                    icono: Icons.person_outline_rounded,
                    texto: clase.profesor,
                  ),
                  if (mostrarDias && clase.dias.isNotEmpty)
                    _Detalle(
                      icono: Icons.event_repeat_rounded,
                      texto: clase.dias.join(' · '),
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

class _Detalle extends StatelessWidget {
  const _Detalle({required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
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
