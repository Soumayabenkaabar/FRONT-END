import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/facture.dart';

/// Service Supabase pour la table `factures`
///
/// Table attendue :
/// ```
/// factures (
///   id             uuid primary key default gen_random_uuid(),
///   projet_id      uuid references projets(id) on delete cascade,
///   numero         text not null,
///   montant        numeric not null default 0,
///   statut         text default 'en_attente',  -- 'en_attente' | 'payee' | 'en_retard'
///   date_echeance  text,
///   created_at     timestamptz default now()
/// )
/// ```
class FactureService {
  static final _db = Supabase.instance.client;

  // ── Lire toutes les factures d'un projet ───────────────────────────────────
  static Future<List<Facture>> getFactures(String projetId) async {
    final response = await _db
        .from('factures')
        .select()
        .eq('projet_id', projetId)
        .order('created_at', ascending: true);

    return (response as List)
        .map((json) => Facture.fromJson(json))
        .toList();
  }

  // ── Ajouter une facture ────────────────────────────────────────────────────
  static Future<void> addFacture(Facture facture) async {
    await _db.from('factures').insert({
      'projet_id':     facture.projetId,
      'numero':        facture.numero,
      'montant':       facture.montant,
      'statut':        facture.statut,
      'date_echeance': facture.dateEcheance,
    });
  }

  // ── Mettre à jour le statut d'une facture ──────────────────────────────────
  static Future<void> updateStatut(String id, String statut) async {
    await _db
        .from('factures')
        .update({'statut': statut})
        .eq('id', id);
  }

  // ── Supprimer une facture ──────────────────────────────────────────────────
  static Future<void> deleteFacture(String id) async {
    await _db.from('factures').delete().eq('id', id);
  }
}