import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/colors.dart';
import '../models/membre.dart';
import '../widgets/membre_card.dart';

class EquipeScreen extends StatefulWidget {
  const EquipeScreen({super.key});

  @override
  State<EquipeScreen> createState() => _EquipeScreenState();
}

class _EquipeScreenState extends State<EquipeScreen> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final pad = isMobile ? 14.0 : 28.0;

    // 🔍 FILTRE
    final filtered = sampleMembres.where((m) {
      final name = m.nom.toLowerCase();
      return name.contains(searchQuery.toLowerCase());
    }).toList();

    final disponibles = filtered.where((m) => m.disponible).toList();
    final actifs = filtered.where((m) => !m.disponible).toList();
    final total = filtered.length;

    return Container(
      color: kBg,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(pad, pad, pad, pad + 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER ─────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Gestion de l\'équipe',
                    style: TextStyle(
                      fontSize: isMobile ? 22 : 28,
                      fontWeight: FontWeight.w800,
                      color: kTextMain,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.userPlus,
                      size: 16, color: Colors.white),
                   label:Text( isMobile ? 'Ajouter' : 'Ajouter un membre',
                        style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                 
                 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAccent,
                    padding: EdgeInsets.all(isMobile ? 10 : 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            Text(
              'Gérez votre équipe et leurs assignations aux projets',
              style: TextStyle(
                  color: kTextSub, fontSize: isMobile ? 12 : 14),
            ),

            const SizedBox(height: 24),

            // ── KPI STATS ─────────────────────────────
            isMobile
                ? Column(
                    children: [
                      _StatCard(
                        label: 'Total membres',
                        value: '$total',
                        icon: LucideIcons.briefcase,
                        iconColor: kAccent,
                      ),
                      const SizedBox(height: 8),
                      _StatCard(
                        label: 'En activité',
                        value: '${actifs.length}',
                        icon: LucideIcons.checkCircle,
                        iconColor: kTextSub,
                      ),
                      const SizedBox(height: 8),
                      _StatCard(
                        label: 'Disponibles',
                        value: '${disponibles.length}',
                        icon: LucideIcons.xCircle,
                        iconColor: kTextSub,
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Total membres',
                          value: '$total',
                          icon: LucideIcons.briefcase,
                          iconColor: kAccent,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          label: 'En activité',
                          value: '${actifs.length}',
                          icon: LucideIcons.checkCircle,
                          iconColor: kTextSub,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          label: 'Disponibles',
                          value: '${disponibles.length}',
                          icon: LucideIcons.xCircle,
                          iconColor: kTextSub,
                        ),
                      ),
                    ],
                  ),

            const SizedBox(height: 10),

            // 🔍 SEARCH BAR
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: kCardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: const InputDecoration(
                  icon: Icon(LucideIcons.search, size: 18),
                  hintText: "Rechercher un membre...",
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 19),

            // ── DISPONIBLES ─────────────────────────────
            _SectionTitle(
              icon: LucideIcons.checkCircle,
              iconColor: kAccent,
              title: 'Membres disponibles',
            ),

            const SizedBox(height: 16),

            isMobile
                ? Column(
                    children: disponibles
                        .map((m) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: MembreDisponibleCard(membre: m),
                            ))
                        .toList(),
                  )
                : Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: disponibles
                        .map((m) => SizedBox(
                              width: 300,
                              child:
                                  MembreDisponibleCard(membre: m),
                            ))
                        .toList(),
                  ),

            const SizedBox(height: 28),

            // ── ACTIFS ─────────────────────────────
            _SectionTitle(
              icon: LucideIcons.briefcase,
              iconColor: kTextSub,
              title: 'Membres en activité',
            ),

            const SizedBox(height: 16),

            Column(
              children: actifs
                  .map((m) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: MembreActifRow(membre: m),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── STAT CARD ─────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(14),
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
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                      color: kTextSub,
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                ),
              ),
              Icon(icon, color: iconColor, size: 20),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: kTextMain,
            ),
          ),
        ],
      ),
    );
  }
}

// ── SECTION TITLE ─────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;

  const _SectionTitle({
    required this.icon,
    required this.iconColor,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: kTextMain,
          ),
        ),
      ],
    );
  }
}