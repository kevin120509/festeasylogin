// ignore_for_file: deprecated_member_use, lines_longer_than_80_chars, always_put_required_named_parameters_first, use_super_parameters, document_ignores

import 'package:festeasy_app/features/dashboard/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// --- Colores y Estilos Personalizados (ACTUALIZADO CON NUEVOS COLORES) ---
class AppColors {
  static const Color primary = Color(0xFFEA4D4D); // Rojo del globo
  static const Color accentYellow = Color(0xFFFFD700); // Amarillo del confeti
  static const Color accentBlue = Color(0xFF4285F4); // Azul del confeti
  static const Color backgroundLight = Color(
    0xFFFBF8F2,
  ); // Fondo beige/crema de la imagen
  static const Color backgroundDark = Color(
    0xFF2C2720,
  ); // Un oscuro que combina con el crema
}

// Estilo para simular el 'liquid-glass' (Blur + Transparencia)
class LiquidGlassContainer extends StatelessWidget {
  const LiquidGlassContainer({
    super.key,
    required this.child,
    required this.isDark,
  });
  final Widget child;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    // Para el efecto de blur real se necesitaría usar BackdropFilter,
    // pero afecta el rendimiento. Aquí aplicamos solo la transparencia y un borde.
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.backgroundDark.withOpacity(0.2)
            : AppColors.backgroundLight.withOpacity(
                0.1,
              ), // Usa el nuevo backgroundLight para el efecto
        border: Border(
          top: BorderSide(
            color: (isDark ? Colors.white : Colors.black).withOpacity(
              0.1,
            ), // Borde adaptable al tema
          ),
        ),
      ),
      child: child,
    );
  }
}

// Estilo para el botón primario
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);
  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48, // h-12
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12), // rounded-xl
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFC6A6A),
            AppColors.primary,
          ], // Gradiente con el nuevo rojo
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          // Sombra con el nuevo color primario
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: -2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- Página Principal ---

class ProviderServicesPage extends StatelessWidget {
  const ProviderServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fondo blanco
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Contenido principal desplazable
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imagen de cabecera (w-full h-64)
                    Container(
                      height: 256,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            'assets/Portada-servicio.png',
                          ), // Imagen local
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Detalles del evento
                    Padding(
                      padding: const EdgeInsets.all(24), // p-6
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Título y organizador
                          const Text(
                            'Fiesta de Verano en la Playa',
                            style: TextStyle(
                              fontSize: 30, // text-3xl
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary, // Rojo
                              fontFamily: 'Spline Sans',
                            ),
                          ),
                          const SizedBox(height: 8), // mt-2
                          const Text(
                            'Organizado por Sofia Ramirez',
                            style: TextStyle(
                              color: Colors.grey, // Gris para contraste
                            ),
                          ),
                          const SizedBox(height: 24), // mt-6
                          // --- Detalles (Fecha, Hora, Lugar) ---
                          const Column(
                            children: [
                              _EventDetailItem(
                                iconPath: 'assets/calendar.svg',
                                text: '15 de Julio de 2024',
                              ),
                              SizedBox(height: 16), // space-y-4
                              _EventDetailItem(
                                iconPath: 'assets/clock.svg',
                                text: '20:00 - 02:00',
                              ),
                              SizedBox(height: 16),
                              _EventDetailItem(
                                iconPath: 'assets/pin.svg',
                                text: 'Playa de la Barceloneta, Barcelona',
                              ),
                            ],
                          ),

                          const SizedBox(height: 24), // mt-6
                          // Descripción
                          const Text(
                            'Una noche inolvidable en la playa con música en vivo, DJ, comida y bebidas. ¡No te lo pierdas!',
                            style: TextStyle(
                              color: Colors.black87, // Texto oscuro
                            ),
                          ),

                          const SizedBox(height: 32), // mt-8
                          // --- Asistentes ---
                          const Text(
                            'Asistentes',
                            style: TextStyle(
                              fontSize: 24, // text-2xl
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary, // Rojo
                            ),
                          ),
                          const SizedBox(height: 16), // mt-4
                          const _AttendeesRow(),
                          const SizedBox(height: 160),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 2. Header fijo blanco con rojo
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              child: _EventHeader(),
            ),
          ),

          // 3. Footer Fijo blanco con rojo
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              child: _EventFooter(),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Componentes Reutilizables ---

class _EventDetailItem extends StatelessWidget {
  const _EventDetailItem({required this.iconPath, required this.text});
  final String iconPath;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          iconPath,
          colorFilter: const ColorFilter.mode(
            AppColors.primary,
            BlendMode.srcIn,
          ), // Rojo
          height: 24,
          width: 24,
        ),
        const SizedBox(width: 16), // mr-4
        Text(
          text,
          style: const TextStyle(
            color: Colors.black87, // Texto oscuro
          ),
        ),
      ],
    );
  }
}

class _AttendeesRow extends StatelessWidget {
  const _AttendeesRow();

  @override
  Widget build(BuildContext context) {
    final profileUrls = <String>[
      'https://lh3.googleusercontent.com/aida-public/AB6AXuCWYqJREt5fc-o9xKWEjq98jCf6zaznxInuGTfmJYaFp-D5rbL3RU25Wxwy3PWtXkHagyhZfLIZ4gLd2bNSiNYwnSK3UfPBDZulye91pgAEFpnvvezy1j-GNscmDGS2QZhtehPrIV14D9zr2CV4qTfZ7Nf0KipZqTuSxhdwH2CY8-oh16rHk6VyiHklz_ZWCL0XBBCB4dpprsLjGQY9JmVX7cwf-eAd8tXW7q3k-4V2mtd8ks_uMLgA2nhSzacNhSbNpHX9Ax3wcxk',
      'httsp://lh3.googleusercontent.com/aida-public/AB6AXuCpGgwDxA00Wv-eg0dC8S4OOJdtXpNQGA212Tc071X6jCh6Oc0INYsHvSPLGMnIjen6PRqsSfsDFn5o9fAbbO1p__YLc-UqZlREG6gudw6IUkp64ZBu2nTjYFepjN7xcY0_ngl6N-woUPuUSVjf2AMMJI0jQ7j1CWekrTZE9f30hxu_eNdbNVK3C10RLFaFFowiW1hPCuO29FWCcwgS4UC4pD3Xq6ImaG9jRYjtL6R7rHYxH7y8MX5Lj-Bd1knkqR_IvBT3vmT0rS0',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuAfV7AxE0PfK0JkNmO2Imz-4sdsNvGx4SxWnOsJ0i3MehwGUkEZZGxeX4uNluK2BbRiS27tO6dSudvNaHPHig2LYtXpupYoGm0sFf873whZfxSBM19Hq9fvCj3zNY_G0fdoQH0JdtPYDRMWzRN-X2sWt1D1mTYcQtZ1ONGWVziN56wFoJ_O6NT070wKohAZx9oSWS3BUxVKTAdQN471zSYupaitLReXWklDSI_F6ZWyGkd4V60cS-ESx0d9fbBuMJr9JMQnO9eJez8',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuAJBl0APD1f8xXjKCSQHWbSbC2qx0VNP00qWcE0N9V1SFA6czkrirkt9RAVtfZx26M8wbATsGD5BARniP_iYPecvaMJj1uQeHt3p6fkUEUTOv0n5dzLKWEeD15KKnZLqHwQV8MI62TAvfFhABFMOXhzk74rstCW5_FZprYCwXNjoRjkfWpkOdNOathjzMq8tuQufQt1UNcUxf3BVgEA3YmGftnM6mFCoCtgibUojY2bKMM_dFGCwsXvGPAUymqT53WYLFZ_Fpdr0II',
    ];

    // Borde blanco
    const borderColor = Colors.white;

    return Row(
      children: [
        // Avatares solapados
        ...List.generate(profileUrls.length, (index) {
          return Align(
            widthFactor: 0.6, // -space-x-4 (aproximadamente, para solapar)
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: borderColor,
                  width: 4, // border-4
                ),
                image: DecorationImage(
                  image: NetworkImage(profileUrls[index]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        }),

        // Contador +5
        Align(
          widthFactor: 0.6,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: borderColor,
                width: 4,
              ),
              color: AppColors.primary.withOpacity(
                0.2,
              ), // Rojo con opacidad
            ),
            child: const Center(
              child: Text(
                '+5',
                style: TextStyle(
                  color: Colors.white,
                ), // Texto blanco para contraste
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EventHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          children: [
            // Botón de Volver
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: SvgPicture.asset(
                'assets/arrow_left.svg',
                colorFilter: const ColorFilter.mode(
                  AppColors.primary, // Rojo
                  BlendMode.srcIn,
                ),
                height: 24,
                width: 24,
              ),
            ),

            // Título centrado
            const Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: 24,
                ), // pr-6 (para compensar el botón)
                child: Text(
                  'Detalles del Evento',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18, // text-lg
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary, // Rojo
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventFooter extends StatelessWidget {
  const _EventFooter();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Sección de Botones
        Padding(
          padding: const EdgeInsets.all(16), // p-4
          child: Column(
            children: [
              PrimaryButton(
                text: 'Unirse al Evento',
                onPressed: () {},
              ),
              const SizedBox(height: 12), // space-y-3 (espacio entre botones)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navegar a HomeScreen (Mis Eventos)
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(
                        builder: (context) => const HomeScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Mis Eventos'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Navegación Inferior
        const SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _BottomNavItem(
                  iconPath: 'assets/home.svg',
                  label: 'Inicio',
                  isActive: false,
                ),
                _BottomNavItem(
                  iconPath: 'assets/calendar_bottom.svg',
                  label: 'Eventos',
                  isActive: true,
                ),
                _BottomNavItem(
                  iconPath: 'assets/profile.svg',
                  label: 'Perfil',
                  isActive: false,
                ),
                _BottomNavItem(
                  iconPath: 'assets/settings.svg',
                  label: 'Ajustes',
                  isActive: false,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.iconPath,
    required this.label,
    required this.isActive,
  });
  final String iconPath;
  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? AppColors.primary
        : Colors.grey; // Gris si no está activo
    final fontWeight = isActive ? FontWeight.bold : FontWeight.normal;

    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              iconPath,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              height: 24,
              width: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: fontWeight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
