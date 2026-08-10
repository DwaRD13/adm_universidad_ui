import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/tema.dart';
import '../../../modelos/aula.dart' as modelos;
import '../../../nucleo/formato.dart';
import '../../../proveedores/materiales_proveedor.dart';
import '../../../servicios/archivo_servicio.dart';
import '../../../widgets/comunes.dart';
import '../../../widgets/estado_vista.dart';

/// Materiales de apoyo publicados por los profesores, agrupados por materia.
class MaterialesPantalla extends StatefulWidget {
  const MaterialesPantalla({super.key});

  @override
  State<MaterialesPantalla> createState() => _MaterialesPantallaState();
}

class _MaterialesPantallaState extends State<MaterialesPantalla> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MaterialesProveedor>().cargar();
    });
  }

  Future<void> _abrir(modelos.Material material) async {
    final uri = Uri.tryParse(ArchivoServicio.urlAbsoluta(material.urlArchivo));
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        mostrarAviso(context, 'No se pudo abrir el material.', esError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final proveedor = context.watch<MaterialesProveedor>();
    final grupos = proveedor.porMateria;

    return Scaffold(
      appBar: AppBar(title: const Text('Materiales')),
      body: VistaEstado(
        cargando: proveedor.cargando && !proveedor.cargadoAlgunaVez,
        error: proveedor.error,
        vacio: proveedor.vacio,
        alReintentar: proveedor.cargar,
        skeleton: const CargandoSkeleton(lineas: 5, altura: 76),
        vistaVacia: const EstadoVacio(
          icono: Icons.folder_open_rounded,
          titulo: 'Sin materiales por ahora',
          mensaje:
              'Aquí verás las guías, presentaciones y enlaces que compartan '
              'tus profesores en cada materia.',
        ),
        contenido: (context) => RefreshIndicator(
          onRefresh: () => proveedor.cargar(silencioso: true),
          child: ContenidoCentrado(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                for (final entrada in grupos.entries) ...[
                  EncabezadoSeccion(
                    titulo: entrada.key,
                    subtitulo:
                        '${entrada.value.length} '
                        '${entrada.value.length == 1 ? 'recurso' : 'recursos'}',
                  ),
                  const SizedBox(height: 10),
                  for (var i = 0; i < entrada.value.length; i++)
                    EntradaAnimada(
                      indice: i,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _TarjetaMaterial(
                          material: entrada.value[i],
                          alAbrir: () => _abrir(entrada.value[i]),
                        ),
                      ),
                    ),
                  const SizedBox(height: 14),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TarjetaMaterial extends StatelessWidget {
  const _TarjetaMaterial({required this.material, required this.alAbrir});

  final modelos.Material material;
  final VoidCallback alAbrir;

  /// Icono y color según el tipo declarado en la base de datos.
  (IconData, Color) _apariencia(BuildContext context) {
    final tipo = (material.tipoArchivo ?? '').toLowerCase();
    return switch (tipo) {
      'pdf' => (Icons.picture_as_pdf_rounded, context.estados.error),
      'video' => (Icons.play_circle_outline_rounded, context.estados.info),
      'enlace' => (Icons.link_rounded, context.colores.tertiary),
      _ => (Icons.insert_drive_file_outlined, context.colores.primary),
    };
  }

  @override
  Widget build(BuildContext context) {
    final (icono, color) = _apariencia(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: alAbrir,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icono, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material.titulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textos.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (material.descripcion != null &&
                        material.descripcion!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        material.descripcion!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textos.bodySmall?.copyWith(
                          color: context.colores.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (material.tipoArchivo != null)
                          ChipEstado(
                            texto: material.tipoArchivo!,
                            tono: TonoEstado.neutro,
                          ),
                        const SizedBox(width: 8),
                        Text(
                          Formato.fecha(material.fechaSubida),
                          style: context.textos.labelSmall?.copyWith(
                            color: context.colores.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.open_in_new_rounded,
                size: 18,
                color: context.colores.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
