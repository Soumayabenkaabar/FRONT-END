class Membre {
  final String nom;
  final String role;
  final String specialite;
  final String email;
  final String telephone;
  final bool disponible;
  final List<String> projetsAssignes;

  const Membre({
    required this.nom,
    required this.role,
    required this.specialite,
    required this.email,
    required this.telephone,
    required this.disponible,
    this.projetsAssignes = const [],
  });
}

final List<Membre> sampleMembres = [
  // ── Disponibles ──────────────────────────────────────────────────────────
  const Membre(
    nom: 'Laila Benjelloun',
    role: 'Électricien',
    specialite: 'Installations électriques',
    email: 'laila.b@archi.ma',
    telephone: '0667890123',
    disponible: true,
  ),
  const Membre(
    nom: 'Omar Cherkaoui',
    role: 'Plombier',
    specialite: 'Plomberie sanitaire',
    email: 'omar.c@archi.ma',
    telephone: '0668901234',
    disponible: true,
  ),

  // ── En activité ───────────────────────────────────────────────────────────
  const Membre(
    nom: 'Ahmed Bennani',
    role: 'Chef de projet',
    specialite: 'Gestion de projet',
    email: 'ahmed.bennani@archi.ma',
    telephone: '0661234567',
    disponible: false,
    projetsAssignes: ['Villa Moderne Casablanca'],
  ),
  const Membre(
    nom: 'Fatima Zahra',
    role: 'Architecte',
    specialite: 'Architecture résidentielle',
    email: 'fatima.z@archi.ma',
    telephone: '0662345678',
    disponible: false,
    projetsAssignes: ['Villa Moderne Casablanca'],
  ),
  const Membre(
    nom: 'Sanaa Idrissi',
    role: 'Ingénieur structure',
    specialite: 'Béton armé',
    email: 'sanaa.i@archi.ma',
    telephone: '0663456789',
    disponible: false,
    projetsAssignes: ['Immeuble Résidentiel Rabat'],
  ),
  const Membre(
    nom: 'Karim Tazi',
    role: 'Architecte',
    specialite: 'Architecture commerciale',
    email: 'karim.t@archi.ma',
    telephone: '0664567890',
    disponible: false,
    projetsAssignes: ['Centre Commercial Tanger'],
  ),
  const Membre(
    nom: 'Youssef Amrani',
    role: 'Technicien',
    specialite: 'Topographie',
    email: 'youssef.a@archi.ma',
    telephone: '0665678901',
    disponible: false,
    projetsAssignes: ['Immeuble Résidentiel Rabat'],
  ),
  const Membre(
    nom: 'Nadia Benali',
    role: 'Dessinatrice',
    specialite: 'Plans AutoCAD',
    email: 'nadia.b@archi.ma',
    telephone: '0666789012',
    disponible: false,
    projetsAssignes: ['Centre Commercial Tanger'],
  ),
];