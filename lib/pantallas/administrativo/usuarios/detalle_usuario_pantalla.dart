import 'package:adm_universidad_ui/app/tema.dart';
import 'package:adm_universidad_ui/modelos/usuario_admin.dart';
import 'package:adm_universidad_ui/nucleo/formato.dart';
import 'package:adm_universidad_ui/proveedores/usuarios_proveedor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DetalleUsuarioPantalla extends StatelessWidget {
  final int id;
  const DetalleUsuarioPantalla({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final proveedor = context.watch<UsuariosProveedor>();
    final usuario = proveedor.usuarios.firstWhere(
      (u) => u.id == id,
      orElse: () => UsuarioAdmin(
        id: id,
        nombres: 'Desconocido',
        apellidos: '',
        email: '',
        rol: 'Sin rol',
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(usuario.nombreCompleto)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: context.colores.primaryContainer,
              child: Text(
                Formato.iniciales(usuario.nombreCompleto),
                style: context.textos.headlineSmall?.copyWith(
                  color: context.colores.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _CampoDetalle(label: 'Email', valor: usuario.email),
            const SizedBox(height: 12),
            _CampoDetalle(label: 'Rol', valor: usuario.rol),
            const SizedBox(height: 12),
            _CampoDetalle(label: 'Estado', valor: usuario.estado ?? 'N/A'),
            const SizedBox(height: 12),
            _CampoDetalle(
              label: 'Matrícula / ID empleado',
              valor: usuario.matricula ?? 'N/A',
            ),
            const SizedBox(height: 24),
            // Botones de acción
          ],
        ),
      ),
    );
  }
}

class _CampoDetalle extends StatelessWidget {
  final String label;
  final String valor;
  const _CampoDetalle({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textos.labelMedium?.copyWith(
            color: context.colores.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(valor, style: context.textos.bodyLarge),
      ],
    );
  }
}
