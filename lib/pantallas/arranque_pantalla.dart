import 'package:flutter/material.dart';

import '../app/constantes.dart';
import '../app/tema.dart';

/// Pantalla que se ve mientras se restaura la sesión guardada.
class ArranquePantalla extends StatelessWidget {
  const ArranquePantalla({super.key});

  @override
  Widget build(BuildContext context) {
    final colores = context.colores;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mismo logotipo que el login: el arranque no debe verse como otra app.
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [colores.primary, colores.secondary],
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                Icons.school_rounded,
                size: 44,
                color: colores.onPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              Constantes.nombreInstitucion,
              style: context.textos.headlineSmall,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.6,
                color: colores.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
