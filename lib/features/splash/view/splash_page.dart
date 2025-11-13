import 'dart:async';

import 'package:festeasy_app/features/auth/services/auth_service.dart';
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
  @override
  void initState() {
    super.initState();
    unawaited(_navigateToNextScreen());
  }

  Future<void> _navigateToNextScreen() async {
    debugPrint('SplashPage: _navigateToNextScreen started');
    // Pequeña pausa para mostrar el splash
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) {
      debugPrint('SplashPage: Widget not mounted after delay.');
      return;
    }

    final currentUser = Supabase.instance.client.auth.currentUser;
    debugPrint('SplashPage: Current user: ${currentUser?.id}');

    if (currentUser == null) {
      debugPrint('SplashPage: No current user, navigating to WelcomePage.');
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (context) => const WelcomePage()),
      );
    } else {
      debugPrint('SplashPage: User logged in, fetching profile data.');
      try {
        final authService = AuthService();
        final profileData = await authService.getProfileData();
        debugPrint('SplashPage: Profile data fetched: $profileData');

        if (!mounted) return;
        if (profileData != null && profileData['rol'] != null) {
          final userRole = profileData['rol'] as String;
          debugPrint('SplashPage: User role: $userRole');
          if (userRole == 'cliente' || userRole == 'usuario') {
            debugPrint('SplashPage: Navigating to ClientDashboard.');
            await Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (context) => const ClientDashboard(),
              ),
            );
          } else if (userRole == 'proveedor') {
            debugPrint('SplashPage: Navigating to ProviderDashboard.');
            await Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (context) => const ProviderDashboard(),
              ),
            );
          } else {
            debugPrint('SplashPage: Unknown role, signing out and navigating to WelcomePage.');
            // Unknown role, sign out and go to welcome
            await Supabase.instance.client.auth.signOut();
            if (!mounted) return;
            await Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (context) => const WelcomePage(),
              ),
            );
          }
        } else {
          debugPrint('SplashPage: Profile data or role is null, signing out and navigating to WelcomePage.');
          // Profile data not found or role is null, sign out and go to welcome
          await Supabase.instance.client.auth.signOut();
          if (!mounted) return;
          await Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(builder: (context) => const WelcomePage()),
          );
        }
      } on AuthException catch (e) {
        debugPrint('SplashPage: AuthException fetching profile: $e');
        // Error fetching profile, sign out and go to welcome
        await Supabase.instance.client.auth.signOut();
        if (!mounted) return;
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (context) => const WelcomePage()),
        );
      } on Exception catch (e, s) {
        debugPrint('SplashPage: An unexpected error occurred: $e\n$s');
        // Catch any other unexpected errors, sign out and go to welcome
        await Supabase.instance.client.auth.signOut();
        if (!mounted) return;
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (context) => const WelcomePage()),
        );
      }
    }
    debugPrint('SplashPage: _navigateToNextScreen finished');
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
