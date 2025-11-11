import 'package:festeasy_app/features/auth/services/auth_service.dart';
import 'package:festeasy_app/features/dashboard/view/client_dashboard.dart';
import 'package:festeasy_app/features/dashboard/view/provider_dashboard.dart';
import 'package:flutter/material.dart';

class RoleSelectionPage extends StatelessWidget {
  RoleSelectionPage({super.key});
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Your Role')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await _authService.createProfile('usuario');
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const ClientDashboard(),
                  ),
                );
              },
              child: const Text('I am a Customer'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _authService.createProfile('proveedor');
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const ProviderDashboard(),
                  ),
                );
              },
              child: const Text('I am a Provider'),
            ),
          ],
        ),
      ),
    );
  }
}
