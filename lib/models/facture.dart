class Facture {
  final String id;
  final String projetId;
  final String numero;
  final double montant;
  final String statut; // 'en_attente' | 'payee' | 'en_retard'
  final String? dateEcheance;
  final String? urlPdf;
  final String createdAt;

  Facture({
    required this.id,
    required this.projetId,
    required this.numero,
    required this.montant,
    required this.statut,
    this.dateEcheance,
    this.urlPdf,
    required this.createdAt,
  });

  factory Facture.fromJson(Map<String, dynamic> j) => Facture(
        id: j['id'] ?? '',
        projetId: j['projet_id'] ?? '',
        numero: j['numero'] ?? '',
        montant: (j['montant'] as num?)?.toDouble() ?? 0,
        statut: j['statut'] ?? 'en_attente',
        dateEcheance: j['date_echeance'],
        urlPdf: j['url_pdf'],
        createdAt: j['created_at'] ?? '',
      );
}