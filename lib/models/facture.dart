/// Modèle Facture — table `factures`
///
/// Colonnes BDD :
///   id, projet_id, numero, montant, statut,
///   date_echeance, url_pdf, created_at
class Facture {
  final String  id;
  final String  projetId;
  final String  numero;
  final double  montant;
  final String  statut;        // 'en_attente' | 'payee' | 'en_retard'
  final String? dateEcheance;
  final String? urlPdf;
  final String  createdAt;

  Facture({
    required this.id,
    required this.projetId,
    required this.numero,
    required this.montant,
    this.statut      = 'en_attente',
    this.dateEcheance,
    this.urlPdf,
    this.createdAt   = '',
  });

  String get statutLabel {
    switch (statut) {
      case 'payee':     return 'Payée';
      case 'en_retard': return 'En retard';
      default:          return 'En attente';
    }
  }

  factory Facture.fromJson(Map<String, dynamic> j) => Facture(
    id:           j['id']?.toString()           ?? '',
    projetId:     j['projet_id']?.toString()    ?? '',
    numero:       j['numero']                   ?? '',
    montant:      (j['montant'] as num?)?.toDouble() ?? 0,
    statut:       j['statut']                   ?? 'en_attente',
    dateEcheance: j['date_echeance']?.toString(),
    urlPdf:       j['url_pdf']?.toString(),
    createdAt:    j['created_at']?.toString()   ?? '',
  );

  Map<String, dynamic> toJson() => {
    'projet_id':    projetId,
    'numero':       numero,
    'montant':      montant,
    'statut':       statut,
    'date_echeance': dateEcheance,
    if (urlPdf != null) 'url_pdf': urlPdf,
  };
}