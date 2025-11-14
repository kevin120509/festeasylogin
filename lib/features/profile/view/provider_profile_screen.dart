import 'dart:async';
import 'dart:io';

import 'package:festeasy_app/features/profile/view/manage_service_screen.dart';
import 'package:festeasy_app/features/welcome/view/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({super.key});

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  final _nombreController = TextEditingController();
  final _descController = TextEditingController();
  String? _fotoUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadProfileData());
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final response = await Supabase.instance.client
          .from('proveedores')
          .select('full_name, foto_url')
          .eq('user_id', userId)
          .single();

      _nombreController.text = response['full_name'] as String? ?? '';
      _fotoUrl = response['foto_url'] as String?;
    } on PostgrestException catch (e) {
      debugPrint('Error loading profile data: ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar perfil: ${e.message}')),
        );
      }
    } on Exception catch (e) {
      debugPrint('Unexpected error loading profile data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error inesperado al cargar perfil: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      await Supabase.instance.client.from('proveedores').update({
        'full_name': _nombreController.text.trim(),
      }).eq('user_id', userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado correctamente')),
        );
      }
    } on PostgrestException catch (e) {
      debugPrint('Error updating profile: ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar perfil: ${e.message}')),
        );
      }
    } on Exception catch (e) {
      debugPrint('Unexpected error updating profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error inesperado al actualizar perfil: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final imageFile = File(image.path);
      final path = '$userId/foto-perfil.png';

      // Upload image to Supabase Storage
      await Supabase.instance.client.storage.from('fotos-perfil').upload(
            path,
            imageFile,
            fileOptions: const FileOptions(upsert: true),
          );

      // Get public URL
      final publicUrl = Supabase.instance.client.storage
          .from('fotos-perfil')
          .getPublicUrl(path);

      // Save URL to database
      await Supabase.instance.client.from('proveedores').update({
        'foto_url': publicUrl,
      }).eq('user_id', userId);

      setState(() {
        _fotoUrl = publicUrl;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto de perfil actualizada')),
        );
      }
    } on StorageException catch (e) {
      debugPrint('Error uploading image: ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir imagen: ${e.message}')),
        );
      }
    } on PostgrestException catch (e) {
      debugPrint('Error saving image URL to profile: ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar URL de imagen: ${e.message}'),
          ),
        );
      }
    } on Exception catch (e) {
      debugPrint('Unexpected error during image upload/save: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error inesperado: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser!.id;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Perfil'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sección 1: Foto de Perfil

                  const SizedBox(height: 24),

                  // Sección 1: Foto de Perfil
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage:
                              _fotoUrl != null ? NetworkImage(_fotoUrl!) : null,
                          child: _fotoUrl == null
                              ? const Icon(Icons.person, size: 60)
                              : null,
                        ),
                        TextButton(
                          onPressed: _pickAndUploadImage,
                          child: const Text('Cambiar Foto'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sección 2: Información del Perfil
                  Text(
                    'Información del Perfil',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre Público',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Change to red
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Guardar Perfil'),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Sección 3: Mis Servicios (CRUD de Servicios)
                  Text(
                    'Mis Servicios',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: Supabase.instance.client
                        .from('servicios')
                        .stream(primaryKey: ['servicio_id'])
                        .eq('proveedor_id', currentUserId)
                        .order('nombre', ascending: true),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      final services = snapshot.data ?? [];
                      if (services.isEmpty) {
                        return const Center(
                          child: Text('No tienes servicios registrados.'),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: services.length,
                        itemBuilder: (context, index) {
                          final service = services[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(service['nombre'] as String? ?? ''),
                              subtitle: Text(
                                '\$${(service['precio_base'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () async {
                                      if (!mounted) return;
                                      await Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (context) =>
                                              ManageServiceScreen(
                                            initialService: service,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      await Supabase.instance.client
                                          .from('servicios')
                                          .delete()
                                          .eq('servicio_id', service['servicio_id'] as Object);
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Servicio eliminado'),
                                          ),
                                        );
                                      }
                                      // Refresh the list after deletion
                                      setState(() {});
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  // Botón de Cerrar Sesión
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          await Supabase.instance.client.auth.signOut();
                        } on AuthException catch (_) {}
                        if (!mounted) return;
                        await Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute<void>(
                            builder: (_) => const WelcomePage(),
                          ),
                          (route) => false,
                        );
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
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (!mounted) return;
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => const ManageServiceScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFFEA4D4D),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
