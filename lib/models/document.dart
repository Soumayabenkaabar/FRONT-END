
// ── document.dart ─────────────────────────────────────────────────────────────
class Document {
  final String id;
  final String projetId;
  final String nom;
  final String url;
  final String type;
  final int? tailleKb;
  final String uploadedAt;

  Document({
    required this.id,
    required this.projetId,
    required this.nom,
    required this.url,
    required this.type,
    this.tailleKb,
    required this.uploadedAt,
  });

  factory Document.fromJson(Map<String, dynamic> j) => Document(
        id: j['id'] ?? '',
        projetId: j['projet_id'] ?? '',
        nom: j['nom'] ?? '',
        url: j['url'] ?? '',
        type: j['type'] ?? 'pdf',
        tailleKb: j['taille_kb'],
        uploadedAt: j['uploaded_at'] ?? '',
      );
}