import 'package:flutter/material.dart';

class TareasProfesorScreen extends StatelessWidget {
  const TareasProfesorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Tareas'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Tareas',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 8),

          Text(
            'Administra las tareas y revisa las entregas de tus estudiantes.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),

          const SizedBox(height: 20),

          Card(
            child: ListTile(
              leading: const Icon(Icons.assignment_rounded),
              title: const Text('Ejercicio de Programación'),
              subtitle: const Text(
                '18 entregas pendientes de revisión',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {},
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.assignment_rounded),
              title: const Text('Proyecto Final'),
              subtitle: const Text(
                '12 entregas pendientes de revisión',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {},
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(Icons.assignment_rounded),
              title: const Text('Práctica SQL'),
              subtitle: const Text(
                '25 entregas pendientes de revisión',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {},
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nueva tarea'),
      ),
    );
  }
}