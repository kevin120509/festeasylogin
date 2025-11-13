import 'dart:async';

import 'package:festeasy_app/core/local_storage.dart' as app_local_storage;
import 'package:festeasy_app/features/dashboard/home_screen.dart';
import 'package:festeasy_app/features/dashboard/view/provider_request_review.dart';
import 'package:festeasy_app/features/welcome/view/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProviderDashboard extends StatefulWidget {
  const ProviderDashboard({super.key});

  @override
  State<ProviderDashboard> createState() => _ProviderDashboardState();
}

class _ProviderDashboardState extends State<ProviderDashboard> {
  String _selectedCategory = 'Todos';
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: _selectedTabIndex == 0
            ? const Text('Solicitudes Recientes')
            : _selectedTabIndex == 1
            ? const Text('Mis Eventos')
            : _selectedTabIndex == 2
            ? const Text('Perfil')
            : const Text('Ajustes'),
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

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildInitioTab();
      case 1:
        return _buildEventosTab();
      case 2:
        return _buildPerfilTab();
      case 3:
        return _buildAjustesTab();
      default:
        return _buildInitioTab();
    }
  }

  Widget _buildInitioTab() {
    return ColoredBox(
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Todos'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Bodas'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Cumpleaños'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Empresariales'),
                ],
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: app_local_storage.LocalStorage.getRequests(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final all = snapshot.data ?? [];
                final pending = all
                    .where((e) => (e['status']?.toString() ?? '') == 'pending')
                    .toList();
                if (pending.isEmpty) {
                  return const Center(
                    child: Text('No hay solicitudes pendientes'),
                  );
                }
                return ListView.builder(
                  itemCount: pending.length,
                  itemBuilder: (context, index) {
                    final req = pending[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              req['title']?.toString() ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFFEA4D4D),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(req['description']?.toString() ?? ''),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final res = await Navigator.of(context)
                                      .push<bool?>(
                                        MaterialPageRoute(
                                          builder: (_) => ProviderRequestReview(
                                            request: req,
                                          ),
                                        ),
                                      );
                                  if (res ?? false) setState(() {});
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFEA4D4D),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Revisar',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
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
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedCategory == label;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = label;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: isSelected
          ? const Color(0xFFEA4D4D)
          : const Color(0xFFFFD700),
      side: BorderSide(
        color: isSelected ? const Color(0xFFEA4D4D) : const Color(0xFFFFD700),
        width: 2,
      ),
    );
  }

  Widget _buildEventosTab() {
    return const HomeScreen();
  }

  Widget _buildPerfilTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Perfil del Proveedor'),
            const SizedBox(height: 8),
            Text(
              'Aquí irá la información de tu perfil',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                // Cerrar sesión y volver a WelcomePage
                try {
                  await Supabase.instance.client.auth.signOut();
                } on AuthException {
                  // Ignore
                }
                if (!mounted) return;
                unawaited(Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute<void>(builder: (_) => const WelcomePage()),
                  (route) => false,
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEA4D4D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 24,
                ),
              ),
              child: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAjustesTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.settings, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Ajustes'),
          const SizedBox(height: 8),
          Text(
            'Aquí irán tus configuraciones',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
