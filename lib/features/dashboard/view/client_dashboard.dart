import 'dart:async';

import 'package:festeasy_app/features/auth/services/auth_service.dart';
import 'package:festeasy_app/features/dashboard/view/provider_detail_screen.dart';
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
    // Dummy data for recommended providers to match the new Proveedor model
    final listaProveedores = [
      Proveedor(
        name: 'Alimentos y Catering',
        imageUrl: 'https://picsum.photos/seed/food/300/200',
        description:
            'Ofrecemos los mejores platillos para tu evento. Menús personalizados y servicio de catering completo.',
       services: ['Buffet', 'Taquizas', 'Box Lunch', 'Barra de bebidas'],
        contact: {
          'phone': '55-1234-5678',
          'email': 'contacto@cateringdelicioso.com',
          'website': 'cateringdelicioso.com',
        },
        galleryImages: [
          'https://picsum.photos/seed/food_gallery1/300/200',
          'https://picsum.photos/seed/food_gallery2/300/200',
          'https://picsum.photos/seed/food_gallery3/300/200',
        ],
      ),
      Proveedor(
        name: 'Decoración de Eventos',
        imageUrl: 'https://picsum.photos/seed/decor/300/200',
        description:
            'Transformamos cualquier espacio en el escenario de tus sueños. Decoración floral, globos, y más.',
        services: [
          'Arreglos florales',
          'Decoración con globos',
          'Centros de mesa'
        ],
        contact: {
          'phone': '55-8765-4321',
          'email': 'info@decorarte.com',
          'website': 'decorarte.com',
        },
        galleryImages: [
          'https://picsum.photos/seed/decor_gallery1/300/200',
          'https://picsum.photos/seed/decor_gallery2/300/200',
        ],
      ),
      Proveedor(
        name: 'Fotografía y Evento',
        imageUrl: 'https://picsum.photos/seed/photo/300/200',
        description:
            'Capturamos los momentos más especiales de tu vida. Cobertura completa de tu evento.',
        services: ['Sesión de fotos', 'Video filmación', 'Photobooth'],
        contact: {
          'phone': '55-5555-5555',
          'email': 'captura@momentos.com',
          'website': 'momentosunicos.com',
        },
        galleryImages: [],
      ),
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
                  itemCount: listaProveedores.length,
                  itemBuilder: (context, index) {
                    final proveedor = listaProveedores[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProviderDetailScreen(proveedor: proveedor),
                          ),
                        );
                      },
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        margin: const EdgeInsets.only(right: 16),
                        child: SizedBox(
                          width: 150,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Image.network(
                                  proveedor.imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Center(
                                    child: Icon(Icons.broken_image),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  proveedor.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
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
