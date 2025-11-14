import 'dart:async';

import 'package:festeasy_app/features/auth/services/auth_service.dart';
import 'package:festeasy_app/features/event/view/describe_event_page.dart';
import 'package:festeasy_app/features/events/view/events_page.dart';
import 'package:festeasy_app/features/profile/view/profile_page.dart';
import 'package:festeasy_app/features/settings/view/settings_page.dart';
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
  int _selectedTabIndex = 0;
  final TextEditingController _eventDescriptionController =
      TextEditingController();
  final TextEditingController _eventTitleController = TextEditingController();

  late Future<List<Map<String, dynamic>>> _recommendedProviders;
  late Future<List<Map<String, dynamic>>> _recentQuotations;

  @override
  void initState() {
    super.initState();
    unawaited(_loadUserName());
    _recommendedProviders = _fetchRecommendedProviders();
    _recentQuotations = _fetchRecentQuotations();
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  Widget _buildHomeTabContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          onSubmitted: (value) {
            unawaited(Navigator.pushNamed(context, '/services'));
          },
          decoration: const InputDecoration(
            hintText: 'Buscar servicios para mi evento',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            unawaited(
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const DescribeEventPage(),
                ),
              ),
            );
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
              'Crear Evento',
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
                      (provider['proveedores'] as Map<String, dynamic>?)?['full_name']
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
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildHomeTabContent();
      case 1:
        return const EventsPage();
      case 2:
        return const ProfilePage();
      case 3:
        return const SettingsPage();
      default:
        return _buildHomeTabContent();
    }
  }

  Text _getAppBarTitle() {
    switch (_selectedTabIndex) {
      case 0:
        return Text('Hola, ${_userName ?? ''} 👋');
      case 1:
        return const Text('Mis Eventos');
      case 2:
        return const Text('Perfil');
      case 3:
        return const Text('Ajustes');
      default:
        return Text('Hola, ${_userName ?? ''} 👋');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _getAppBarTitle(),
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
        onTap: _onItemTapped,
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
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFEA4D4D),
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
