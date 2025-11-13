import 'package:festeasy_app/features/requests/data/request_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RequestsRepository {
  RequestsRepository({SupabaseClient? client})
    : supabase = client ?? Supabase.instance.client;

  final SupabaseClient supabase;

  // Trae solicitudes asignadas a un proveedor
  // (o abiertas si providerId == null)
  Future<List<RequestModel>> fetchRequestsForProvider(
    String providerId,
  ) async {
    final res =
        await supabase
                .from('requests')
                .select()
                .or('provider_id.eq.$providerId,status.eq.open')
                .order('created_at', ascending: false)
            as List<dynamic>;

    return res
        .map((e) => RequestModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Trae solicitudes creadas por un usuario (historial)
  Future<List<RequestModel>> fetchRequestsByUser(String userId) async {
    final res =
        await supabase
                .from('requests')
                .select()
                .eq('user_id', userId)
                .order('created_at', ascending: false)
            as List<dynamic>;

    return res
        .map((e) => RequestModel.fromJson(e as Map<String, dynamic>))
        .toList();
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

    final response = await supabase
        .from('requests')
        .insert(payload)
        .select()
        .single();
    return RequestModel.fromJson(response);
  }
}
