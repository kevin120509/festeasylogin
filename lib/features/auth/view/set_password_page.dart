import 'package:flutter/material.dart';
import 'package:festeasy_app/features/auth/services/auth_service.dart';

class SetPasswordPage extends StatefulWidget {
  const SetPasswordPage({super.key});

  @override
  State<SetPasswordPage> createState() => _SetPasswordPageState();
}

class _SetPasswordPageState extends State<SetPasswordPage> {
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _setPassword() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.setUserPassword(_passwordController.text);
      // Navigate to the appropriate dashboard after setting the password
      final profileData = await _authService.getProfileData();
      if (profileData != null) {
        final rol = profileData['rol'];
        if (rol == 'proveedor') {
          Navigator.of(context).pushReplacementNamed('/provider_dashboard');
        } else if (rol == 'usuario') {
          Navigator.of(context).pushReplacementNamed('/client_dashboard');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Your Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _setPassword,
                    child: const Text('Set Password'),
                  ),
          ],
        ),
      ),
    );
  }
}
