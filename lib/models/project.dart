class Project {
  final String title;
  final String client;
  final double progress;
  final String status;           // 'En cours' | 'Planification' | 'Terminé'
  final double budgetTotal;
  final double budgetDepense;
  final String chef;
  final int taches;
  final int membres;
  final int docs;
  final String localisation;
  final String dateDebut;
  final String dateFin;

  const Project({
    required this.title,
    required this.client,
    required this.progress,
    this.status = 'En cours',
    required this.budgetTotal,
    required this.budgetDepense,
    required this.chef,
    required this.taches,
    required this.membres,
    required this.docs,
    required this.localisation,
    required this.dateDebut,
    required this.dateFin,
  });

  double get budgetProgress => budgetDepense / budgetTotal;
}

final List<Project> sampleProjects = [
  const Project(
    title: 'Villa Moderne Casablanca',
    client: 'M. Alami',
    progress: 0.45,
    status: 'En cours',
    budgetTotal: 2500000,
    budgetDepense: 575000,
    chef: 'Ahmed Bennani',
    taches: 6,
    membres: 4,
    docs: 2,
    localisation: 'Anfa, Casablanca',
    dateDebut: 'janv. 2026',
    dateFin: 'déc. 2026',
  ),
  const Project(
    title: 'Immeuble Résidentiel Rabat',
    client: 'Promoteur Horizon',
    progress: 0.25,
    status: 'En cours',
    budgetTotal: 8500000,
    budgetDepense: 1070000,
    chef: 'Sanaa Idrissi',
    taches: 2,
    membres: 2,
    docs: 0,
    localisation: 'Agdal, Rabat',
    dateDebut: 'févr. 2026',
    dateFin: 'juin 2027',
  ),
  const Project(
    title: 'Centre Commercial Tanger',
    client: 'Société Delta Invest',
    progress: 0.05,
    status: 'Planification',
    budgetTotal: 15000000,
    budgetDepense: 250000,
    chef: 'Karim Tazi',
    taches: 1,
    membres: 1,
    docs: 0,
    localisation: 'Tanger Med, Tanger',
    dateDebut: 'juin 2026',
    dateFin: 'déc. 2027',
  ),
];