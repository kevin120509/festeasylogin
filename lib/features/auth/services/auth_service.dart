import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final user = response.user;

    if (user == null) {
      throw Exception('Credenciales inválidas');
    }

    // Ahora buscamos su perfil asociado
    final profile = await _supabase
        .from('profiles')
        .select('rol, full_name')
        .eq('id', user.id)
        .maybeSingle();

    // Si no hay perfil asociado
    if (profile == null) {
      throw Exception('No se encontró el perfil del usuario.');
    }

    final rol = profile['rol'];
    debugPrint('Rol detectado: $rol');

    return {
      'user': user,
      'rol': rol,
    };
  }

  Future<void> sendMagicLink(String email) async {
    try {
      await _supabase.auth.signInWithOtp(
        email: email,
        emailRedirectTo: 'io.supabase.flutterquickstart://login-callback/',
      );
      debugPrint('Magic link sent successfully to $email');
    } on AuthException catch (e) {
      debugPrint('Error sending magic link: ${e.message}');
    } on Exception catch (e) {
      debugPrint('An unexpected error occurred: $e');
    }
  }

  Future<User?> signUp(
    String email,
    String password,
    String fullName,
    String rol,
  ) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    final user = response.user;

    if (user != null) {
      await _supabase.from('profiles').insert({
        'id': user.id,
        'full_name': fullName,
        'rol': rol,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
    return user;
  }

  Future<Map<String, dynamic>?> getProfileData() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return null;
    }

    try {
      final profileResponse = await _supabase
          .from('profiles')
          .select('full_name, rol')
          .eq('id', user.id)
          .maybeSingle();

      return profileResponse;
    } on Exception catch (e, s) {
      debugPrint('Error fetching profile data: $e, stack trace: $s');
      return null;
    }
  }
}
