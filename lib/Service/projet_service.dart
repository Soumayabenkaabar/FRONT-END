import '../core/supabase_config.dart';
import '../models/project.dart';

class ProjetService {
  static final supabase = SupabaseConfig.client;

  // ── Lire tous les projets ─────────────────────────────────────────────────
  static Future<List<Project>> getProjets() async {
    final data = await supabase
        .from('projets')
        .select()
        .order('created_at', ascending: false);

    return (data as List).map((j) => Project.fromJson(j)).toList();
  }

  // ── Lire titres uniquement (pour les dropdowns) ───────────────────────────
  static Future<List<Map<String, dynamic>>> getProjetsTitres() async {
    final data = await supabase.from('projets').select('id, titre');
    return List<Map<String, dynamic>>.from(data);
  }

  // ── Ajouter un projet ─────────────────────────────────────────────────────
  static Future<void> addProjet(Project projet) async {
    await supabase.from('projets').insert(projet.toJson());
  }

  // ── Modifier un projet ────────────────────────────────────────────────────
  static Future<void> updateProjet(Project projet) async {
    await supabase
        .from('projets')
        .update(projet.toJson())
        .eq('id', projet.id);
  }

  // ── Supprimer un projet ───────────────────────────────────────────────────
  static Future<void> deleteProjet(String id) async {
    await supabase.from('projets').delete().eq('id', id);
  }
}