import 'dart:async';

import 'package:festeasy_app/features/auth/services/auth_service.dart';
import 'package:festeasy_app/features/auth/view/login_page.dart';
import 'package:festeasy_app/features/auth/view/role_selection_page.dart';
import 'package:festeasy_app/features/auth/view/set_password_page.dart';
import 'package:festeasy_app/features/dashboard/view/client_dashboard.dart';
import 'package:festeasy_app/features/dashboard/view/provider_dashboard.dart';
import 'package:festeasy_app/features/splash/view/splash_page.dart';
import 'package:festeasy_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final AuthService _authService = AuthService();
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      // Add a small delay to ensure the navigator is ready
      await Future.delayed(const Duration(milliseconds: 100));

      if (event == AuthChangeEvent.signedIn) {
        print('User signed in!');
        if (session != null) {
          final profileData = await _authService.getProfileData();
          if (profileData != null) {
            final rol = profileData['rol'];
            if (rol == 'proveedor') {
              navigatorKey.currentState?.pushReplacement(
                MaterialPageRoute(
                    builder: (context) => const ProviderDashboard()),
              );
            } else if (rol == 'usuario') {
              navigatorKey.currentState?.pushReplacement(
                MaterialPageRoute(
                    builder: (context) => const ClientDashboard()),
              );
            }
          } else {
            // If profile data is null, it's the first login.
            navigatorKey.currentState?.pushReplacement(
              MaterialPageRoute(builder: (context) => RoleSelectionPage()),
            );
          }
        }
      } else if (event == AuthChangeEvent.signedOut) {
        print('User signed out!');
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    });

    // Handle initial state
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      // Add a small delay to ensure the navigator is ready
      Future.delayed(const Duration(milliseconds: 100), () {
        navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      });
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        useMaterial3: true,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const SplashPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/provider_dashboard': (context) => const ProviderDashboard(),
        '/client_dashboard': (context) => const ClientDashboard(),
        '/set_password': (context) => const SetPasswordPage(),
      },
    );
  }
}
