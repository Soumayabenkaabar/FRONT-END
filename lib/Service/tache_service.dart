import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tache.dart';

class TacheService {
  static final _db = Supabase.instance.client;

  static Future<List<Tache>> getTaches(String projetId) async {
    final response = await _db
        .from('taches')
        .select()
        .eq('projet_id', projetId)
        .order('created_at', ascending: true);
    return (response as List).map((json) => Tache.fromJson(json)).toList();
  }

  static Future<void> addTache(Tache tache) async {
    await _db.from('taches').insert({
      'projet_id': tache.projetId,
      'titre': tache.titre,
      'description': tache.description,
      'statut': tache.statut,
      'date_debut': tache.dateDebut,
      'date_fin': tache.dateFin,
      'budget_estime': tache.budgetEstime,
    });
  }

  // ← NOUVEAU : modifier une tâche complète
  static Future<void> updateTache(Tache tache) async {
    await _db
        .from('taches')
        .update({
          'titre': tache.titre,
          'description': tache.description,
          'statut': tache.statut,
          'date_debut': tache.dateDebut,
          'date_fin': tache.dateFin,
          'budget_estime': tache.budgetEstime,
        })
        .eq('id', tache.id);
  }

  static Future<void> updateStatut(String id, String statut) async {
    await _db.from('taches').update({'statut': statut}).eq('id', id);
  }

  static Future<void> deleteTache(String id) async {
    await _db.from('taches').delete().eq('id', id);
  }
}
