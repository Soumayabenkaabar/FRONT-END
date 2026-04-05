class Client {
  final String nom;
  final String entreprise;
  final int nbProjets;
  final String email;
  final String telephone;
  final String dateDepuis;
  final bool accesPortail;

  const Client({
    required this.nom,
    required this.entreprise,
    required this.nbProjets,
    required this.email,
    required this.telephone,
    required this.dateDepuis,
    this.accesPortail = true,
  });
}

final List<Client> sampleClients = [
  const Client(
    nom: 'Groupe OCP',
    entreprise: 'OCP SA',
    nbProjets: 2,
    email: 'contact@ocp.ma',
    telephone: '0522123456',
    dateDepuis: '15/01/2023',
    accesPortail: true,
  ),
  const Client(
    nom: 'Ministère de la Santé',
    entreprise: 'Gouvernement',
    nbProjets: 1,
    email: 'hopital@sante.gov.ma',
    telephone: '0537112233',
    dateDepuis: '20/03/2023',
    accesPortail: true,
  ),
  const Client(
    nom: 'M. Alami',
    entreprise: 'Particulier',
    nbProjets: 1,
    email: 'alami@gmail.com',
    telephone: '0661234567',
    dateDepuis: '10/06/2023',
    accesPortail: false,
  ),
  const Client(
    nom: 'Société Delta Invest',
    entreprise: 'Immobilier',
    nbProjets: 1,
    email: 'contact@delta.ma',
    telephone: '0539876543',
    dateDepuis: '01/09/2023',
    accesPortail: true,
  ),
];