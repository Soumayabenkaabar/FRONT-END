import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../models/alert_item.dart';
import '../models/project.dart';
import '../widgets/kpi_card.dart';
import '../widgets/alert_card.dart';
import '../widgets/project_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final pad = isMobile ? 16.0 : 28.0;

    return Container(
      color: kBg,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(pad, pad, pad, pad + 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────────
            if (!isMobile) ...[
              const Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: kTextMain,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Vue d'ensemble de vos projets et activités",
                style: TextStyle(color: kTextSub, fontSize: 14),
              ),
              const SizedBox(height: 28),
            ] else ...[
              const Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: kTextMain,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                "Vue d'ensemble de vos projets et activités",
                style: TextStyle(color: kTextSub, fontSize: 13),
              ),
              const SizedBox(height: 20),
            ],

            // ── KPI Cards ─────────────────────────────────────────────────
            LayoutBuilder(
              builder: (context, constraints) {
                final isWideKpi = constraints.maxWidth > 700;

                final cards = [
                  const KpiCard(
                    title: 'Projets',
                    icon: Icons.folder_copy_outlined,
                    value: '3',
                    sub1Icon: Icons.circle,
                    sub1Text: '2 actifs',
                    sub1Color: kAccent,
                    sub2Icon: Icons.check_circle_outline,
                    sub2Text: '0 terminés',
                    sub2Color: kTextSub,
                    accentColor: kAccent,
                    hasProgress: false,
                  ),
                  const KpiCard(
                    title: 'Progression',
                    icon: Icons.trending_up_rounded,
                    value: '25%',
                    accentColor: kAccent,
                    hasProgress: true,
                    progressValue: 0.25,
                  ),
                  const KpiCard(
                    title: 'Coût réalisé',
                    icon: Icons.attach_money_rounded,
                    value: '1.895.000',
                    valueFontSize: 17,
                    sub1Text: 'Sur 15.000.000 MAD',
                    sub1Color: kTextSub,
                    accentColor: kAccent,
                    hasProgress: false,
                  ),
                  const KpiCard(
                    title: 'Alertes',
                    icon: Icons.warning_amber_rounded,
                    value: '2',
                    sub1Icon: Icons.attach_money_rounded,
                    sub1Text: '1 budget',
                    sub1Color: kRed,
                    sub2Icon: Icons.access_time_rounded,
                    sub2Text: '1 retard',
                    sub2Color: kAccent,
                    accentColor: kRed,
                    hasProgress: false,
                    borderColor: kRed,
                  ),
                ];

                if (isWideKpi) {
                  // Desktop : 4 cartes sur une ligne
                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (int i = 0; i < cards.length; i++) ...[
                          if (i > 0) const SizedBox(width: 12),
                          Expanded(child: cards[i]),
                        ],
                      ],
                    ),
                  );
                }

                // Mobile : 2 lignes de 2 cartes
                return Column(
                  children: [
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: cards[0]),
                          const SizedBox(width: 12),
                          Expanded(child: cards[1]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: cards[2]),
                          const SizedBox(width: 12),
                          Expanded(child: cards[3]),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),

            SizedBox(height: isMobile ? 20 : 28),

            // ── Alertes récentes ──────────────────────────────────────────
            Row(
              children: const [
                Icon(Icons.warning_amber_rounded, color: kAccent, size: 20),
                SizedBox(width: 8),
                Text(
                  'Alertes récentes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: kTextMain,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ...sampleAlerts.map(
              (alert) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AlertCard(alert: alert),
              ),
            ),

            SizedBox(height: isMobile ? 16 : 18),

            // ── Projets en cours ──────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Projets en cours',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: kTextMain,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                  ),
                  child: const Text(
                    'Voir tous →',
                    style: TextStyle(
                      color: kTextMain,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Projets : toujours en colonne sur mobile
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: sampleProjects
                        .take(2)
                        .map(
                          (p) => Expanded(
                            child: Padding(
                              padding: sampleProjects.indexOf(p) == 0
                                  ? const EdgeInsets.only(right: 12)
                                  : EdgeInsets.zero,
                              child: ProjectCard(project: p),
                            ),
                          ),
                        )
                        .toList(),
                  );
                }
                return Column(
                  children: sampleProjects
                      .take(2)
                      .map(
                        (p) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ProjectCard(project: p),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helper ────────────────────────────────────────────────────────────────────
Widget _kpiCardWrapper(double width, double height, Widget child) {
  return SizedBox(width: width, height: height, child: child);
}
