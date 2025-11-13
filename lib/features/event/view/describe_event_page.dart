import 'dart:async';

import 'package:festeasy_app/core/local_storage.dart' as app_local_storage;
import 'package:festeasy_app/features/auth/services/auth_service.dart';
import 'package:flutter/material.dart';

class DescribeEventPage extends StatefulWidget {
  const DescribeEventPage({super.key});

  @override
  State<DescribeEventPage> createState() => _DescribeEventPageState();
}

class _DescribeEventPageState extends State<DescribeEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _eventNameController = TextEditingController();
  final _eventDescriptionController = TextEditingController();
  final _totalPeopleController = TextEditingController();
  final _locationController = TextEditingController();

  final _serviceNameController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();

  final List<Map<String, String>> _services = [];
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _eventNameController.dispose();
    _eventDescriptionController.dispose();
    _totalPeopleController.dispose();
    _locationController.dispose();
    _serviceNameController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  void _addService() {
    if (_serviceNameController.text.isNotEmpty &&
        _startTimeController.text.isNotEmpty &&
        _endTimeController.text.isNotEmpty) {
      setState(() {
        _services.add({
          'name': _serviceNameController.text,
          'start_time': _startTimeController.text,
          'end_time': _endTimeController.text,
        });
        _serviceNameController.clear();
        _startTimeController.clear();
        _endTimeController.clear();
      });
      Navigator.of(context).pop();
    }
  }

  void _showAddServiceDialog() {
    unawaited(showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agregar Servicio'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _serviceNameController,
                decoration:
                    const InputDecoration(labelText: 'Nombre del Servicio'),
              ),
              TextField(
                controller: _startTimeController,
                decoration: const InputDecoration(labelText: 'Hora de Inicio'),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    if (!mounted) return;
                    _startTimeController.text = time.format(context);
                  }
                },
              ),
              TextField(
                controller: _endTimeController,
                decoration: const InputDecoration(labelText: 'Hora de Fin'),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    if (!mounted) return;
                    _endTimeController.text = time.format(context);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: _addService,
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    ));
  }

  Future<void> _generateEvent() async {
    if (_formKey.currentState!.validate()) {
      final profileData = await _authService.getProfileData();
      final description = '''
Descripción: ${_eventDescriptionController.text}
Total de personas: ${_totalPeopleController.text}
Lugar: ${_locationController.text}
Email: ${profileData?['email']}
Usuario: ${profileData?['full_name']}
Servicios:
${_services.map((s) => '- ${s['name']} de ${s['start_time']} a ${s['end_time']}').join('\n')}
''';

      final eventData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': _eventNameController.text,
        'description': description,
        'status': 'pending',
      };

      await app_local_storage.LocalStorage.addRequest(eventData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Su solicitud se envió')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Describir Evento'),
        actions: [
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _generateEvent,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _eventNameController,
                decoration:
                    const InputDecoration(labelText: 'Nombre del Evento'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el nombre del evento';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _eventDescriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese la descripción del evento';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _totalPeopleController,
                decoration:
                    const InputDecoration(labelText: 'Total de Personas'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el total de personas';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Lugar'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el lugar del evento';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _showAddServiceDialog,
                child: const Text('Agregar Servicio'),
              ),
              const SizedBox(height: 20),
              const Text(
                'Servicios Agregados:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ..._services.map((service) {
                return ListTile(
                  title: Text(service['name']!),
                  subtitle: Text(
                    'De ${service['start_time']} a ${service['end_time']}',
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
