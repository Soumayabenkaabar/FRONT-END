import 'package:archi_manager/Service/auth_service.dart';

import '../core/supabase_config.dart';
import '../models/project.dart';
import '../service/auth_service.dart' hide AuthService;

class ProjetService {
  static final _db = SupabaseConfig.client;

  // 🔥 GET — RLS filtre automatiquement par user_id
  static Future<List<Project>> getProjets() async {
    final data = await _db
        .from('projets')
        .select()
        .order('created_at', ascending: false);
    return (data as List).map((e) => Project.fromJson(e)).toList();
  }

  // ➕ INSERT
  static Future<void> addProjet(Project projet) async {
    final json = projet.toJson();
    json['user_id'] = AuthService.currentUser!.id; // ← isolation
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