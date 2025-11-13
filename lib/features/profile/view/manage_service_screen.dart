import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManageServiceScreen extends StatefulWidget {
  const ManageServiceScreen({this.initialService, super.key});

  final Map<String, dynamic>? initialService;

  @override
  State<ManageServiceScreen> createState() => _ManageServiceScreenState();
}

class _ManageServiceScreenState extends State<ManageServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioBaseController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialService != null) {
      _nombreController.text = widget.initialService!['nombre'] as String? ?? '';
      _descripcionController.text =
          widget.initialService!['descripcion'] as String? ?? '';
      _precioBaseController.text =
          (widget.initialService!['precio_base'] as num?)?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioBaseController.dispose();
    super.dispose();
  }

  Future<void> _saveService() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final serviceData = <String, dynamic>{
        'nombre': _nombreController.text.trim(),
        'descripcion': _descripcionController.text.trim(),
        'precio_base': double.parse(_precioBaseController.text.trim()),
        'proveedor_id': userId,
        'categoria_id': 1, // Placeholder: Assuming a default category for now
      };

      if (widget.initialService == null) {
        // Create new service
        await Supabase.instance.client.from('servicios').insert(serviceData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Servicio añadido correctamente')),
          );
        }
      } else {
        // Update existing service
        await Supabase.instance.client
            .from('servicios')
            .update(serviceData)
            .eq('servicio_id', widget.initialService!['servicio_id'] as Object);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Servicio actualizado correctamente')),
          );
        }
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on PostgrestException catch (e) {
      debugPrint('Error saving service: ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar servicio: ${e.message}')),
        );
      }
    } on Exception catch (e) {
      debugPrint('Unexpected error saving service: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error inesperado al guardar servicio: $e')),
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
    final isEditing = widget.initialService != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Servicio' : 'Añadir Servicio'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Servicio',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce el nombre del servicio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce una descripción';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _precioBaseController,
                decoration: const InputDecoration(
                  labelText: 'Precio Base',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce el precio base';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Por favor, introduce un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveService,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(isEditing ? 'Guardar Cambios' : 'Añadir Servicio'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
