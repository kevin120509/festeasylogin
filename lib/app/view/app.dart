<<<<<<< HEAD
import 'package:festeasy_app/features/auth/view/login_page.dart'; // Importación unificada
import 'package:festeasy_app/features/dashboard/home_screen.dart';
import 'package:festeasy_app/features/dashboard/view/client_dashboard.dart';
import 'package:festeasy_app/features/dashboard/view/provider_dashboard.dart';
=======
import 'dart:async'; // Added for StreamSubscription
import 'package:flutter/services.dart'; // Added for PlatformException
import 'package:uni_links/uni_links.dart'; // Added for uni_links
import 'package:festeasy_app/core/theme/app_theme.dart';
import 'package:festeasy_app/features/dashboard/home_screen.dart';
import 'package:festeasy_app/features/dashboard/view/client_dashboard.dart';
import 'package:festeasy_app/features/dashboard/view/provider_dashboard.dart';
import 'package:festeasy_app/features/payment/view/payment_page.dart';
import 'package:festeasy_app/features/welcome/view/welcome_page.dart';
>>>>>>> 82c47dfb1d761e597520ea79cb7b380e13b3b400
import 'package:festeasy_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  // Aquí podrías agregar lógica para uni_links si la usas
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blue),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
<<<<<<< HEAD

      // SOLO UNA VEZ: Usamos LoginPage como pantalla inicial
      home: const LoginPage(),

      // Definimos las rutas nombradas que se usan después del login
=======
      home: const HomeScreen(),
>>>>>>> 82c47dfb1d761e597520ea79cb7b380e13b3b400
      routes: {
        '/home': (context) => const HomeScreen(),
        '/provider_dashboard': (context) => const ProviderDashboard(),
        '/client_dashboard': (context) => const ClientDashboard(),
        '/payment': (context) => const PaymentPage(),
      },
    );
  }
}
