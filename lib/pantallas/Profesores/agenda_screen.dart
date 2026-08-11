import 'package:flutter/material.dart';

class AgendaProfesorScreen extends StatelessWidget {
  const AgendaProfesorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;

    final clases = [
      {
        'materia': 'Programación Orientada a Objetos',
        'hora': '8:00 AM - 10:00 AM',
        'aula': 'Aula 204',
        'estado': 'Próxima',
      },
      {
        'materia': 'Ingeniería de Software',
        'hora': '11:00 AM - 1:00 PM',
        'aula': 'Aula 301',
        'estado': 'Próxima',
      },
      {
        'materia': 'Bases de Datos',
        'hora': '3:00 PM - 5:00 PM',
        'aula': 'Laboratorio 2',
        'estado': 'Próxima',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Agenda'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Agenda de hoy',
            style: textos.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Consulta tus clases y horarios programados.',
            style: textos.bodyMedium?.copyWith(
              color: colores.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 20),

          ...clases.map(
            (clase) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: colores.primaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.calendar_month_rounded,
                        color: colores.onPrimaryContainer,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            clase['materia']!,
                            style: textos.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 16,
                                color: colores.onSurfaceVariant,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                clase['hora']!,
                                style: textos.bodySmall?.copyWith(
                                  color: colores.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 4),

                          Row(
                            children: [
                              Icon(
                                Icons.room_rounded,
                                size: 16,
                                color: colores.onSurfaceVariant,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                clase['aula']!,
                                style: textos.bodySmall?.copyWith(
                                  color: colores.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colores.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        clase['estado']!,
                        style: textos.labelSmall?.copyWith(
                          color: colores.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}