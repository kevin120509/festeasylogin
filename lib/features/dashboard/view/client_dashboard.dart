import 'dart:async';

import 'package:festeasy_app/features/auth/services/auth_service.dart';
import 'package:festeasy_app/features/event/view/crear_evento_screen.dart';
import 'package:festeasy_app/features/welcome/view/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClientDashboard extends StatefulWidget {
  const ClientDashboard({super.key});

  @override
  State<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard> {
  final AuthService _authService = AuthService();
  String? _userName;
  final TextEditingController _eventDescriptionController =
      TextEditingController();
  final TextEditingController _eventTitleController = TextEditingController();

  late Future<List<Map<String, dynamic>>> _recommendedProviders;
  late Future<List<Map<String, dynamic>>> _recentQuotations;
  late Future<List<Map<String, dynamic>>> _userEvents;

  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_loadUserName());
    _recommendedProviders = _fetchRecommendedProviders();
    _recentQuotations = _fetchRecentQuotations();
    _userEvents = _fetchUserEvents(); // Initialize _userEvents here
  }

  @override
  void dispose() {
    _eventDescriptionController.dispose();
    _eventTitleController.dispose();
    super.dispose();
  }

  Future<void> _loadUserName() async {
    final profileData = await _authService.getProfileData();
    if (profileData != null) {
      setState(() {
        _userName = profileData['full_name'] as String?;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchRecommendedProviders() async {
    try {
      final response = await Supabase.instance.client
          .from('servicios')
          .select('*, proveedores(full_name)')
          .limit(10);
      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      debugPrint('Error fetching recommended providers: $e');
      return [];
    } on Exception catch (e) {
      debugPrint('An unexpected error occurred: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _fetchRecentQuotations() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final response = await Supabase.instance.client
          .from('cotizaciones')
          .select()
          .eq('user_id', userId)
          .limit(5);
      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      debugPrint('Error fetching recent quotations: $e');
      return [];
    } on Exception catch (e) {
      debugPrint('An unexpected error occurred: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _fetchUserEvents() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final response = await Supabase.instance.client
          .from('eventos')
          .select()
          .eq('cliente_id', userId)
          .order('fecha_evento', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      debugPrint('Error fetching user events: $e');
      return [];
    } on Exception catch (e) {
      debugPrint('An unexpected error occurred: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hola, ${_userName ?? ''} 👋'),
        actions: [
          IconButton(
            icon: const CircleAvatar(
              backgroundColor: Colors.red,
              child: Icon(Icons.shopping_cart, color: Colors.white),
            ),
            onPressed: () {
              unawaited(Navigator.pushNamed(context, '/payment'));
            },
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildTabContent(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        onTap: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Mis Eventos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  Widget _buildInicioTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Crea tu evento con IA',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _eventTitleController,
              decoration: const InputDecoration(
                hintText: 'Título del evento',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _eventDescriptionController,
              decoration: const InputDecoration(
                hintText: 'Describe tu evento',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final description = _eventDescriptionController.text.trim();
                if (description.isNotEmpty) {
                  try {
                    final userId =
                        Supabase.instance.client.auth.currentUser!.id;
                    await Supabase.instance.client
                        .from('solicitudes_texto')
                        .insert({
                          'user_id': userId,
                          'texto_original': description,
                          'estado': 'pendiente_ia',
                        });
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Solicitud enviada para análisis'),
                        ),
                      );
                      _eventDescriptionController.clear();
                    }
                  } on PostgrestException catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al enviar solicitud: $e'),
                        ),
                      );
                    }
                  } on Exception catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('An unexpected error occurred: $e'),
                        ),
                      );
                    }
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('La descripción no puede estar vacía'),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Center(
                child: Text(
                  'Generar sugerencias',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Proveedores recomendados',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _recommendedProviders,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('No hay proveedores recomendados'),
                    );
                  }
                  final providers = snapshot.data!;
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: providers.length,
                    itemBuilder: (context, index) {
                      final provider = providers[index];
                      final providerName =
                          (provider['proveedores']
                                  as Map<String, dynamic>?)?['full_name']
                              as String? ??
                          'Proveedor';
                      final serviceName =
                          provider['nombre'] as String? ?? 'Servicio';
                      return Card(
                        margin: const EdgeInsets.only(right: 16),
                        child: SizedBox(
                          width: 150,
                          child: Column(
                            children: [
                              Expanded(
                                child: Image.network(
                                  'https://via.placeholder.com/150', // Placeholder image
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text('$serviceName ($providerName)'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Cotizaciones recientes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _recentQuotations,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('No hay cotizaciones recientes'),
                    );
                  }
                  final quotations = snapshot.data!;
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: quotations.length,
                    itemBuilder: (context, index) {
                      final quotation = quotations[index];
                      return Card(
                        margin: const EdgeInsets.only(right: 16),
                        child: SizedBox(
                          width: 200,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  quotation['titulo'] as String? ??
                                      'Sin título',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  quotation['estado'] as String? ??
                                      'Desconocido',
                                ),
                                const Spacer(),
                                Text(
                                  '\$${(quotation['total_estimado'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMisEventosTab() {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => const CrearEventoScreen(),
            ),
          );
          // Refresh events after returning from CrearEventoScreen
          setState(() {
            _userEvents = _fetchUserEvents();
          });
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _userEvents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tienes eventos creados.'));
          }
          final events = snapshot.data!;
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(
                    event['titulo'] as String? ?? 'Evento sin título',
                  ),
                  subtitle: Text(
                    'Fecha: ${event['fecha_evento']} - Estado: ${event['estado_evento']}',
                  ),
                  // Add more details or navigation to event detail page
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPerfilTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FutureBuilder<Map<String, dynamic>?>(
            future: _authService.getProfileData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              final profile = snapshot.data;
              final fullName = profile?['full_name'] as String? ?? 'Usuario';
              return Text(
                'Hola, $fullName',
                style: Theme.of(context).textTheme.headlineMedium,
              );
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (mounted) {
                await Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute<void>(
                    builder: (context) => const WelcomePage(),
                  ),
                  (route) => false,
                );
              }
            },
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildInicioTab();
      case 1:
        return _buildMisEventosTab();
      case 2:
        return _buildPerfilTab();
      default:
        return _buildInicioTab();
    }
  }
}
