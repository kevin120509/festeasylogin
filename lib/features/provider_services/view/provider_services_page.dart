import 'package:flutter/material.dart';

class ProviderServicesPage extends StatelessWidget {
  const ProviderServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Servicios del Proveedor'),
      ),
      body: const Center(
        child: Text('Aquí se mostrarán los servicios del proveedor.'),
      ),
    );
  }
}
