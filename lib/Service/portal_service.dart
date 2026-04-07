import 'package:archi_manager/models/project.dart';
import 'package:archi_manager/core/supabase_config.dart';

import 'package:archi_manager/models/document.dart';
import 'package:archi_manager/models/facture.dart';
import 'package:archi_manager/models/commentaire.dart';

class PortalService {
  static final _db = SupabaseConfig.client;

  // ── Auth ──────────────────────────────────────────────────────────────────

  static Future<void> login(String email, String password) async {
    await _db.auth.signInWithPassword(email: email, password: password);
  }

  static Future<void> logout() async {
    await _db.auth.signOut();
  }

  static bool get isLoggedIn => _db.auth.currentUser != null;
  static String get currentEmail => _db.auth.currentUser?.email ?? '';

  // ── Projets ───────────────────────────────────────────────────────────────

  static Future<List<Project>> getProjets() async {
    final data = await _db
        .from('projets')
        .select()
        .order('created_at', ascending: false);
    return (data as List).map((e) => Project.fromJson(e)).toList();
  }

  // ── Documents ─────────────────────────────────────────────────────────────

  static Future<List<Document>> getDocuments(String projetId) async {
    final data = await _db
        .from('documents')
        .select()
        .eq('projet_id', projetId)
        .order('uploaded_at', ascending: false);
    return (data as List).map((e) => Document.fromJson(e)).toList();
  }

  // ── Factures ──────────────────────────────────────────────────────────────

  static Future<List<Facture>> getFactures(String projetId) async {
    final data = await _db
        .from('factures')
        .select()
        .eq('projet_id', projetId)
        .order('created_at', ascending: false);
    return (data as List).map((e) => Facture.fromJson(e)).toList();
  }

  // ── Commentaires ──────────────────────────────────────────────────────────

  static Future<List<Commentaire>> getCommentaires(String projetId) async {
    final data = await _db
        .from('commentaires')
        .select()
        .eq('projet_id', projetId)
        .order('created_at', ascending: true);
    return (data as List).map((e) => Commentaire.fromJson(e)).toList();
  }

  static Future<void> addCommentaire(Commentaire c) async {
    await _db.from('commentaires').insert(c.toJson());
  }
}