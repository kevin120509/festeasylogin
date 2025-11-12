import 'package:supabase_flutter/supabase_flutter.dart';
import 'request_model.dart';

class RequestsRepository {
  final SupabaseClient supabase;

  RequestsRepository({SupabaseClient? client}) : supabase = client ?? Supabase.instance.client;

  // Trae solicitudes asignadas a un proveedor (o abiertas si providerId == null)
  Future<List<RequestModel>> fetchRequestsForProvider(String providerId) async {
    final res = await supabase
        .from('requests')
        .select()
        .or('provider_id.eq.$providerId,status.eq.open')
        .order('created_at', ascending: false) as List<dynamic>?;

    if (res == null) return [];
    return res.map((e) => RequestModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  // Trae solicitudes creadas por un usuario (historial)
  Future<List<RequestModel>> fetchRequestsByUser(String userId) async {
    final res = await supabase
        .from('requests')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false) as List<dynamic>?;

    if (res == null) return [];
    return res.map((e) => RequestModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  // Crea una solicitud nueva
  Future<RequestModel?> createRequest({
    required String title,
    required String description,
    required String userId,
    int? budget,
  }) async {
    final now = DateTime.now().toIso8601String();
    final payload = {
      'title': title,
      'description': description,
      'user_id': userId,
      'status': 'open',
      'created_at': now,
      'budget': budget,
    };

    final response = await supabase.from('requests').insert(payload).select().single();
    if (response == null) return null;
    return RequestModel.fromJson(Map<String, dynamic>.from(response));
  }
}