import 'dart:async';

import 'package:festeasy_app/features/auth/services/auth_service.dart';
import 'package:flutter/material.dart';

class ClientDashboard extends StatefulWidget {
  const ClientDashboard({super.key});

  @override
  State<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard> {
  final AuthService _authService = AuthService();
  String? _userName;

  @override
  void initState() {
    super.initState();
    unawaited(_loadUserName());
  }

  Future<void> _loadUserName() async {
    final profileData = await _authService.getProfileData();
    if (profileData != null) {
      setState(() {
        _userName = profileData['full_name'] as String?;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Hola, ${_userName ?? ''} 👋'),
        actions: [
          IconButton(
            icon: const CircleAvatar(
              backgroundColor: Colors.red,
              child: Icon(Icons.shopping_cart, color: Colors.white),
            ),
            onPressed: () async {
              await Navigator.pushNamed(context, '/payment');
            },
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TextField(
                decoration: InputDecoration(
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
              const TextField(
                decoration: InputDecoration(
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
                onPressed: () {},
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                quotation['title']!,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(quotation['provider']!),
                              const Spacer(),
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
          ),
        ),
      ),
    );
  }
}
