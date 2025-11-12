import 'dart:async';

import 'package:festeasy_app/features/auth/services/auth_service.dart';
import 'package:festeasy_app/features/auth/view/email_verification_page.dart'; // Importar EmailVerificationPage
import 'package:festeasy_app/features/dashboard/view/client_dashboard.dart';
import 'package:festeasy_app/features/dashboard/view/provider_dashboard.dart';
import 'package:festeasy_app/features/welcome/view/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
    Future.microtask(_handleInitialState);
  }

  void _setupAuthListener() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      final session = data.session;

      if (event == AuthChangeEvent.signedIn) {
        debugPrint('User signed in!');
        if (session != null) {
          if (!_authService.isEmailVerified()) {
            if (!mounted) return;
            await Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (context) => const EmailVerificationPage(),
              ),
            );
          } else {
            final profileData = await _authService.getProfileData();
            if (profileData != null) {
              final rol = profileData['rol'];
              if (rol == 'proveedor') {
                if (!mounted) return;
                await Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (context) => const ProviderDashboard(),
                  ),
                );
              } else if (rol == 'usuario' || rol == 'cliente') {
                if (!mounted) return;
                await Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (context) => const ClientDashboard(),
                  ),
                );
              }
            } else {
              // If profile data is null, something went wrong or user is not fully registered
              if (!mounted) return;
              await Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(
                  builder: (context) => const WelcomePage(),
                ),
              );
            }
          }
        } else {
          // If session is null, it's the first login.
          if (!mounted) return;
          await Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (context) => const WelcomePage(),
            ),
          );
        }
      } else if (event == AuthChangeEvent.signedOut) {
        debugPrint('User signed out!');
        if (!mounted) return;
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (context) => const WelcomePage()),
        );
      }
    });
  }

  Future<void> _handleInitialState() async {
    // Add a small delay to allow the auth state listener to fire
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (context) => const WelcomePage()),
      );
    } else {
      if (!_authService.isEmailVerified()) {
        if (!mounted) return;
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (context) => const EmailVerificationPage(),
          ),
        );
      } else {
        final profileData = await _authService.getProfileData();
        if (profileData != null) {
          final rol = profileData['rol'];
          if (rol == 'proveedor') {
            if (!mounted) return;
            await Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (context) => const ProviderDashboard(),
              ),
            );
          } else if (rol == 'usuario' || rol == 'cliente') {
            if (!mounted) return;
            await Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (context) => const ClientDashboard(),
              ),
            );
          }
        } else {
          // If profile data is null, something went wrong or user is not fully registered
          if (!mounted) return;
          await Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (context) => const WelcomePage(),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
