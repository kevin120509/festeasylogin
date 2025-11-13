import 'package:festeasy_app/core/local_storage.dart' as app_local_storage;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  Future<void> _acceptRequest() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecciona una fecha')));
      return;
    }
    setState(() => _isSaving = true);
    final reservation = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'requestId': widget.request['id'].toString(),
      'title': widget.request['title'].toString(),
      'description': widget.request['description'].toString(),
      'providerDescription': _providerDescController.text.trim(),
      'date': _selectedDate!.toIso8601String(),
      'createdAt': DateTime.now().toIso8601String(),
    };
    try {
      await app_local_storage.LocalStorage.addReservation(reservation);
      await app_local_storage.LocalStorage.updateRequestStatus(
        widget.request['id'].toString(),
        'accepted',
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Reserva aceptada')));
        Navigator.of(context).pop(true);
      }
    } on Exception {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error guardando reserva')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
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
              request['title']?.toString() ?? '',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(request['description']?.toString() ?? ''),
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
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _acceptRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEA4D4D),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Aceptar y reservar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
