import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/tema.dart';
import '../proveedores/sesion_proveedor.dart';

/// Los paneles de Profesor y Administrativo se construirán en fases posteriores.
/// Hasta entonces, quienes tienen esos roles ven esta pantalla tras el login.
class RolPendientePantalla extends StatelessWidget {
  const RolPendientePantalla({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<SesionProveedor>().usuario;
    final colores = context.colores;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: colores.tertiaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.construction_rounded,
                    size: 44,
                    color: colores.onTertiaryContainer,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Panel en construcción',
                  textAlign: TextAlign.center,
                  style: context.textos.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Hola ${usuario?.nombres ?? ''}. El panel para el rol '
                  '${usuario?.rol ?? ''} todavía no está disponible. '
                  'Por ahora solo el panel de Estudiante está habilitado.',
                  textAlign: TextAlign.center,
                  style: context.textos.bodyMedium?.copyWith(
                    color: colores.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),
                OutlinedButton.icon(
                  onPressed: () =>
                      context.read<SesionProveedor>().cerrarSesion(),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Cerrar sesión'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(200, 48),
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
