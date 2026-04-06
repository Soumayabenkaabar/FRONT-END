import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/colors.dart';
import '../models/project.dart';
import '../models/task.dart';

class FinancesTab extends StatelessWidget {
  final Project project;
  final int projectIndex;

  const FinancesTab({
    super.key,
    required this.project,
    required this.projectIndex,
  });

  String _fmt(double v) {
    if (v == 0) return '0 MAD';
    final s = v.toInt().toString();
    final buf = StringBuffer();
    int c = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (c > 0 && c % 3 == 0) buf.write('.');
      buf.write(s[i]);
      c++;
    }
    return '${buf.toString().split('').reversed.join()} MAD';
  }

  List<Task> get _allTasks {
    if (projectIndex >= projectPhases.length) return [];
    return projectPhases[projectIndex]
        .expand((p) => p.taches)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final pad = isMobile ? 16.0 : 28.0;

    final budget    = project.budgetTotal;
    final depense   = project.budgetDepense;
    final restant   = budget - depense;
    final pctBudget = depense / budget;
    final tasks     = _allTasks;
    final nbFactures = 3; // simulé
    final tasks2 = [
      _FinanceTask('Fondations',          300000, 295000),
      _FinanceTask('Élévation des murs',  500000, 280000),
      _FinanceTask('Charpente et toiture',350000, 0),
      _FinanceTask('Plomberie',           200000, 0),
      _FinanceTask('Électricité',         250000, 0),
      _FinanceTask('Finitions intérieures',400000, 0),
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(pad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Gestion financière',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: kTextMain)),
                    SizedBox(height: 2),
                    Text('Suivi du budget, factures et paiements',
                        style: TextStyle(color: kTextSub, fontSize: 12)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(LucideIcons.plus,
                    size: 14, color: Colors.white),
                label: const Text('Nouvelle facture',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccent,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── KPI Cards ────────────────────────────────────────────────
          LayoutBuilder(builder: (ctx, constraints) {
            final cols = constraints.maxWidth > 600 ? 4 : 2;
            final cards = [
              _FinKpiCard(
                icon: LucideIcons.dollarSign,
                iconColor: kAccent,
                label: 'Budget prévu',
                value: _fmt(budget),
              ),
              _FinKpiCard(
                icon: LucideIcons.trendingUp,
                iconColor: kAccent,
                label: 'Coût réalisé',
                value: _fmt(depense),
                sub: '${(pctBudget * 100).toStringAsFixed(0)}% du budget',
              ),
              _FinKpiCard(
                icon: LucideIcons.trendingDown,
                iconColor: const Color(0xFF10B981),
                label: 'Reste à payer',
                value: _fmt(restant),
              ),
              _FinKpiCard(
                icon: LucideIcons.fileText,
                iconColor: kTextSub,
                label: 'Factures',
                value: '$nbFactures',
                sub: 'Total facturé: ${_fmt(depense)}',
              ),
            ];
            return Column(
              children: [
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: cards[0]),
                      const SizedBox(width: 12),
                      Expanded(child: cards[1]),
                      if (cols == 4) ...[
                        const SizedBox(width: 12),
                        Expanded(child: cards[2]),
                        const SizedBox(width: 12),
                        Expanded(child: cards[3]),
                      ],
                    ],
                  ),
                ),
                if (cols == 2) ...[
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
              ],
            );
          }),

          const SizedBox(height: 20),

          // ── Utilisation du budget ────────────────────────────────────
          _Section(
            title: 'Utilisation du budget',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Budget consommé',
                        style: TextStyle(color: kTextSub, fontSize: 13)),
                    Text('${_fmt(depense)} / ${_fmt(budget)}',
                        style: const TextStyle(
                            color: kTextSub, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: pctBudget,
                    minHeight: 10,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(kAccent),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Budget par tâche ─────────────────────────────────────────
          _Section(
            title: 'Budget par tâche',
            child: isMobile
                ? _MobileTaskTable(tasks: tasks2, fmt: _fmt)
                : _DesktopTaskTable(tasks: tasks2, fmt: _fmt),
          ),
        ],
      ),
    );
  }
}

// ── Finance Task data ─────────────────────────────────────────────────────────
class _FinanceTask {
  final String titre;
  final double budgetPrevu;
  final double coutReel;
  double get ecart => coutReel - budgetPrevu;
  _FinanceTask(this.titre, this.budgetPrevu, this.coutReel);
}

// ── KPI Card ──────────────────────────────────────────────────────────────────
class _FinKpiCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String? sub;
  const _FinKpiCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(label,
                    style: const TextStyle(
                        color: kTextSub, fontSize: 12),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: kTextMain),
              overflow: TextOverflow.ellipsis),
          if (sub != null) ...[
            const SizedBox(height: 4),
            Text(sub!,
                style: const TextStyle(
                    color: kTextSub, fontSize: 11)),
          ],
        ],
      ),
    );
  }
}

// ── Desktop table ─────────────────────────────────────────────────────────────
class _DesktopTaskTable extends StatelessWidget {
  final List<_FinanceTask> tasks;
  final String Function(double) fmt;
  const _DesktopTaskTable(
      {required this.tasks, required this.fmt});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(
              vertical: 10, horizontal: 12),
          decoration: const BoxDecoration(
            border: Border(
                bottom: BorderSide(color: Color(0xFFE5E7EB))),
          ),
          child: const Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Text('Tâche',
                      style: TextStyle(
                          color: kTextSub,
                          fontSize: 12,
                          fontWeight: FontWeight.w600))),
              Expanded(
                  flex: 2,
                  child: Text('Budget prévu',
                      style: TextStyle(
                          color: kTextSub, fontSize: 12))),
              Expanded(
                  flex: 2,
                  child: Text('Coût réel',
                      style: TextStyle(
                          color: kTextSub, fontSize: 12))),
              Expanded(
                  flex: 2,
                  child: Text('Écart',
                      style: TextStyle(
                          color: kTextSub, fontSize: 12))),
              SizedBox(
                  width: 60,
                  child: Text('Statut',
                      style: TextStyle(
                          color: kTextSub, fontSize: 12))),
            ],
          ),
        ),
        // Rows
        ...tasks.map((t) => Container(
              padding: const EdgeInsets.symmetric(
                  vertical: 12, horizontal: 12),
              decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: Color(0xFFF3F4F6))),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(t.titre,
                        style: const TextStyle(
                            color: kTextMain,
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(fmt(t.budgetPrevu),
                        style: const TextStyle(
                            color: kTextMain, fontSize: 13)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(fmt(t.coutReel),
                        style: const TextStyle(
                            color: kTextMain, fontSize: 13)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      t.ecart == 0
                          ? '—'
                          : '${t.ecart < 0 ? '' : '+'}${fmt(t.ecart)}',
                      style: TextStyle(
                        color: t.ecart <= 0
                            ? const Color(0xFF10B981)
                            : kRed,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF374151),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Text('OK',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

// ── Mobile table ──────────────────────────────────────────────────────────────
class _MobileTaskTable extends StatelessWidget {
  final List<_FinanceTask> tasks;
  final String Function(double) fmt;
  const _MobileTaskTable(
      {required this.tasks, required this.fmt});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: tasks
          .map((t) => Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: Color(0xFFF3F4F6))),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(t.titre,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: kTextMain)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF374151),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('OK',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _MiniLabel('Prévu', fmt(t.budgetPrevu)),
                        const SizedBox(width: 16),
                        _MiniLabel('Réel', fmt(t.coutReel)),
                        const SizedBox(width: 16),
                        _MiniLabel(
                          'Écart',
                          t.ecart == 0
                              ? '—'
                              : '${t.ecart < 0 ? '' : '+'}${fmt(t.ecart)}',
                          color: t.ecart <= 0
                              ? const Color(0xFF10B981)
                              : kRed,
                        ),
                      ],
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

class _MiniLabel extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _MiniLabel(this.label, this.value, {this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: kTextSub, fontSize: 10)),
        Text(value,
            style: TextStyle(
                color: color ?? kTextMain,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ── Section card ──────────────────────────────────────────────────────────────
class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: kTextMain)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}