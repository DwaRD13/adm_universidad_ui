import 'package:flutter/material.dart';

class MaterialesProfesorScreen extends StatelessWidget {
  const MaterialesProfesorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Materiales de Clase'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Materiales',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 8),

          Text(
            'Comparte recursos y documentos con tus estudiantes.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colores.onSurfaceVariant,
                ),
          ),

          const SizedBox(height: 20),

          Card(
            child: ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colores.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.picture_as_pdf_rounded,
                  color: colores.onErrorContainer,
                ),
              ),
              title: const Text(
                'Presentación Tema 1',
              ),
              subtitle: const Text(
                'Programación Orientada a Objetos',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.download_rounded),
                onPressed: () {},
              ),
            ),
          ),

          Card(
            child: ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colores.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.picture_as_pdf_rounded,
                  color: colores.onErrorContainer,
                ),
              ),
              title: const Text(
                'Guía de ejercicios',
              ),
              subtitle: const Text(
                'Programación Orientada a Objetos',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.download_rounded),
                onPressed: () {},
              ),
            ),
          ),

          Card(
            child: ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colores.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.description_rounded,
                  color: colores.onSecondaryContainer,
                ),
              ),
              title: const Text(
                'Material de apoyo',
              ),
              subtitle: const Text(
                'Ingeniería de Software',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.download_rounded),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.upload_file_rounded),
        label: const Text('Subir material'),
      ),
    );
  }
}