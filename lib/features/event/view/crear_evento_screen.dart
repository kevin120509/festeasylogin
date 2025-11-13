import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CrearEventoScreen extends StatefulWidget {
  const CrearEventoScreen({super.key});

  @override
  State<CrearEventoScreen> createState() => _CrearEventoScreenState();
}

class _CrearEventoScreenState extends State<CrearEventoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _direccionController = TextEditingController();
  DateTime? _fechaEvento;
  TimeOfDay? _horaInicio;
  TimeOfDay? _horaFin;

  @override
  void dispose() {
    _tituloController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (pickedDate != null) {
      setState(() {
        _fechaEvento = pickedDate;
      });
    }
  }

  Future<void> _pickTime(bool isStartTime) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          _horaInicio = pickedTime;
        } else {
          _horaFin = pickedTime;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_fechaEvento == null || _horaInicio == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, selecciona fecha y hora de inicio'),
          ),
        );
        return;
      }

      final userId = Supabase.instance.client.auth.currentUser!.id;
      final eventData = {
        'cliente_id': userId,
        'titulo': _tituloController.text,
        'fecha_evento': _fechaEvento!.toIso8601String().split('T')[0],
        'hora_inicio':
            '${_horaInicio!.hour.toString().padLeft(2, '0')}:${_horaInicio!.minute.toString().padLeft(2, '0')}:00',
        'hora_fin': _horaFin != null
            ? '${_horaFin!.hour.toString().padLeft(2, '0')}:${_horaFin!.minute.toString().padLeft(2, '0')}:00'
            : null,
        'direccion_texto': _direccionController.text,
        'estado_evento': 'borrador', // O el estado inicial que desees
      };

      try {
        await Supabase.instance.client.from('eventos').insert(eventData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Evento creado exitosamente')),
          );
          Navigator.of(context).pop(); // Go back to previous screen
        }
      } on PostgrestException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al crear evento: ${e.message}')),
          );
        }
      } on Exception catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('An unexpected error occurred: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nuevo Evento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título del Evento',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un título';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(
                  labelText: 'Dirección del Evento',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una dirección';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  _fechaEvento == null
                      ? 'Seleccionar Fecha'
                      : 'Fecha: ${_fechaEvento!.day}/${_fechaEvento!.month}/'
                            '${_fechaEvento!.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              ListTile(
                title: Text(
                  _horaInicio == null
                      ? 'Seleccionar Hora de Inicio'
                      : 'Hora de Inicio: ${_horaInicio!.format(context)}',
                ),
                trailing: const Icon(Icons.access_time),
                onTap: () => _pickTime(true),
              ),
              ListTile(
                title: Text(
                  _horaFin == null
                      ? 'Seleccionar Hora de Fin (Opcional)'
                      : 'Hora de Fin: ${_horaFin!.format(context)}',
                ),
                trailing: const Icon(Icons.access_time),
                onTap: () => _pickTime(false),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Crear Evento'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
