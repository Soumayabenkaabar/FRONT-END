import '../core/supabase_config.dart';
import '../models/membre.dart';

class MembreService {
  static final supabase = SupabaseConfig.client;

  // ── GET ─────────────────────────────
  static Future<List<Membre>> getMembres() async {
    final data = await supabase.from('membres').select();

    return (data as List)
        .map((e) => Membre.fromJson(e))
        .toList();
  }

  // ── ADD ─────────────────────────────
  static Future<void> addMembre(Membre membre) async {
    await supabase.from('membres').insert(membre.toJson());
  }

  // ── UPDATE 🔥 ───────────────────────
  static Future<void> updateMembre(Membre membre) async {
    if (membre.id == null) {
      throw Exception("ID membre null ❌");
    }

    await supabase
        .from('membres')
        .update(membre.toJson())
        .eq('id', membre.id!);
  }

  // ── DELETE 🔥 ───────────────────────
  static Future<void> deleteMembre(String id) async {
    await supabase.from('membres').delete().eq('id', id);
  }

  // ── ASSIGN TO PROJECT 🔥 ─────────────
  static Future<void> assignToProject({
    required String membreId,
    required String projectId,
  }) async {
    await supabase.from('project_members').insert({
      'membre_id': membreId,
      'project_id': projectId,
    });
  }static Future<void> assignMembre({
  required Membre membre,
  required String projet,
}) async {
  if (membre.id == null) return;

  // ✅ COPIE ICI 🔥
  final updatedProjects = List<String>.from(membre.projetsAssignes);

  if (!updatedProjects.contains(projet)) {
    updatedProjects.add(projet);
  }

  await supabase
      .from('membres')
      .update({
        'projets_assignes': updatedProjects,
        'disponible': false,
      })
      .eq('id', membre.id!);

  print("ASSIGNED: $projet to ${membre.nom}");
}
  // ── GET MEMBRES PAR PROJET 🔥 ───────
  static Future<List<Membre>> getMembresByProject(String projectId) async {
    final data = await supabase
        .from('project_members')
        .select('membres(*)')
        .eq('project_id', projectId);

    return (data as List)
        .map((e) => Membre.fromJson(e['membres']))
        .toList();
  }
}