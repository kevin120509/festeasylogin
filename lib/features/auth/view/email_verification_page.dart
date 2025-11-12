import 'package:festeasy_app/features/auth/services/auth_service.dart';
import 'package:festeasy_app/features/dashboard/view/client_dashboard.dart';
import 'package:festeasy_app/features/dashboard/view/provider_dashboard.dart';
import 'package:festeasy_app/features/welcome/view/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final AuthService _authService = AuthService();
  bool _isResending = false;
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isResending = true;
    });
    try {
      await _authService.sendEmailVerification();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Correo de verificación reenviado. Revisa tu bandeja de entrada.',
          ),
        ),
      );
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al reenviar el correo: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  Future<void> _checkEmailVerification() async {
    // Reload user session to get updated email_confirmed_at status
    await _authService.reloadUser();
    if (!mounted) return; // Added this check
    if (_authService.isEmailVerified()) {
      // Navigate to appropriate dashboard based on user role
      final profileData = await _authService.getProfileData();
      if (!mounted) return; // Added this check
      if (profileData != null) {
        final rol = profileData['rol'];
        if (rol == 'cliente' || rol == 'usuario') {
          await Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (context) => const ClientDashboard(),
            ),
          );
        } else if (rol == 'proveedor') {
          await Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (context) => const ProviderDashboard(),
            ),
          );
        }
      } else {
        // If profile data is null, something went wrong or user is not fully registered
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (context) => const WelcomePage()),
        );
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tu correo aún no ha sido verificado.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifica tu correo'),
        automaticallyImplyLeading: false, // Prevent back button
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.email_outlined,
                size: 100,
                color: Colors.red,
              ),
              const SizedBox(height: 20),
              const Text(
                'Se ha enviado un correo de verificación a tu dirección de correo electrónico. Por favor, verifica tu bandeja de entrada (y la carpeta de spam) para activar tu cuenta.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isResending ? null : _resendVerificationEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isResending
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Reenviar correo de verificación'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: _checkEmailVerification,
                child: const Text(
                  'Ya verifiqué mi correo',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () async {
                  await _supabase.auth.signOut();
                  if (!mounted) return;
                  await Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute<void>(
                      builder: (context) => const WelcomePage(),
                    ),
                    (Route<dynamic> route) => false,
                  );
                },
                child: const Text(
                  'Cerrar sesión',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
