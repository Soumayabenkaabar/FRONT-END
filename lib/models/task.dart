import 'package:flutter/material.dart';

enum TaskStatus { termine, enCours, planifie }

class Task {
  final String id;
  final String titre;
  final TaskStatus status;
  final String dateDebut;
  final String dateFin;
  final double budgetPrevu;
  final double coutReel;
  final double progress;

  const Task({
    required this.id,
    required this.titre,
    required this.status,
    required this.dateDebut,
    required this.dateFin,
    required this.budgetPrevu,
    required this.coutReel,
    required this.progress,
  });

  String get statusLabel {
    switch (status) {
      case TaskStatus.termine:   return 'Terminé';
      case TaskStatus.enCours:   return 'En cours';
      case TaskStatus.planifie:  return 'Planifié';
    }
  }

  Color get statusColor {
    switch (status) {
      case TaskStatus.termine:   return const Color(0xFF374151);
      case TaskStatus.enCours:   return const Color(0xFFF5A623);
      case TaskStatus.planifie:  return const Color(0xFF9CA3AF);
    }
  }
}

class Phase {
  final String titre;
  final double progress;
  final List<Task> taches;

  const Phase({
    required this.titre,
    required this.progress,
    required this.taches,
  });
}

// ── Données Villa Moderne Casablanca ──────────────────────────────────────────
final phasesVillaCasablanca = [
  Phase(
    titre: 'Gros œuvre',
    progress: 0.55,
    taches: [
      const Task(
        id: 't1',
        titre: 'Fondations',
        status: TaskStatus.termine,
        dateDebut: '15 janv.',
        dateFin: '28 févr.',
        budgetPrevu: 300000,
        coutReel: 295000,
        progress: 1.0,
      ),
      const Task(
        id: 't2',
        titre: 'Élévation des murs',
        status: TaskStatus.enCours,
        dateDebut: '1 mars',
        dateFin: '30 avr.',
        budgetPrevu: 450000,
        coutReel: 275000,
        progress: 0.6,
      ),
      const Task(
        id: 't3',
        titre: 'Dalle du toit',
        status: TaskStatus.planifie,
        dateDebut: '1 mai',
        dateFin: '31 mai',
        budgetPrevu: 200000,
        coutReel: 0,
        progress: 0.0,
      ),
    ],
  ),
  Phase(
    titre: 'Second œuvre',
    progress: 0.10,
    taches: [
      const Task(
        id: 't4',
        titre: 'Plomberie',
        status: TaskStatus.planifie,
        dateDebut: '1 juin',
        dateFin: '30 juin',
        budgetPrevu: 180000,
        coutReel: 0,
        progress: 0.0,
      ),
      const Task(
        id: 't5',
        titre: 'Électricité',
        status: TaskStatus.planifie,
        dateDebut: '1 juil.',
        dateFin: '31 juil.',
        budgetPrevu: 150000,
        coutReel: 0,
        progress: 0.0,
      ),
    ],
  ),
  Phase(
    titre: 'Finitions',
    progress: 0.0,
    taches: [
      const Task(
        id: 't6',
        titre: 'Carrelage & Revêtements',
        status: TaskStatus.planifie,
        dateDebut: '1 août',
        dateFin: '31 août',
        budgetPrevu: 220000,
        coutReel: 0,
        progress: 0.0,
      ),
    ],
  ),
];

// Données par projet (index = sampleProjects index)
final List<List<Phase>> projectPhases = [
  phasesVillaCasablanca,
  // Immeuble Résidentiel Rabat
  [
    Phase(
      titre: 'Terrassement',
      progress: 0.80,
      taches: [
        const Task(
          id: 'r1',
          titre: 'Terrassement général',
          status: TaskStatus.termine,
          dateDebut: '1 févr.',
          dateFin: '28 févr.',
          budgetPrevu: 500000,
          coutReel: 490000,
          progress: 1.0,
        ),
        const Task(
          id: 'r2',
          titre: 'Fondations profondes',
          status: TaskStatus.enCours,
          dateDebut: '1 mars',
          dateFin: '15 avr.',
          budgetPrevu: 800000,
          coutReel: 580000,
          progress: 0.6,
        ),
      ],
    ),
  ],
  // Centre Commercial Tanger
  [
    Phase(
      titre: 'Études & Plans',
      progress: 0.05,
      taches: [
        const Task(
          id: 'c1',
          titre: 'Étude de sol',
          status: TaskStatus.enCours,
          dateDebut: '1 juin',
          dateFin: '30 juin',
          budgetPrevu: 150000,
          coutReel: 50000,
          progress: 0.33,
        ),
      ],
    ),
  ],
];