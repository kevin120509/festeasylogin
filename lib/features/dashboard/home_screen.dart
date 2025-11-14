import 'dart:async';

import 'package:festeasy_app/features/dashboard/view/provider_services_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({this.useScaffold = true, super.key});

  final bool useScaffold;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedFilter = 'Próximos';
  late Future<List<Map<String, dynamic>>> _providerEvents;

  @override
  void initState() {
    super.initState();
    _providerEvents = _fetchProviderEvents();
  }

  Future<List<Map<String, dynamic>>> _fetchProviderEvents() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final response = await Supabase.instance.client
          .from('evento_servicios')
          .select('*, eventos(*)')
          .eq('proveedor_id', userId)
          .order('fecha_servicio', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      debugPrint('Error fetching provider events: $e');
      return [];
    } on Exception catch (e) {
      debugPrint('An unexpected error occurred: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget content = Column(
      children: [
        // Tabs de filtro
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _FilterChip(
                label: 'Próximos',
                isSelected: _selectedFilter == 'Próximos',
                onSelected: () {
                  setState(() => _selectedFilter = 'Próximos');
                },
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Pasados',
                isSelected: _selectedFilter == 'Pasados',
                onSelected: () {
                  setState(() => _selectedFilter = 'Pasados');
                },
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Todos',
                isSelected: _selectedFilter == 'Todos',
                onSelected: () {
                  setState(() => _selectedFilter = 'Todos');
                },
              ),
            ],
          ),
        ),
        // Lista de eventos (reservas guardadas en JSON)
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _providerEvents,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final allEvents = snapshot.data ?? [];
              // Convert dates and filter
              final now = DateTime.now();
              final upcoming = <Map<String, dynamic>>[];
              final past = <Map<String, dynamic>>[];
              for (final eventService in allEvents) {
                try {
                  final eventDate = DateTime.parse(
                    eventService['fecha_servicio'] as String,
                  );
                  if (eventDate.isAfter(now)) {
                    upcoming.add(eventService);
                  } else {
                    past.add(eventService);
                  }
                } on FormatException catch (_) {}
              }

              final children = <Widget>[];
              if (_selectedFilter == 'Próximos' || _selectedFilter == 'Todos') {
                children.add(
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      'Próximos',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                );
                if (upcoming.isEmpty) {
                  children.add(
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No hay eventos próximos'),
                    ),
                  );
                } else {
                  children.addAll(
                    upcoming.map((eventService) {
                      final event = eventService['eventos'] as Map<String, dynamic>;
                      final dt = DateTime.parse(
                        eventService['fecha_servicio'] as String,
                      );
                      final fecha = DateFormat('d MMMM', 'es_ES').format(dt);
                      return EventCard(
                        fecha: fecha,
                        titulo: event['titulo']?.toString() ?? '',
                        lugar: event['direccion_texto']?.toString() ?? '',
                        urlImagen:
                            'https://via.placeholder.com/120x120?text=Evento',
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) => const ProviderServicesPage(),
                            ),
                          );
                        },
                      );
                    }),
                  );
                }
              }

              if (_selectedFilter == 'Pasados' || _selectedFilter == 'Todos') {
                children.add(
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Text(
                      'Pasados',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                );
                if (past.isEmpty) {
                  children.add(
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No hay eventos pasados'),
                    ),
                  );
                } else {
                  children.addAll(
                    past.map((eventService) {
                      final event = eventService['eventos'] as Map<String, dynamic>;
                      final dt = DateTime.parse(
                        eventService['fecha_servicio'] as String,
                      );
                      final fecha = DateFormat('d MMMM', 'es_ES').format(dt);
                      return EventCard(
                        fecha: fecha,
                        titulo: event['titulo']?.toString() ?? '',
                        lugar: event['direccion_texto']?.toString() ?? '',
                        urlImagen:
                            'https://via.placeholder.com/120x120?text=Evento',
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) => const ProviderServicesPage(),
                            ),
                          );
                        },
                      );
                    }),
                  );
                }
              }

              children.add(const SizedBox(height: 20));
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children,
                ),
              );
            },
          ),
        ),
      ],
    );

    if (widget.useScaffold) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const SizedBox.shrink(),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar eventos',
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: content,
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: const Color(0xFFEA4D4D),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFFEA4D4D),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Eventos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Perfil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Ajustes',
            ),
          ],
        ),
      );
    } else {
      return content;
    }
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEA4D4D) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  const EventCard({
    required this.fecha,
    required this.titulo,
    required this.lugar,
    required this.urlImagen,
    required this.onTap,
    super.key,
  });

  final String fecha;
  final String titulo;
  final String lugar;
  final String urlImagen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            // Imagen
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Image.network(
                urlImagen,
                width: 100,
                height: 110,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 100,
                    height: 110,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, color: Colors.grey),
                  );
                },
              ),
            ),
            // Contenido
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fecha,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lugar,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
