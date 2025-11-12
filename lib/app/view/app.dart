<<<<<<< HEAD
import 'dart:async'; // Added for StreamSubscription
import 'package:flutter/services.dart'; // Added for PlatformException
import 'package:uni_links/uni_links.dart'; // Added for uni_links
import 'package:festeasy_app/core/theme/app_theme.dart';
import 'package:festeasy_app/features/dashboard/home_screen.dart';
import 'package:festeasy_app/features/dashboard/view/client_dashboard.dart';
import 'package:festeasy_app/features/dashboard/view/provider_dashboard.dart';
=======
import 'package:festeasy_app/features/auth/view/login_page.dart';
>>>>>>> 25ed4c27e52ec49a68cc98b89f1868e1e0621859
import 'package:festeasy_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
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
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
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
      home: const HomeScreen(),
      routes: {
        '/provider_dashboard': (context) => const ProviderDashboard(),
        '/client_dashboard': (context) => const ClientDashboard(),
      },
=======
      home: const LoginPage(),
>>>>>>> 25ed4c27e52ec49a68cc98b89f1868e1e0621859
    );
  }
}
