import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/colors.dart';
import '../models/client.dart';

class ClientCard extends StatelessWidget {
  final Client client;

  const ClientCard({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nom + badge projets
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        client.nom,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: kTextMain,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: kAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${client.nbProjets} Projet(s)',
                        style: const TextStyle(
                          color: kAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Entreprise
                Row(
                  children: [
                    const Icon(LucideIcons.building2,
                        size: 13, color: kTextSub),
                    const SizedBox(width: 6),
                    Text(
                      client.entreprise,
                      style: const TextStyle(
                          color: kTextSub, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Divider ───────────────────────────────────────────────────
          const Divider(height: 1, color: Color(0xFFF0F0F0)),

          // ── Coordonnées ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
            child: Column(
              children: [
                _InfoRow(
                    icon: LucideIcons.mail, text: client.email),
                const SizedBox(height: 8),
                _InfoRow(
                    icon: LucideIcons.phone, text: client.telephone),
                const SizedBox(height: 8),
                _InfoRow(
                  icon: LucideIcons.calendar,
                  text: 'Client depuis ${client.dateDepuis}',
                ),
              ],
            ),
          ),

          // ── Divider ───────────────────────────────────────────────────
          const Divider(height: 1, color: Color(0xFFF0F0F0)),

          // ── Accès portail ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Accès portail client:',
                  style: TextStyle(color: kTextSub, fontSize: 13),
                ),
                Text(
                  client.accesPortail ? 'Actif' : 'Inactif',
                  style: TextStyle(
                    color: client.accesPortail
                        ? const Color(0xFF10B981)
                        : kRed,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: kTextSub),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: kTextSub, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}