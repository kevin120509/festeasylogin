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
  final _precioUnidadController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _categories = [];
  List<int> _selectedCategoryIds = [];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    if (widget.initialService != null) {
      _nombreController.text = widget.initialService!['nombre'] as String? ?? '';
      _descripcionController.text =
          widget.initialService!['descripcion'] as String? ?? '';
      _precioBaseController.text =
          (widget.initialService!['precio_base'] as num?)?.toString() ?? '';
      _precioUnidadController.text =
          widget.initialService!['precio_unidad'] as String? ?? '';
      _fetchSelectedCategories(widget.initialService!['servicio_id'] as int);
    }
  }

  Future<void> _fetchSelectedCategories(int serviceId) async {
    try {
      final response = await Supabase.instance.client
          .from('servicio_categorias')
          .select('categoria_id')
          .eq('servicio_id', serviceId);
      setState(() {
        _selectedCategoryIds = (response as List<dynamic>)
            .map((e) => e['categoria_id'] as int)
            .toList();
      });
    } on PostgrestException catch (e) {
      debugPrint('Error fetching selected categories: ${e.message}');
    }
  }

  Future<void> _showCategoryMultiSelect(FormFieldState<List<int>> state) async {
    final selectedIds = List<int>.from(_selectedCategoryIds);
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Seleccionar Categorías'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _categories.map((category) {
                    final isSelected =
                        selectedIds.contains(category['categoria_id'] as int);
                    return CheckboxListTile(
                      title: Text(category['nombre'] as String),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedIds.add(category['categoria_id'] as int);
                          } else {
                            selectedIds.remove(category['categoria_id'] as int);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                state.didChange(selectedIds);
                setState(() {
                  _selectedCategoryIds = selectedIds;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await Supabase.instance.client
          .from('categorias_servicio')
          .select('categoria_id, nombre');
      debugPrint('Categories response: $response');
      setState(() {
        _categories = List<Map<String, dynamic>>.from(response as List);
        _isLoadingCategories = false;
      });
    } on PostgrestException catch (e) {
      debugPrint('Error fetching categories: ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar categorías: ${e.message}')),
        );
      }
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioBaseController.dispose();
    _precioUnidadController.dispose();
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
        'precio_unidad': _precioUnidadController.text.trim(),
        'proveedor_id': userId,
      };

      if (widget.initialService == null) {
        // Create new service
        final newService = await Supabase.instance.client
            .from('servicios')
            .insert(serviceData)
            .select()
            .single();
        final newServiceId = newService['servicio_id'] as int;

        final serviceCategories = _selectedCategoryIds
            .map((categoryId) => {
                  'servicio_id': newServiceId,
                  'categoria_id': categoryId,
                })
            .toList();

        await Supabase.instance.client
            .from('servicio_categorias')
            .insert(serviceCategories);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Servicio añadido correctamente')),
          );
        }
      } else {
        // Update existing service
        final serviceId = widget.initialService!['servicio_id'] as int;
        await Supabase.instance.client
            .from('servicios')
            .update(serviceData)
            .eq('servicio_id', serviceId);

        // Delete old categories and insert new ones
        await Supabase.instance.client
            .from('servicio_categorias')
            .delete()
            .eq('servicio_id', serviceId);

        final serviceCategories = _selectedCategoryIds
            .map((categoryId) => {
                  'servicio_id': serviceId,
                  'categoria_id': categoryId,
                })
            .toList();

        if (serviceCategories.isNotEmpty) {
          await Supabase.instance.client
              .from('servicio_categorias')
              .insert(serviceCategories);
        }

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
              _isLoadingCategories
                  ? const Center(child: CircularProgressIndicator())
                  : FormField<List<int>>(
                      initialValue: _selectedCategoryIds,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, selecciona al menos una categoría';
                        }
                        return null;
                      },
                      builder: (FormFieldState<List<int>> state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            OutlinedButton(
                              onPressed: () => _showCategoryMultiSelect(state),
                              child: const Text('Seleccionar Categorías'),
                            ),
                            if (_selectedCategoryIds.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: _selectedCategoryIds.map((id) {
                                    final category = _categories.firstWhere(
                                        (cat) => cat['categoria_id'] == id);
                                    return Chip(
                                      label: Text(category['nombre'] as String),
                                    );
                                  }).toList(),
                                ),
                              ),
                            if (state.hasError)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  state.errorText!,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        );
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _precioUnidadController,
                decoration: const InputDecoration(
                  labelText: 'Unidad de Precio (e.g., por hora, por persona)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce la unidad de precio';
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
