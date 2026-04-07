import '../core/supabase_config.dart';

class ProjetService {
  static final supabase = SupabaseConfig.client;

  static Future<List<Map<String, dynamic>>> getProjets() async {
    final data = await supabase
        .from('projets')
        .select('id, titre');

    return List<Map<String, dynamic>>.from(data);
  }
}