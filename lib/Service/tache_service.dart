import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tache.dart';

/// Service Supabase pour la table `taches`
///
/// Table attendue :
/// ```
/// taches (
///   id            uuid primary key default gen_random_uuid(),
///   projet_id     uuid references projets(id) on delete cascade,
///   titre         text not null,
///   description   text default '',
///   statut        text default 'en_attente',   -- 'en_attente' | 'en_cours' | 'termine'
///   date_debut    text,
///   date_fin      text,
///   budget_estime numeric default 0,
///   created_at    timestamptz default now()
/// )
/// ```
class TacheService {
  static final _db = Supabase.instance.client;

  // ── Lire toutes les tâches d'un projet ─────────────────────────────────────
  static Future<List<Tache>> getTaches(String projetId) async {
    final response = await _db
        .from('taches')
        .select()
        .eq('projet_id', projetId)
        .order('created_at', ascending: true);

    return (response as List)
        .map((json) => Tache.fromJson(json))
        .toList();
  }

  // ── Ajouter une tâche ──────────────────────────────────────────────────────
  static Future<void> addTache(Tache tache) async {
    await _db.from('taches').insert({
      'projet_id':     tache.projetId,
      'titre':         tache.titre,
      'description':   tache.description,
      'statut':        tache.statut,
      'date_debut':    tache.dateDebut,
      'date_fin':      tache.dateFin,
      'budget_estime': tache.budgetEstime,
    });
  }

  // ── Mettre à jour le statut d'une tâche ────────────────────────────────────
  static Future<void> updateStatut(String id, String statut) async {
    await _db
        .from('taches')
        .update({'statut': statut})
        .eq('id', id);
  }

  // ── Supprimer une tâche ────────────────────────────────────────────────────
  static Future<void> deleteTache(String id) async {
    await _db.from('taches').delete().eq('id', id);
  }
}