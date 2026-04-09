/// Modèle Tache — table `taches`
///
/// Colonnes BDD :
///   id, projet_id, titre, description, statut,
///   date_debut, date_fin, budget_estime, created_at
class Tache {
  final String  id;
  final String  projetId;
  final String  titre;
  final String  description;
  final String  statut;       // 'en_attente' | 'en_cours' | 'termine'
  final String? dateDebut;
  final String? dateFin;
  final double  budgetEstime;
  final String  createdAt;

  const Tache({
    required this.id,
    required this.projetId,
    required this.titre,
    this.description  = '',
    this.statut       = 'en_attente',
    this.dateDebut,
    this.dateFin,
    this.budgetEstime = 0,
    this.createdAt    = '',
  });

  // ── Label et couleur gérés côté UI dans projet_detail_screen ─────────────
  String get statutLabel {
    switch (statut) {
      case 'en_cours':  return 'En cours';
      case 'termine':   return 'Terminé';
      default:          return 'Planifié';
    }
  }

  factory Tache.fromJson(Map<String, dynamic> j) => Tache(
    id:           j['id']?.toString()           ?? '',
    projetId:     j['projet_id']?.toString()    ?? '',
    titre:        j['titre']                    ?? '',
    description:  j['description']              ?? '',
    statut:       j['statut']                   ?? 'en_attente',
    dateDebut:    j['date_debut']?.toString(),
    dateFin:      j['date_fin']?.toString(),
    budgetEstime: (j['budget_estime'] as num?)?.toDouble() ?? 0,
    createdAt:    j['created_at']?.toString()   ?? '',
  );

  Map<String, dynamic> toJson() => {
    'projet_id':    projetId,
    'titre':        titre,
    'description':  description,
    'statut':       statut,
    'date_debut':   dateDebut,
    'date_fin':     dateFin,
    'budget_estime': budgetEstime,
  };
}