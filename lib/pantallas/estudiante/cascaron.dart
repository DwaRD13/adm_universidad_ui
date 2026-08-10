import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/router.dart';
import '../../proveedores/mensajes_proveedor.dart';

/// Estructura común de los cinco destinos principales del estudiante.
///
/// Mantiene la barra inferior fija mientras el contenido cambia, de modo que
/// cambiar de pestaña no reconstruye todo el Scaffold.
class CascaronEstudiante extends StatelessWidget {
  const CascaronEstudiante({
    super.key,
    required this.rutaActual,
    required this.child,
  });

  final String rutaActual;
  final Widget child;

  static const List<_Destino> _destinos = [
    _Destino(
      Rutas.dashboard,
      Icons.home_outlined,
      Icons.home_rounded,
      'Inicio',
    ),
    _Destino(
      Rutas.horario,
      Icons.calendar_today_outlined,
      Icons.calendar_today_rounded,
      'Horario',
    ),
    _Destino(
      Rutas.calificaciones,
      Icons.grade_outlined,
      Icons.grade_rounded,
      'Notas',
    ),
    _Destino(
      Rutas.mensajes,
      Icons.chat_bubble_outline_rounded,
      Icons.chat_bubble_rounded,
      'Mensajes',
    ),
    _Destino(
      Rutas.perfil,
      Icons.person_outline_rounded,
      Icons.person_rounded,
      'Perfil',
    ),
  ];

  int get _indiceActual {
    final indice = _destinos.indexWhere((d) => d.ruta == rutaActual);
    return indice < 0 ? 0 : indice;
  }

  @override
  Widget build(BuildContext context) {
    // Solo el contador de no leídos se observa aquí; el resto del cascarón es estático.
    final sinLeer = context.select<MensajesProveedor, int>(
      (p) => p.totalSinLeer,
    );

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indiceActual,
        onDestinationSelected: (indice) => context.go(_destinos[indice].ruta),
        destinations: [
          for (final destino in _destinos)
            NavigationDestination(
              icon: destino.ruta == Rutas.mensajes && sinLeer > 0
                  ? Badge.count(count: sinLeer, child: Icon(destino.icono))
                  : Icon(destino.icono),
              selectedIcon: destino.ruta == Rutas.mensajes && sinLeer > 0
                  ? Badge.count(
                      count: sinLeer,
                      child: Icon(destino.iconoActivo),
                    )
                  : Icon(destino.iconoActivo),
              label: destino.etiqueta,
            ),
        ],
      ),
    );
  }
}

class _Destino {
  const _Destino(this.ruta, this.icono, this.iconoActivo, this.etiqueta);

  final String ruta;
  final IconData icono;
  final IconData iconoActivo;
  final String etiqueta;
}
