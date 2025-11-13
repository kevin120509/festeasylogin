import 'package:flutter/material.dart';

// --- Data Model ---
// NOTE: This is a more detailed model based on your request.
// In a real app, you should move this to its own file (e.g., 'models/proveedor.dart')
// and update how you create this object in the previous screen.
class Proveedor {
  const Proveedor({
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.services,
    required this.contact,
    this.galleryImages = const [],
  });

  final String name;
  final String imageUrl;
  final String description;
  final List<String> services;
  final Map<String, String> contact;
  final List<String> galleryImages;
}

// --- Detail Screen ---
class ProviderDetailScreen extends StatelessWidget {
  const ProviderDetailScreen({
    required this.proveedor,
    super.key,
  });

  final Proveedor proveedor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(proveedor.name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Main Image
            Image.network(
              proveedor.imageUrl,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
              // Basic error handling for the image
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 250,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // 2. Main content section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Provider Name
                  Text(
                    proveedor.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    proveedor.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),

                  // "Servicios Ofrecidos" Section
                  _buildSectionTitle(context, 'Servicios Ofrecidos'),
                  const SizedBox(height: 8),
                  ...proveedor.services.map(
                    (service) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.check, color: Colors.red),
                      title: Text(service),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // "Galería de Imágenes" Section
                  if (proveedor.galleryImages.isNotEmpty) ...[
                    _buildSectionTitle(context, 'Galería de Imágenes'),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: proveedor.galleryImages.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                proveedor.galleryImages[index],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // "Información de Contacto" Section
                  _buildSectionTitle(context, 'Información de Contacto'),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.phone, color: Colors.red),
                    title: Text(proveedor.contact['phone'] ?? 'No disponible'),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.email, color: Colors.red),
                    title: Text(proveedor.contact['email'] ?? 'No disponible'),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.public, color: Colors.red),
                    title: Text(
                      proveedor.contact['website'] ?? 'No disponible',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
      // 3. Bottom Action Button
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            // TODO(developer): Implement contact or quotation logic
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Pedir Cotización',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }

  // Helper widget for section titles
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
