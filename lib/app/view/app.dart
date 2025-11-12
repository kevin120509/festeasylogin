import 'dart:async'; // Added for StreamSubscription
import 'package:flutter/services.dart'; // Added for PlatformException
import 'package:uni_links/uni_links.dart'; // Added for uni_links
import 'package:festeasy_app/core/theme/app_theme.dart';
import 'package:festeasy_app/features/dashboard/view/client_dashboard.dart';
import 'package:festeasy_app/features/dashboard/view/provider_dashboard.dart';
import 'package:festeasy_app/features/welcome/view/welcome_page.dart';
import 'package:festeasy_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Added for Supabase client

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _initUniLinks();
  }

  Future<void> _initUniLinks() async {
    // Manejar el deep link inicial si la app se abre con uno
    try {
      final initialLink = await getInitialLink();
      _handleLink(initialLink);
    } on PlatformException {
      // Manejar errores de plataforma
    }

    // Manejar deep links mientras la app está en ejecución
    _sub = uriLinkStream.listen((Uri? uri) {
      _handleLink(uri?.toString());
    }, onError: (err) {
      // Manejar errores
    });

    // Escuchar cambios en el estado de autenticación de Supabase
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        // El usuario ha iniciado sesión o su sesión ha sido confirmada
        // Aquí puedes añadir lógica para navegar a la pantalla principal
        print('Usuario confirmado y logeado!');
        // Ejemplo de navegación:
        // Navigator.of(context).pushReplacementNamed('/home');
      }
    });
  }

  void _handleLink(String? link) {
    if (link != null) {
      final uri = Uri.parse(link);
      // Supabase maneja automáticamente la sesión si el deep link es de confirmación
      // o de restablecimiento de contraseña. Solo necesitas asegurarte de que
      // el cliente de Supabase esté escuchando.
      // La librería supabase_flutter ya hace esto internamente cuando se inicializa.
      // Sin embargo, puedes añadir lógica aquí si necesitas navegar a una pantalla específica.

      if (uri.path == '/login-callback') {
        print('Deep link de Supabase recibido: $link');
        // Puedes añadir lógica de navegación específica aquí si es necesario
      }
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

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
      },
    );
  }
}
