// lib/features/auth/auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

/// Registra un nuevo usuario en Supabase con email, contraseña y metadatos adicionales,
/// incluyendo el rol del usuario.
///
/// [email]: El correo electrónico del usuario.
/// [password]: La contraseña del usuario.
/// [username]: El nombre de usuario deseado.
/// [fullName]: El nombre completo del usuario.
/// [rol]: El rol del usuario ('cliente' o 'proveedor').
///
/// Retorna un [AuthResponse] si el registro es exitoso, o `null` si ocurre un error.
Future<AuthResponse?> signUpUser({
  required String email,
  required String password,
  required String username,
  required String fullName,
  required String rol, // Nuevo parámetro para el rol
}) async {
  try {
    final AuthResponse response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
      data: {
        'username': username,
        'full_name': fullName,
        'rol': rol, // Añadido el rol al objeto data
      },
    );

    if (response.user != null) {
      print('Usuario registrado exitosamente: ${response.user!.email}');
      return response;
    } else if (response.session != null) {
      print('Sesión existente o flujo de confirmación iniciado.');
      return response;
    } else {
      print('Registro iniciado, se requiere confirmación por correo electrónico.');
      return response;
    }
  } on AuthException catch (e) {
    print('Error de autenticación al registrar usuario: ${e.message}');
    return null;
  } catch (e) {
    print('Error inesperado al registrar usuario: $e');
    return null;
  }
}

/// Reenvía el correo de confirmación a un usuario.
///
/// [email]: El correo electrónico del usuario al que se le reenviará la confirmación.
///
/// Retorna `true` si el correo se reenvió exitosamente, `false` en caso contrario.
Future<bool> resendConfirmationEmail({required String email}) async {
  try {
    await Supabase.instance.client.auth.resend(
      type: AuthResponseType.signup, // O AuthResponseType.emailChange si es para cambio de email
      email: email,
    );
    print('Correo de confirmación reenviado a $email');
    return true;
  } on AuthException catch (e) {
    print('Error al reenviar correo de confirmación: ${e.message}');
    return false;
  } catch (e) {
    print('Error inesperado al reenviar correo de confirmación: $e');
    return false;
  }
}