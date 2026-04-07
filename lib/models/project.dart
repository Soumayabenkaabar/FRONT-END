class Project {
  final String id;
  final String clientId;
  final String titre;
  final String description;
  final String statut;
  final int avancement; // 0-100
  final String? dateDebut;
  final String? dateFin;
  final double budgetTotal;
  final double budgetDepense;
  final String client;
  final String localisation;
  final String chef;
  final int taches;

  // ✅ AJOUT
  final List<String> membres;
  final List<String> docs;

  Project({
    required this.id,
    required this.clientId,
    required this.titre,
    required this.description,
    required this.statut,
    required this.avancement,
    this.dateDebut,
    this.dateFin,
    this.budgetTotal = 0,
    this.budgetDepense = 0,
    this.client = '',
    this.localisation = '',
    this.chef = '',
    this.taches = 0,

    // ✅ DEFAULT VALUES (important)
    this.membres = const [],
    this.docs = const [],
  });

  // ── Aliases ─────────────────────────────────────────
  String get title => titre;
  String get status => statut;

  /// 0.0 → 1.0
  double get progress => avancement / 100.0;

  /// budget ratio
  double get budgetProgress =>
      budgetTotal > 0 ? (budgetDepense / budgetTotal).clamp(0.0, 1.0) : 0.0;

  // ── FROM JSON (Supabase safe) ───────────────────────
  factory Project.fromJson(Map<String, dynamic> j) {
    return Project(
      id: j['id'] ?? '',
      clientId: j['client_id'] ?? '',
      titre: j['titre'] ?? '',
      description: j['description'] ?? '',
      statut: j['statut'] ?? 'en_cours',
      avancement: (j['avancement'] ?? 0) as int,
      dateDebut: j['date_debut'],
      dateFin: j['date_fin'],
      budgetTotal: (j['budget_total'] as num?)?.toDouble() ?? 0,
      budgetDepense: (j['budget_depense'] as num?)?.toDouble() ?? 0,
      client: j['client'] ?? '',
      localisation: j['localisation'] ?? '',
      chef: j['chef'] ?? '',
      taches: j['taches'] ?? 0,

      // ✅ SAFE LIST PARSING
      membres: j['membres'] != null
          ? List<String>.from(j['membres'])
          : [],
      docs: j['docs'] != null
          ? List<String>.from(j['docs'])
          : [],
    );
  }

  // ── TO JSON ─────────────────────────────────────────
  Map<String, dynamic> toJson() {
    return {
      'client_id': clientId,
      'titre': titre,
      'description': description,
      'statut': statut,
      'avancement': avancement,
      'date_debut': dateDebut,
      'date_fin': dateFin,
      'budget_total': budgetTotal,
      'budget_depense': budgetDepense,
      'client': client,
      'localisation': localisation,
      'chef': chef,
      'taches': taches,

      // ✅ AJOUT
      'membres': membres,
      'docs': docs,
    };
  }
}
final List<Project> sampleProjects = [
  Project(
    id: '1',
    clientId: 'c1',
    titre: 'Villa Carthage',
    description: 'Construction villa R+1 avec piscine',
    statut: 'En cours',
    avancement: 65,
    dateDebut: 'Jan 2024',
    dateFin: 'Déc 2024',
    budgetTotal: 8500000,
    budgetDepense: 1070000,
    client: 'Groupe OCP',
    localisation: 'Carthage, Tunis',
    chef: 'Ahmed Ben Ali',
    taches: 12,

    // ✅ NEW
    membres: ['Ahmed', 'Sonia', 'Karim'],
    docs: ['plan.pdf', 'devis.xlsx'],
  ),
  Project(
    id: '2',
    clientId: 'c2',
    titre: 'Résidence Les Pins',
    description: 'Immeuble R+4, 16 appartements',
    statut: 'Planification',
    avancement: 20,
    dateDebut: 'Mar 2024',
    dateFin: 'Nov 2025',
    budgetTotal: 6500000,
    budgetDepense: 825000,
    client: 'Société Immobilière TN',
    localisation: 'La Marsa, Tunis',
    chef: 'Sonia Mrad',
    taches: 8,
    membres: ['Sonia', 'Ali'],
    docs: ['contrat.pdf'],
  ),
];