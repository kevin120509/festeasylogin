import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<User?> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user;
    } on AuthException catch (e) {
      print('Error in AuthService.signIn: ${e.message}');
      throw Exception(e.message); // Re-throw with the specific message
    } catch (e) {
      print('Error in AuthService.signIn: $e');
      throw Exception('An unexpected error occurred during sign in.');
    }
  }

  Future<void> sendMagicLink(String email) async {
    try {
      await _supabase.auth.signInWithOtp(
        email: email,
        emailRedirectTo: 'festeasyapp://login-callback',
      );
      print('Magic link sent successfully to $email');
    } on AuthException catch (e) {
      print('Error sending magic link: ${e.message}');
    } catch (e) {
      print('An unexpected error occurred: $e');
    }
  }

  Future<User?> signUp(String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      return response.user;
    } catch (e) {
      print('Error in AuthService.signUp: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getProfileData() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return null;
    }

    final profileResponse = await _supabase
        .from('profiles')
        .select('rol')
        .eq('id', user.id)
        .single();

    if (profileResponse == null || profileResponse.isEmpty) {
      return null;
    }

    final rol = profileResponse['rol'];
    Map<String, dynamic> profileData = {'rol': rol};

    if (rol == 'proveedor') {
      final providerResponse = await _supabase
          .from('proveedores')
          .select()
          .eq('user_id', user.id)
          .single();
      if (providerResponse != null) {
        profileData.addAll(providerResponse);
      }
    } else if (rol == 'usuario') {
      final clientResponse = await _supabase
          .from('clientes')
          .select()
          .eq('user_id', user.id)
          .single();
      if (clientResponse != null) {
        profileData.addAll(clientResponse);
      }
    }

    return profileData;
  }

  Future<void> createProfile(String role) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return;
    }

    await _supabase.from('profiles').insert({
      'id': user.id,
      'rol': role,
    });

    if (role == 'proveedor') {
      await _supabase.from('proveedores').insert({'user_id': user.id});
    } else if (role == 'usuario') {
      await _supabase.from('clientes').insert({'user_id': user.id});
    }
  }

  Future<void> setUserPassword(String password) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in.');
    }
    await _supabase.auth.updateUser(
      UserAttributes(
        password: password,
      ),
    );
  }
}
