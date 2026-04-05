import 'package:flutter/material.dart';
import '../constants/colors.dart';

enum NotifType { budget, retard, info }

class AppNotification {
  final String id;
  final NotifType type;
  final String message;
  final String projet;
  final String date;
  final String heure;
  bool lue;

  AppNotification({
    required this.id,
    required this.type,
    required this.message,
    required this.projet,
    required this.date,
    this.heure = '01:00',
    this.lue = false,
  });

  String get typeLabel {
    switch (type) {
      case NotifType.budget: return 'Budget';
      case NotifType.retard: return 'Retard';
      case NotifType.info:   return 'Info';
    }
  }

  Color get typeColor {
    switch (type) {
      case NotifType.budget: return kRed;
      case NotifType.retard: return kAccent;
      case NotifType.info:   return const Color(0xFF3B82F6);
    }
  }

  IconData get typeIcon {
    switch (type) {
      case NotifType.budget: return Icons.attach_money_rounded;
      case NotifType.retard: return Icons.access_time_rounded;
      case NotifType.info:   return Icons.info_outline_rounded;
    }
  }
}

// Données mutables (non-const car lue peut changer)
final List<AppNotification> sampleNotifications = [
  AppNotification(
    id: '1',
    type: NotifType.budget,
    message: "Dépassement budget de 5% sur 'Élévation des murs' - Villa Moderne Casablanca",
    projet: 'Villa Moderne Casablanca',
    date: '26 mars 2026',
    heure: '01:00',
    lue: false,
  ),
  AppNotification(
    id: '2',
    type: NotifType.retard,
    message: "Retard de 3 jours prévu sur 'Fondations profondes' - Immeuble Résidentiel Rabat",
    projet: 'Immeuble Résidentiel Rabat',
    date: '25 mars 2026',
    heure: '01:00',
    lue: false,
  ),
  AppNotification(
    id: '3',
    type: NotifType.budget,
    message: "Dépassement budget de 20 000 MAD sur 'Terrassement' - Immeuble Résidentiel Rabat",
    projet: 'Immeuble Résidentiel Rabat',
    date: '24 mars 2026',
    heure: '',
    lue: true,
  ),
];