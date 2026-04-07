class Client {
  final String? id;

  final String nom;
  final String email;
  final String telephone;
  final String entreprise;
  final int nbProjets;
  final String dateDepuis;
  final bool accesPortail;

  Client({
    this.id,
    required this.nom,
    required this.email,
    required this.telephone,
    required this.entreprise,
    required this.nbProjets,
    required this.dateDepuis,
    required this.accesPortail,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      nom: json['nom'] ?? '',
      email: json['email'] ?? '',
      telephone: json['telephone'] ?? '',
      entreprise: json['entreprise'] ?? '',
      nbProjets: json['nb_projets'] ?? 0,
      dateDepuis: json['date_depuis'] ?? '',
      accesPortail: json['acces_portail'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nom': nom,
      'email': email,
      'telephone': telephone,
      'entreprise': entreprise,
      'acces_portail': accesPortail,
    };
  }
}