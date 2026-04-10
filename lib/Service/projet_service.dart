import '../core/supabase_config.dart';
import '../models/project.dart';
import '../service/auth_service.dart'; // ← services minuscule

class ProjetService {
  static final _db = SupabaseConfig.client;

  // 🔥 GET — RLS filtre automatiquement
  static Future<List<Project>> getProjets() async {
    final data = await _db
        .from('projets')
        .select()
        .order('created_at', ascending: false);
    return (data as List).map((e) => Project.fromJson(e)).toList();
  }

  // ➕ INSERT
  static Future<void> addProjet(Project projet) async {
    final json = Map<String, dynamic>.from(projet.toJson());
    json['user_id'] = AuthService.currentUser!.id;
    await _db.from('projets').insert(json);
  }

  // ✏️ UPDATE
  static Future<void> updateProjet(Project projet) async {
    await _db.from('projets').update(projet.toJson()).eq('id', projet.id);
  }

  // 🗑️ DELETE
  static Future<void> deleteProjet(String id) async {
    await _db.from('projets').delete().eq('id', id);
  }
}
