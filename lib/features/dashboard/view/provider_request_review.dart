import 'dart:convert';
import 'dart:io';

import 'package:festeasy_app/core/local_storage.dart' as app_local_storage;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProviderRequestReview extends StatefulWidget {
  const ProviderRequestReview({required this.request, super.key});

  final Map<String, dynamic> request;

  @override
  State<ProviderRequestReview> createState() => _ProviderRequestReviewState();
}

class _ProviderRequestReviewState extends State<ProviderRequestReview> {
  final TextEditingController _providerDescController = TextEditingController();
  DateTime? _selectedDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    debugPrint('ProviderRequestReview: initState - request: ${widget.request}');
  }

  @override
  void dispose() {
    _providerDescController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _showFakeJson() async {
    final fakeEventData = {
      'evento_id': 12345,
      'cliente_id': 'a1b2c3d4-e5f6-7890-1234-567890abcdef',
      'titulo': 'Fiesta de Cumpleaños Sorpresa',
      'fecha_evento': '2024-12-25',
      'hora_inicio': '20:00:00',
      'hora_fin': '02:00:00',
      'direccion_texto': 'Calle Falsa 123, Colonia Inventada, Ciudad Ejemplo',
      'estado_evento': 'confirmado',
      'servicios_sugeridos': [
        {
          'sugerencia_id': 1,
          'nombre_sugerido': 'DJ para Fiesta',
          'tipo': 'Musica',
          'confianza': 0.95,
        },
        {
          'sugerencia_id': 2,
          'nombre_sugerido': 'Servicio de Catering (Bocadillos)',
          'tipo': 'Comida',
          'confianza': 0.88,
        },
        {
          'sugerencia_id': 3,
          'nombre_sugerido': 'Show de Magia',
          'tipo': 'Shows',
          'confianza': 0.75,
        }
      ]
    };

    const encoder = JsonEncoder.withIndent('  ');
    final prettyJson = encoder.convert(fakeEventData);

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Información Falsa del Evento (JSON)'),
          content: SingleChildScrollView(
            child: Text(prettyJson),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleAcceptRequest() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecciona una fecha')));
      return;
    }
    setState(() => _isSaving = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;

      // 1. Create a new cotizacion entry
      final cotizacionResponse = await Supabase.instance.client
          .from('cotizaciones')
          .insert({
            'user_id': userId,
            'solicitud_id': widget.request['solicitud_id'],
            'titulo': widget.request['texto_original'],
            'descripcion': _providerDescController.text.trim(),
            'estado': 'enviada',
            'validez_dias': 7, // Default validity
          })
          .select()
          .single();

      final cotizacionId = cotizacionResponse['cotizacion_id'] as int;

      // 2. Create a cotizacion_item entry (example, adjust as needed)
      await Supabase.instance.client.from('cotizacion_items').insert({
        'cotizacion_id': cotizacionId,
        // Assuming a default service or category for now,
        // this would need to be dynamic based on the request or provider input
        'servicio_id': 1, // Placeholder: Replace with actual service_id
        'proveedor_id': userId,
        'cantidad': 1,
        'precio_unitario': 0.0, // Placeholder: Replace with actual price
        'notas': 'Propuesta para solicitud: ${widget.request['solicitud_id']}',
      });

      // 3. Update the solicitud_texto status
      await Supabase.instance.client
          .from('solicitudes_texto')
          .update({'estado': 'cotizado'})
          .eq('solicitud_id', widget.request['solicitud_id'] as int);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text('Cotización enviada y solicitud actualizada'),
          ),
        );
        Navigator.of(context).pop(true); // Indicate acceptance
      }
    } on PostgrestException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de base de datos: ${e.message}')),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error guardando cotización: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _handleRejectRequest() async {
    setState(() => _isSaving = true);
    try {
      await Supabase.instance.client
          .from('solicitudes_texto')
          .update({'estado': 'rechazado'})
          .eq('solicitud_id', widget.request['solicitud_id'] as int);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text('Solicitud rechazada'),
          ),
        );
        Navigator.of(context).pop(false); // Indicate rejection
      }
    } on PostgrestException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de base de datos: ${e.message}')),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al rechazar solicitud: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('ProviderRequestReview: build method started.');
    final request = widget.request;
    debugPrint('ProviderRequestReview: request in build: $request');
    debugPrint('ProviderRequestReview: texto_original: ${request['texto_original']}');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Revisar solicitud'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              request['texto_original']?.toString() ?? '',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(request['texto_original'] as String? ?? ''),
            const SizedBox(height: 16),
            TextField(
              controller: _providerDescController,
              decoration: const InputDecoration(
                labelText: 'Descripción del proveedor',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _pickDate,
                  child: const Text('Elegir fecha'),
                ),
                const SizedBox(width: 12),
                if (_selectedDate != null)
                  Text(DateFormat.yMMMMd().format(_selectedDate!)),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _showFakeJson,
                child: const Text('Ver JSON Falso'),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _handleRejectRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Rechazar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _handleAcceptRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Aceptar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
