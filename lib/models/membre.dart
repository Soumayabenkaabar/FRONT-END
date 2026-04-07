class Membre {
  final String id;
  final String nom;
  final String role;
  final String specialite;
  final String email;
  final String telephone;
  final bool disponible;
  final List<String> projetsAssignes;

  Membre({
    required this.id,
    required this.nom,
    required this.role,
    required this.specialite,
    required this.email,
    required this.telephone,
    required this.disponible,
    required this.projetsAssignes,
  });

  factory Membre.fromJson(Map<String, dynamic> json) {
    return Membre(
      id: json['id'],
      nom: json['nom'] ?? '',
      role: json['role'] ?? '',
      specialite: json['specialite'] ?? '',
      email: json['email'] ?? '',
      telephone: json['telephone'] ?? '',
      disponible: json['disponible'] ?? true,
      projetsAssignes:
          List<String>.from(json['projets_assignes'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'role': role,
      'specialite': specialite,
      'email': email,
      'telephone': telephone,
      'disponible': disponible,
      'projets_assignes': projetsAssignes,
    };
  }
}