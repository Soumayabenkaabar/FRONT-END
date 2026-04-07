import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/colors.dart';
import '../models/project.dart';
import '../models/task.dart';
import '../widgets/finances_tab.dart';
import '../widgets/suivi_photos_tab.dart';
import '../widgets/equipe_tab.dart';
import '../widgets/documents_tab.dart';
import '../widgets/modele3d_tab.dart';
import '../widgets/commentaires_tab.dart';

class ProjetDetailScreen extends StatefulWidget {
  final Project project;
  final int projectIndex;

  const ProjetDetailScreen({
    super.key,
    required this.project,
    required this.projectIndex,
  });

  @override
  State<ProjetDetailScreen> createState() => _ProjetDetailScreenState();
}

class _ProjetDetailScreenState extends State<ProjetDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _tabs = const [
    'Planning & Tâches',
    'Finances',
    'Suivi & Photos',
    'Équipe',
    'Documents',
    'Modèle 3D',
    'Commentaires',
  ];

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

  Color get _statusColor {
    switch (widget.project.statut) {
      case 'En cours':      return kAccent;
      case 'Planification': return const Color(0xFFADB5BD);
      default:              return const Color(0xFF28A745);
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final pad      = isMobile ? 16.0 : 28.0;
    final p        = widget.project;
    final phases   = widget.projectIndex < projectPhases.length
        ? projectPhases[widget.projectIndex]
        : <Phase>[];

    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [

          // ══════════════════════════════════════════════════════════
          //  HEADER BLANC
          // ══════════════════════════════════════════════════════════
          Material(
            color: kCardBg,
            elevation: 0,
            child: Padding(
              padding: EdgeInsets.fromLTRB(pad, 16, pad, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Retour ────────────────────────────────────────
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back_ios_rounded,
                            size: 14, color: kTextSub),
                        SizedBox(width: 4),
                        Text('Retour aux projets',
                            style: TextStyle(
                                color: kTextSub, fontSize: 13)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Titre + statut + actions ───────────────────────
                  isMobile
                      ? _buildMobileHeader(p)
                      : _buildDesktopHeader(p),

                  const SizedBox(height: 16),

                  // ── Progression globale ───────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Progression Globale',
                          style: TextStyle(
                              color: kTextSub,
                              fontSize: 13,
                              fontWeight: FontWeight.w500)),
                      Text('${(p.avancement * 100).toInt()}%',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: kTextMain,
                              fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: p.avancement.toDouble(),
                      minHeight: 8,
                      backgroundColor: const Color(0xFFE5E7EB),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(_statusColor),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Onglets ───────────────────────────────────────
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    labelColor: kTextMain,
                    unselectedLabelColor: kTextSub,
                    labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13),
                    unselectedLabelStyle:
                        const TextStyle(fontSize: 13),
                    indicatorColor: kAccent,
                    indicatorWeight: 3,
                    dividerColor: const Color(0xFFE5E7EB),
                    tabs: _tabs.map((t) => Tab(text: t)).toList(),
                  ),
                ],
              ),
            ),
          ),

          // ══════════════════════════════════════════════════════════
          //  CONTENU ONGLETS
          // ══════════════════════════════════════════════════════════
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _PlanningTab(phases: phases, isMobile: isMobile),
                FinancesTab(
                    project: widget.project,
                    projectIndex: widget.projectIndex),
                const SuiviPhotosTab(),
                const EquipeTab(),
                const DocumentsTab(),
                Modele3DTab(projectIndex: widget.projectIndex),
                const CommentairesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Desktop header ──────────────────────────────────────────────────────────
  Widget _buildDesktopHeader(Project p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Titre + badge
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(p.titre,
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: kTextMain)),
                  ),
                  const SizedBox(width: 12),
                  _StatusBadge(
                      label: p.statut, color: _statusColor),
                ],
              ),
            ),
            // Actions
            Row(
              children: [
                _AccessToggle(),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF374151),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Terminer le projet',
                      style: TextStyle(
                          color: Colors.white, fontSize: 13)),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: kRed),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Annuler',
                      style: TextStyle(color: kRed, fontSize: 13)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text('Client: ${p.client}',
            style: const TextStyle(color: kTextSub, fontSize: 13)),
        const SizedBox(height: 16),
        // 4 info cards
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                  child: _InfoCard(
                      icon: LucideIcons.mapPin,
                      label: 'Localisation',
                      value: p.localisation)),
              const SizedBox(width: 12),
              Expanded(
                  child: _InfoCard(
                      icon: LucideIcons.calendar,
                      label: 'Période',
                      value: '${p.dateDebut} - ${p.dateFin}')),
              const SizedBox(width: 12),
              Expanded(
                  child: _InfoCard(
                      icon: LucideIcons.user,
                      label: 'Chef de projet',
                      value: p.chef)),
              const SizedBox(width: 12),
              Expanded(
                  child: _InfoCard(
                      icon: LucideIcons.dollarSign,
                      label: 'Budget Consommé',
                      value: '${_fmt(p.budgetDepense)} / ${_fmt(p.budgetTotal)}')),
            ],
          ),
        ),
      ],
    );
  }

  // ── Mobile header ───────────────────────────────────────────────────────────
  Widget _buildMobileHeader(Project p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(p.title,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: kTextMain)),
            ),
            _StatusBadge(label: p.status, color: _statusColor),
          ],
        ),
        const SizedBox(height: 4),
        Text('Client: ${p.client}',
            style: const TextStyle(color: kTextSub, fontSize: 12)),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _InfoChip(icon: LucideIcons.mapPin, text: p.localisation),
              const SizedBox(width: 8),
              _InfoChip(icon: LucideIcons.user, text: p.chef),
              const SizedBox(width: 8),
              _InfoChip(
                  icon: LucideIcons.dollarSign,
                  text: '${_fmt(p.budgetDepense)} / ${_fmt(p.budgetTotal)}'),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _AccessToggle(),
            const Spacer(),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: kRed),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Annuler',
                  style: TextStyle(color: kRed, fontSize: 12)),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF374151),
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Terminer',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ],
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  PLANNING TAB
// ══════════════════════════════════════════════════════════════════════════════
class _PlanningTab extends StatefulWidget {
  final List<Phase> phases;
  final bool isMobile;
  const _PlanningTab({required this.phases, required this.isMobile});

  @override
  State<_PlanningTab> createState() => _PlanningTabState();
}

class _PlanningTabState extends State<_PlanningTab> {
  bool _isListView = true;

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

  @override
  Widget build(BuildContext context) {
    final pad = widget.isMobile ? 16.0 : 28.0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(pad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Planning des tâches',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: kTextMain)),
                    SizedBox(height: 2),
                    Text(
                        'Gérez le planning et suivez la progression de chaque tâche',
                        style: TextStyle(color: kTextSub, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Row(
                children: [
                  _ViewToggleBtn(
                    label: 'Liste',
                    icon: LucideIcons.list,
                    active: _isListView,
                    onTap: () => setState(() => _isListView = true),
                  ),
                  const SizedBox(width: 6),
                  _ViewToggleBtn(
                    label: 'Gantt',
                    icon: LucideIcons.barChart2,
                    active: !_isListView,
                    onTap: () => setState(() => _isListView = false),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(LucideIcons.plus,
                        size: 13, color: Colors.white),
                    label: const Text('Nouvelle tâche',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAccent,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          if (_isListView)
            ...widget.phases.map((phase) => _PhaseSection(
                  phase: phase,
                  isMobile: widget.isMobile,
                  onFormatMad: _fmt,
                ))
          else
            _GanttView(phases: widget.phases),
        ],
      ),
    );
  }
}

// ── Phase Section ─────────────────────────────────────────────────────────────
class _PhaseSection extends StatefulWidget {
  final Phase phase;
  final bool isMobile;
  final String Function(double) onFormatMad;

  const _PhaseSection({
    required this.phase,
    required this.isMobile,
    required this.onFormatMad,
  });

  @override
  State<_PhaseSection> createState() => _PhaseSectionState();
}

class _PhaseSectionState extends State<_PhaseSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final pct = (widget.phase.progress * 100).toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // Phase header
          InkWell(
            onTap: () =>
                setState(() => _expanded = !_expanded),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(widget.phase.titre,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: kTextMain)),
                  ),
                  Text('$pct% complété',
                      style: const TextStyle(
                          color: kTextSub, fontSize: 12)),
                  const SizedBox(width: 8),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: kTextSub,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: widget.phase.progress,
                minHeight: 6,
                backgroundColor: const Color(0xFFE5E7EB),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(kAccent),
              ),
            ),
          ),

          if (_expanded) ...[
            const Divider(height: 1, color: Color(0xFFF3F4F6)),
            ...widget.phase.taches.map((t) => _TaskRow(
                  task: t,
                  isMobile: widget.isMobile,
                  onFormatMad: widget.onFormatMad,
                )),
          ],
        ],
      ),
    );
  }
}

// ── Task Row ──────────────────────────────────────────────────────────────────
class _TaskRow extends StatelessWidget {
  final Task task;
  final bool isMobile;
  final String Function(double) onFormatMad;

  const _TaskRow({
    required this.task,
    required this.isMobile,
    required this.onFormatMad,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: isMobile
          ? _buildMobile()
          : _buildDesktop(),
    );
  }

  Widget _buildDesktop() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre + badge
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(task.titre,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: kTextMain)),
              const SizedBox(height: 6),
              _TaskBadge(task: task),
            ],
          ),
        ),
        // Dates
        Expanded(
          flex: 2,
          child: _Col(
              icon: LucideIcons.calendar,
              label: 'Dates',
              value: '${task.dateDebut} — ${task.dateFin}'),
        ),
        // Budget prévu
        Expanded(
          flex: 2,
          child: _Col(
              icon: LucideIcons.dollarSign,
              label: 'Budget prévu',
              value: onFormatMad(task.budgetPrevu)),
        ),
        // Coût réel
        Expanded(
          flex: 2,
          child: _Col(
              icon: LucideIcons.trendingUp,
              label: 'Coût réel',
              value: task.coutReel > 0
                  ? onFormatMad(task.coutReel)
                  : '—'),
        ),
        // Progress
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${(task.progress * 100).toInt()}%',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: kTextMain)),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: task.progress,
                  minHeight: 5,
                  backgroundColor: const Color(0xFFE5E7EB),
                  valueColor: AlwaysStoppedAnimation<Color>(
                      task.statusColor),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(task.titre,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: kTextMain)),
            ),
            Text('${(task.progress * 100).toInt()}%',
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: kTextMain,
                    fontSize: 14)),
          ],
        ),
        const SizedBox(height: 6),
        _TaskBadge(task: task),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: task.progress,
            minHeight: 6,
            backgroundColor: const Color(0xFFE5E7EB),
            valueColor:
                AlwaysStoppedAnimation<Color>(task.statusColor),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.calendar_today_rounded,
                size: 12, color: kTextSub),
            const SizedBox(width: 4),
            Text('${task.dateDebut} — ${task.dateFin}',
                style: const TextStyle(
                    color: kTextSub, fontSize: 11)),
            const SizedBox(width: 12),
            const Icon(Icons.attach_money_rounded,
                size: 12, color: kTextSub),
            const SizedBox(width: 2),
            Text(onFormatMad(task.budgetPrevu),
                style: const TextStyle(
                    color: kTextSub, fontSize: 11)),
          ],
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  GANTT VIEW
// ══════════════════════════════════════════════════════════════════════════════
class _GanttView extends StatefulWidget {
  final List<Phase> phases;
  const _GanttView({required this.phases});

  @override
  State<_GanttView> createState() => _GanttViewState();
}

class _GanttViewState extends State<_GanttView> {
  final ScrollController _headerScroll = ScrollController();
  final ScrollController _bodyScroll   = ScrollController();

  static const _months = [
    'Janv','Févr','Mars','Avr','Mai','Juin',
    'Juil','Août','Sept','Oct','Nov','Déc',
  ];

  List<({Task task, String phaseName, Color phaseColor})> get _allTasks {
    final colors = [kAccent, const Color(0xFF3B82F6), const Color(0xFF10B981)];
    final result = <({Task task, String phaseName, Color phaseColor})>[];
    for (int i = 0; i < widget.phases.length; i++) {
      for (final t in widget.phases[i].taches) {
        result.add((
          task: t,
          phaseName: widget.phases[i].titre,
          phaseColor: colors[i % colors.length],
        ));
      }
    }
    return result;
  }

  (int, int) _range(Task t) {
    final map = {
      'janv':0,'févr':1,'mars':2,'avr':3,'mai':4,'juin':5,
      'juil':6,'août':7,'sept':8,'oct':9,'nov':10,'déc':11,
    };
    int s = 0, e = 1;
    for (final entry in map.entries) {
      if (t.dateDebut.toLowerCase().contains(entry.key)) s = entry.value;
      if (t.dateFin.toLowerCase().contains(entry.key))   e = entry.value;
    }
    if (e < s) e = s;
    return (s, e);
  }

  @override
  void initState() {
    super.initState();
    _headerScroll.addListener(() {
      if (_bodyScroll.hasClients && _bodyScroll.offset != _headerScroll.offset) {
        _bodyScroll.jumpTo(_headerScroll.offset);
      }
    });
    _bodyScroll.addListener(() {
      if (_headerScroll.hasClients && _headerScroll.offset != _bodyScroll.offset) {
        _headerScroll.jumpTo(_bodyScroll.offset);
      }
    });
  }

  @override
  void dispose() {
    _headerScroll.dispose();
    _bodyScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const taskColW = 160.0;
    const cellW    = 70.0;
    const totalW   = 12 * cellW;
    final tasks    = _allTasks;

    return Container(
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // Header mois
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1F2937),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                const SizedBox(
                  width: taskColW,
                  child: Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Text('Tâche',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _headerScroll,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: totalW,
                      child: Row(
                        children: _months
                            .map((m) => SizedBox(
                                  width: cellW,
                                  child: Text(m,
                                      style: const TextStyle(
                                          color: Colors.white54,
                                          fontSize: 11)),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Lignes
          ...tasks.map((item) {
            final (start, end) = _range(item.task);
            final barLeft  = start * cellW;
            final barWidth = (end - start + 1) * cellW;
            final progress = item.task.progress;
            final color    = item.task.statusColor;

            return Container(
              decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: Color(0xFFF3F4F6)))),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: taskColW,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.task.titre,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: kTextMain),
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 3),
                          Text(item.phaseName,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: item.phaseColor,
                                  fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 3),
                          _TaskBadge(task: item.task),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _bodyScroll,
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: totalW,
                        height: 60,
                        child: Stack(
                          children: [
                            ...List.generate(
                              12,
                              (i) => Positioned(
                                left: i * cellW,
                                top: 0,
                                bottom: 0,
                                child: Container(
                                    width: 1,
                                    color: const Color(0xFFF3F4F6)),
                              ),
                            ),
                            Positioned(
                              left: barLeft,
                              top: 20,
                              width: barWidth,
                              height: 20,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5E7EB),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                            if (progress > 0)
                              Positioned(
                                left: barLeft,
                                top: 20,
                                width: barWidth * progress,
                                height: 20,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  alignment: Alignment.center,
                                  child: progress > 0.15
                                      ? Text(
                                          '${(progress * 100).toInt()}%',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700),
                                        )
                                      : null,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          // Légende
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: Wrap(
              spacing: 16,
              runSpacing: 6,
              children: [
                _GanttLegend(color: const Color(0xFF374151), label: 'Terminé'),
                _GanttLegend(color: kAccent, label: 'En cours'),
                _GanttLegend(color: const Color(0xFF9CA3AF), label: 'Planifié'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GanttLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _GanttLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(color: kTextSub, fontSize: 11)),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  HELPER WIDGETS
// ══════════════════════════════════════════════════════════════════════════════

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700)),
    );
  }
}

class _AccessToggle extends StatefulWidget {
  @override
  State<_AccessToggle> createState() => _AccessToggleState();
}

class _AccessToggleState extends State<_AccessToggle> {
  bool _value = true;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
              value: _value,
              onChanged: (v) => setState(() => _value = v),
              activeThumbColor: kAccent),
          const Text('Accès Portail Client',
              style: TextStyle(color: kTextSub, fontSize: 12)),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoCard(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: kTextSub),
              const SizedBox(width: 6),
              Text(label,
                  style: const TextStyle(color: kTextSub, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: kTextMain)),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: kBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: kTextSub),
          const SizedBox(width: 5),
          Text(text,
              style: const TextStyle(color: kTextSub, fontSize: 11)),
        ],
      ),
    );
  }
}

class _ViewToggleBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _ViewToggleBtn({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: active ? kAccent : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: active ? kAccent : const Color(0xFFE5E7EB)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14, color: active ? Colors.white : kTextSub),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    color: active ? Colors.white : kTextSub,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _TaskBadge extends StatelessWidget {
  final Task task;
  const _TaskBadge({required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: task.statusColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(task.statusLabel,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700)),
    );
  }
}

class _Col extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _Col(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: kTextSub),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(color: kTextSub, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: kTextMain,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}