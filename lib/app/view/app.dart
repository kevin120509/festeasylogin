import 'package:festeasy_app/core/theme/app_theme.dart';
import 'package:festeasy_app/features/dashboard/view/client_dashboard.dart';
import 'package:festeasy_app/features/dashboard/view/provider_dashboard.dart';
import 'package:festeasy_app/features/payment/view/payment_page.dart';
import 'package:festeasy_app/features/welcome/view/welcome_page.dart';
import 'package:festeasy_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const WelcomePage(),
      routes: {
        '/provider_dashboard': (context) => const ProviderDashboard(),
        '/client_dashboard': (context) => const ClientDashboard(),
        '/payment': (context) => const PaymentPage(),
      },
    );
  }
}
