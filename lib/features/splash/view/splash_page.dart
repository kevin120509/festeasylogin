import 'package:festeasy_app/features/auth/services/auth_service.dart';
import 'package:festeasy_app/features/auth/view/login_page.dart';
import 'package:festeasy_app/features/auth/view/role_selection_page.dart';
import 'package:festeasy_app/features/dashboard/view/client_dashboard.dart';
import 'package:festeasy_app/features/dashboard/view/provider_dashboard.dart';
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
  }

  void _setupAuthListener() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.signedIn) {
        print('User signed in!');
        if (session != null) {
          final profileData = await _authService.getProfileData();
          if (profileData != null) {
            final rol = profileData['rol'];
            if (rol == 'proveedor') {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (context) => const ProviderDashboard()),
              );
            } else if (rol == 'usuario') {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (context) => const ClientDashboard()),
              );
            }
          } else {
            // If profile data is null, it's the first login.
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => RoleSelectionPage()),
            );
          }
        }
      } else if (event == AuthChangeEvent.signedOut) {
        print('User signed out!');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    });

    // Handle initial state
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
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
