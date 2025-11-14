import 'dart:async';

import 'package:festeasy_app/features/auth/services/auth_service.dart';
import 'package:festeasy_app/features/event/view/describe_event_page.dart';
import 'package:festeasy_app/features/events/view/events_page.dart';
import 'package:festeasy_app/features/profile/view/profile_page.dart';
import 'package:festeasy_app/features/settings/view/settings_page.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    unawaited(_loadUserName());
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  Widget _buildHomeTabContent() {
    final providerImages = [
      'assets/proveedores/alimentos y catering.png',
      'assets/proveedores/decoracion de eventos.png',
      'assets/proveedores/fotografia y evento.png',
      'assets/proveedores/musicaDJ.png',
      'assets/proveedores/show.png',
    ];

    final recentQuotations = [
      {
        'title': 'Boda de Ensueño',
        'provider': 'Eventos Premier',
        'price': r'$5,000',
      },
      {
        'title': 'Fiesta de 15 Años',
        'provider': 'Decoraciones Mágicas',
        'price': r'$2,500',
      },
      {
        'title': 'Conferencia Corporativa',
        'provider': 'Catering Express',
        'price': r'$3,000',
      },
    ];

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
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: providerImages.length,
            itemBuilder: (context, index) {
              final imagePath = providerImages[index];
              final title = imagePath.split('/').last.split('.').first;
              return Card(
                margin: const EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 150,
                  child: Column(
                    children: [
                      Expanded(
                        child: Image.asset(
                          imagePath,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(title),
                      ),
                    ],
                  ),
                ),
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
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recentQuotations.length,
            itemBuilder: (context, index) {
              final quotation = recentQuotations[index];
              return Card(
                margin: const EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 200,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quotation['title']!,
                          style: Theme.of(context).textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          quotation['provider']!,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          quotation['price']!,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                ),
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
      backgroundColor: Colors.grey[100],
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
