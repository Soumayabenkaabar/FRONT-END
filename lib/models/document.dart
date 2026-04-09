/// Modèle Document — table `documents`
///
/// Colonnes BDD :
///   id, projet_id, nom, url, type, taille_kb, uploaded_at
class Document {
  final String  id;
  final String  projetId;
  final String  nom;
  final String  url;
  final String  type;       // 'pdf' | 'dwg' | 'xlsx' | 'image' | 'autre'
  final int?    tailleKb;
  final String  uploadedAt;

  Document({
    required this.id,
    required this.projetId,
    required this.nom,
    required this.url,
    this.type       = 'pdf',
    this.tailleKb,
    this.uploadedAt = '',
  });

  factory Document.fromJson(Map<String, dynamic> j) => Document(
    id:         j['id']?.toString()        ?? '',
    projetId:   j['projet_id']?.toString() ?? '',
    nom:        j['nom']                   ?? '',
    url:        j['url']                   ?? '',
    type:       j['type']                  ?? 'pdf',
    tailleKb:   j['taille_kb'] as int?,
    uploadedAt: j['uploaded_at']?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {
    'projet_id': projetId,
    'nom':       nom,
    'url':       url,
    'type':      type,
    if (tailleKb != null) 'taille_kb': tailleKb,
  };
}