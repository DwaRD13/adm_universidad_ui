import 'package:flutter/material.dart';

class MensajesProfesorScreen extends StatelessWidget {
  const MensajesProfesorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;

    final mensajes = [
      {
        'nombre': 'Carlos Rodríguez',
        'mensaje': 'Profesor, tengo una duda con la asignación.',
        'hora': '10:30 AM',
        'sinLeer': true,
      },
      {
        'nombre': 'María Pérez',
        'mensaje': '¿Podría revisar mi proyecto?',
        'hora': '9:45 AM',
        'sinLeer': true,
      },
      {
        'nombre': 'José Martínez',
        'mensaje': 'Gracias por la explicación de hoy.',
        'hora': 'Ayer',
        'sinLeer': false,
      },
      {
        'nombre': 'Ana López',
        'mensaje': '¿Cuándo será la próxima evaluación?',
        'hora': 'Ayer',
        'sinLeer': false,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mensajes de Alumnos'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              'Conversaciones',
              style: textos.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 8),

          ...mensajes.map(
            (mensaje) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),

                leading: CircleAvatar(
                  radius: 25,
                  backgroundColor: colores.primaryContainer,
                  child: Icon(
                    Icons.person_rounded,
                    color: colores.onPrimaryContainer,
                  ),
                ),

                title: Text(
                  mensaje['nombre']! as String,
                  style: textos.titleSmall?.copyWith(
                    fontWeight: mensaje['sinLeer'] == true
                        ? FontWeight.bold
                        : FontWeight.w500,
                  ),
                ),

                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    mensaje['mensaje']! as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      mensaje['hora']! as String,
                      style: textos.bodySmall?.copyWith(
                        color: mensaje['sinLeer'] == true
                            ? colores.primary
                            : colores.onSurfaceVariant,
                        fontWeight: mensaje['sinLeer'] == true
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),

                    if (mensaje['sinLeer'] == true) ...[
                      const SizedBox(height: 6),
                      Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: colores.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),

                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Abriendo conversación con ${mensaje['nombre']}',
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nuevo mensaje'),
            ),
          );
        },
        child: const Icon(Icons.edit_rounded),
      ),
    );
  }
}