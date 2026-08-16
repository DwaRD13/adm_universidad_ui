import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';

class CascaronProfesor extends StatelessWidget {
  const CascaronProfesor({
    super.key,
    required this.rutaActual,
    required this.child,
  });

  final String rutaActual;
  final Widget child;

  static const List<_Destino> _destinos = [
    _Destino(
      Rutas.dashboardProfesor,
      Icons.home_outlined,
      Icons.home_rounded,
      'Inicio',
    ),
    _Destino(
      Rutas.materiasProfesor,
      Icons.menu_book_outlined,
      Icons.menu_book_rounded,
      'Materias',
    ),
    _Destino(
      Rutas.tareasProfesor,
      Icons.assignment_outlined,
      Icons.assignment_rounded,
      'Tareas',
    ),
    _Destino(
      Rutas.mensajesProfesor,
      Icons.chat_bubble_outline_rounded,
      Icons.chat_bubble_rounded,
      'Mensajes',
    ),
    _Destino(
      Rutas.calificacionesProfesor,
      Icons.grade_outlined,
      Icons.grade_rounded,
      'Notas',
    ),
  ];

  int get _indiceActual {
    final indice = _destinos.indexWhere(
      (d) => d.ruta == rutaActual,
    );

    return indice < 0 ? 0 : indice;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indiceActual,
        onDestinationSelected: (indice) {
          context.go(
            _destinos[indice].ruta,
          );
        },
        destinations: [
          for (final destino in _destinos)
            NavigationDestination(
              icon: Icon(destino.icono),
              selectedIcon:
                  Icon(destino.iconoActivo),
              label: destino.etiqueta,
            ),
        ],
      ),
    );
  }
}

class _Destino {
  const _Destino(
    this.ruta,
    this.icono,
    this.iconoActivo,
    this.etiqueta,
  );

  final String ruta;
  final IconData icono;
  final IconData iconoActivo;
  final String etiqueta;
}