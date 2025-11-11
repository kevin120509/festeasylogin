import 'package:flutter/material.dart';

class EventDetailPage extends StatelessWidget {
  const EventDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Evento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Nombre del Evento',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Proveedor: Nombre del Proveedor'),
                const SizedBox(height: 8),
                const Text('Fecha: 25 de Diciembre, 2025'),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Text('Estado: '),
                    Chip(
                      label: Text('Confirmado'),
                      backgroundColor: Colors.green,
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        // TODO: Implement cancel logic
                      },
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      label: const Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        // TODO: Implement chat logic
                      },
                      icon: const Icon(Icons.chat),
                      label: const Text('Chat'),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        // TODO: Implement progress logic
                      },
                      icon: const Icon(Icons.timeline),
                      label: const Text('Ver progreso'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
