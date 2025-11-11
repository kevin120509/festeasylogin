import 'package:festeasy_app/features/auth/view/login_page.dart';
import 'package:festeasy_app/features/dashboard/view/client_dashboard.dart';
import 'package:festeasy_app/features/dashboard/view/provider_dashboard.dart';
import 'package:festeasy_app/features/splash/view/splash_page.dart';
import 'package:festeasy_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      },
    );
  }
}
