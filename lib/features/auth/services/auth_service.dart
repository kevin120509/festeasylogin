import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Servicio de autenticación que interactúa con Supabase.
/// La persistencia de la sesión del usuario (recordar el inicio de sesión)
/// es manejada automáticamente por el SDK de Supabase.
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
    try {
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
    } on PostgrestException catch (e) {
      debugPrint('PostgrestException during profile fetch: ${e.message}');
      rethrow;
    } catch (e, s) {
      debugPrint('Unexpected error during profile fetch: $e, stack: $s');
      rethrow;
    }
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
      try {
        final List<Map<String, dynamic>>? profilesInsertResult = await _supabase
            .from('profiles')
            .insert({
              'id': user.id,
              'full_name': fullName,
              'rol': rol,
              'created_at': DateTime.now().toIso8601String(),
            })
            .select(); // Use .select() to get the inserted data

        if (profilesInsertResult == null || profilesInsertResult.isEmpty) {
          throw Exception('No se pudo crear el perfil del usuario.');
        }

        // Insert into specific role table
        if (rol == 'cliente') {
          await _supabase.from('clientes').insert({
            'user_id': user.id,
            'full_name': fullName,
            'created_at': DateTime.now().toIso8601String(),
          });
        } else if (rol == 'proveedor') {
          await _supabase.from('proveedores').insert({
            'user_id': user.id,
            'full_name': fullName,
            'created_at': DateTime.now().toIso8601String(),
          });
        }
      } on PostgrestException catch (e) {
        debugPrint('PostgrestException during sign up: ${e.message}');
        rethrow;
      } catch (e, s) {
        debugPrint('Unexpected error during sign up: $e, stack: $s');
        rethrow;
      }
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

  bool isEmailVerified() {
    final user = _supabase.auth.currentUser;
    return user?.emailConfirmedAt != null;
  }

  Future<void> sendEmailVerification() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: user.email,
      );
    }
  }

  Future<void> reloadUser() async {
    await _supabase.auth.refreshSession();
  }
}
