import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/colors.dart';
import '../models/project.dart';
import '../models/tache.dart';
import '../models/document.dart';
import '../models/facture.dart';
import '../models/commentaire.dart';
import '../models/membre.dart';
import '../service/tache_service.dart';
import '../service/document_service.dart';
import '../service/facture_service.dart';
import '../service/commentaire_service.dart';
import '../service/project_member_service.dart';

class ProjetDetailScreen extends StatefulWidget {
  final Project project;
  final int projectIndex;
  const ProjetDetailScreen({super.key, required this.project, required this.projectIndex});
  @override
  State<ProjetDetailScreen> createState() => _ProjetDetailScreenState();
}

class _ProjetDetailScreenState extends State<ProjetDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  static const _tabs = ['Tâches', 'Finances', 'Documents', 'Équipe', 'Commentaires'];

  Color get _statusColor {
    switch (widget.project.statut) {
      case 'en_cours': return kAccent;
      case 'termine':  return const Color(0xFF10B981);
      case 'annule':   return kRed;
      default:         return const Color(0xFF9CA3AF);
    }
  }

  String _fmt(double v) {
    if (v == 0) return '0 DT';
    final s = v.toInt().toString();
    final buf = StringBuffer();
    int c = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (c > 0 && c % 3 == 0) buf.write('.');
      buf.write(s[i]);
      c++;
    }
    return '${buf.toString().split('').reversed.join()} DT';
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final pad = isMobile ? 16.0 : 28.0;
    final p = widget.project;

    return Scaffold(
      backgroundColor: kBg,
      body: Column(children: [
        Material(
          color: kCardBg, elevation: 0,
          child: Padding(
            padding: EdgeInsets.fromLTRB(pad, 16, pad, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.arrow_back_ios_rounded, size: 14, color: kTextSub),
                  SizedBox(width: 4),
                  Text('Retour aux projets', style: TextStyle(color: kTextSub, fontSize: 13)),
                ]),
              ),
              const SizedBox(height: 14),
              isMobile ? _buildMobileHeader(p) : _buildDesktopHeader(p),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Progression globale', style: TextStyle(color: kTextSub, fontSize: 13, fontWeight: FontWeight.w500)),
                Text('${p.avancement}%', style: const TextStyle(fontWeight: FontWeight.w700, color: kTextMain, fontSize: 13)),
              ]),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: p.progress, minHeight: 8,
                  backgroundColor: const Color(0xFFE5E7EB),
                  valueColor: AlwaysStoppedAnimation<Color>(_statusColor),
                ),
              ),
              const SizedBox(height: 16),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: kTextMain,
                unselectedLabelColor: kTextSub,
                labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                unselectedLabelStyle: const TextStyle(fontSize: 13),
                indicatorColor: kAccent,
                indicatorWeight: 3,
                dividerColor: const Color(0xFFE5E7EB),
                tabs: _tabs.map((t) => Tab(text: t)).toList(),
              ),
            ]),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _TachesTab(project: widget.project),
              _FinancesTab(project: widget.project, fmt: _fmt),
              _DocumentsTab(project: widget.project),
              _EquipeTab(project: widget.project),
              _CommentairesTab(project: widget.project),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildDesktopHeader(Project p) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Expanded(child: Row(children: [
        Flexible(child: Text(p.titre, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: kTextMain))),
        const SizedBox(width: 12),
        _StatusBadge(label: p.status, color: _statusColor),
      ])),
      Material(color: Colors.transparent, child: Row(children: [
        _AccessToggle(),
        const SizedBox(width: 12),
        ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF374151), elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Terminer le projet', style: TextStyle(color: Colors.white, fontSize: 13))),
        const SizedBox(width: 8),
        OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(side: const BorderSide(color: kRed), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Annuler', style: TextStyle(color: kRed, fontSize: 13))),
      ])),
    ]),
    const SizedBox(height: 6),
    Text('Client : ${p.client}', style: const TextStyle(color: kTextSub, fontSize: 13)),
    const SizedBox(height: 16),
    IntrinsicHeight(child: Row(children: [
      Expanded(child: _InfoCard(icon: LucideIcons.mapPin,     label: 'Localisation',    value: p.localisation.isEmpty ? '—' : p.localisation)),
      const SizedBox(width: 12),
      Expanded(child: _InfoCard(icon: LucideIcons.calendar,   label: 'Période',         value: '${p.dateDebut ?? "—"} → ${p.dateFin ?? "—"}')),
      const SizedBox(width: 12),
      Expanded(child: _InfoCard(icon: LucideIcons.user,       label: 'Chef de projet',  value: p.chef.isEmpty ? '—' : p.chef)),
      const SizedBox(width: 12),
      Expanded(child: _InfoCard(icon: LucideIcons.dollarSign, label: 'Budget consommé', value: '${_fmt(p.budgetDepense)} / ${_fmt(p.budgetTotal)}')),
    ])),
  ]);

  Widget _buildMobileHeader(Project p) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      Expanded(child: Text(p.titre, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kTextMain))),
      _StatusBadge(label: p.status, color: _statusColor),
    ]),
    const SizedBox(height: 4),
    Text('Client : ${p.client}', style: const TextStyle(color: kTextSub, fontSize: 12)),
    const SizedBox(height: 10),
    SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
      _InfoChip(icon: LucideIcons.mapPin,     text: p.localisation.isEmpty ? '—' : p.localisation),
      const SizedBox(width: 8),
      _InfoChip(icon: LucideIcons.user,       text: p.chef.isEmpty ? '—' : p.chef),
      const SizedBox(width: 8),
      _InfoChip(icon: LucideIcons.dollarSign, text: '${_fmt(p.budgetDepense)} / ${_fmt(p.budgetTotal)}'),
    ])),
    const SizedBox(height: 10),
    Material(color: Colors.transparent, child: Row(children: [
      _AccessToggle(), const Spacer(),
      OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(side: const BorderSide(color: kRed), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Annuler', style: TextStyle(color: kRed, fontSize: 12))),
      const SizedBox(width: 8),
      ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF374151), elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Terminer', style: TextStyle(color: Colors.white, fontSize: 12))),
    ])),
  ]);
}

// ══════════════════════════════════════════════════════════════════════════════
//  ONGLET TÂCHES — COMPLET
// ══════════════════════════════════════════════════════════════════════════════
class _TachesTab extends StatefulWidget {
  final Project project;
  const _TachesTab({required this.project});
  @override State<_TachesTab> createState() => _TachesTabState();
}

class _TachesTabState extends State<_TachesTab> {
  List<Tache> taches = [];
  bool loading = true;
  bool _showGantt = false;
  String _filterStatut = 'tous';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final data = await TacheService.getTaches(widget.project.id);
      setState(() { taches = data; loading = false; });
    } catch (e) { setState(() => loading = false); }
  }

  // ── Calculs progression ───────────────────────────────────────────────────
  int get _total     => taches.length;
  int get _terminees => taches.where((t) => t.statut == 'termine').length;
  int get _enCours   => taches.where((t) => t.statut == 'en_cours').length;
  int get _enAttente => taches.where((t) => t.statut == 'en_attente').length;
  double get _progression => _total == 0 ? 0 : _terminees / _total;

  List<Tache> get _filtered {
    if (_filterStatut == 'tous') return taches;
    return taches.where((t) => t.statut == _filterStatut).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final pad = isMobile ? 16.0 : 28.0;
    if (loading) return const Center(child: CircularProgressIndicator(color: kAccent));

    return SingleChildScrollView(
      padding: EdgeInsets.all(pad),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Header ──────────────────────────────────────────────────────────
        Row(children: [
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Planning & Tâches', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kTextMain)),
            SizedBox(height: 2),
            Text('Gérez et suivez l\'avancement de chaque tâche', style: TextStyle(color: kTextSub, fontSize: 12)),
          ])),
          // Toggle liste/gantt
          Container(
            decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              _ViewToggleBtn(label: 'Liste', icon: LucideIcons.list,      active: !_showGantt, onTap: () => setState(() => _showGantt = false)),
              _ViewToggleBtn(label: 'Gantt', icon: LucideIcons.barChart2, active: _showGantt,  onTap: () => setState(() => _showGantt = true)),
            ]),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            onPressed: () => _showAddTacheDialog(context),
            icon: const Icon(LucideIcons.plus, size: 14, color: Colors.white),
            label: Text(isMobile ? '' : 'Nouvelle tâche', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
            style: ElevatedButton.styleFrom(backgroundColor: kAccent, elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          ),
        ]),

        const SizedBox(height: 20),

        // ── Carte progression ────────────────────────────────────────────────
        _ProgressionCard(
          total: _total, terminees: _terminees,
          enCours: _enCours, enAttente: _enAttente,
          progression: _progression,
        ),

        const SizedBox(height: 20),

        // ── KPI cards ────────────────────────────────────────────────────────
        IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(child: _KpiCard(label: 'Total',      value: '$_total',     color: kAccent,                  icon: LucideIcons.listChecks)),
          const SizedBox(width: 10),
          Expanded(child: _KpiCard(label: 'En cours',   value: '$_enCours',   color: const Color(0xFF3B82F6),  icon: LucideIcons.activity)),
          const SizedBox(width: 10),
          Expanded(child: _KpiCard(label: 'Terminées',  value: '$_terminees', color: const Color(0xFF10B981),  icon: LucideIcons.checkCircle)),
          const SizedBox(width: 10),
          Expanded(child: _KpiCard(label: 'Planifiées', value: '$_enAttente', color: const Color(0xFF9CA3AF),  icon: LucideIcons.clock)),
        ])),

        const SizedBox(height: 20),

        if (taches.isEmpty)
          _EmptyState(icon: LucideIcons.listChecks, message: 'Aucune tâche — commencez par en créer une')
        else if (_showGantt)
          _GanttView(taches: taches)
        else ...[
          // ── Filtres ──────────────────────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              for (final f in ['tous', 'en_attente', 'en_cours', 'termine'])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _filterStatut = f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: _filterStatut == f ? _filterColor(f) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _filterStatut == f ? _filterColor(f) : const Color(0xFFE5E7EB)),
                      ),
                      child: Text(_filterLabel(f),
                          style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600,
                            color: _filterStatut == f ? Colors.white : kTextSub,
                          )),
                    ),
                  ),
                ),
            ]),
          ),
          const SizedBox(height: 14),

          // ── Liste tâches ─────────────────────────────────────────────────
          if (_filtered.isEmpty)
            _EmptyState(icon: LucideIcons.filter, message: 'Aucune tâche pour ce filtre')
          else
            ...List.generate(_filtered.length, (i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _TacheCard(
                tache: _filtered[i],
                index: i + 1,
                onStatusChanged: (s) async { await TacheService.updateStatut(_filtered[i].id, s); _load(); },
                onDelete: () async { await TacheService.deleteTache(_filtered[i].id); _load(); },
                onEdit: () => _showEditTacheDialog(context, _filtered[i]),
                onView: () => _showViewTacheDialog(context, _filtered[i]),
              ),
            )),
        ],
      ]),
    );
  }

  // ── Dialog Ajouter ──────────────────────────────────────────────────────────
  void _showAddTacheDialog(BuildContext context) {
    final titreCtrl  = TextEditingController();
    final descCtrl   = TextEditingController();
    final debutCtrl  = TextEditingController();
    final finCtrl    = TextEditingController();
    final budgetCtrl = TextEditingController();
    String statut = 'en_attente';

    showDialog(context: context, builder: (_) => StatefulBuilder(builder: (ctx, sd) {
      return _TacheDialog(
        title: 'Nouvelle tâche', subtitle: 'Ajoutez une tâche au projet',
        icon: LucideIcons.listPlus, btnLabel: 'Ajouter',
        titreCtrl: titreCtrl, descCtrl: descCtrl,
        debutCtrl: debutCtrl, finCtrl: finCtrl, budgetCtrl: budgetCtrl,
        statut: statut, onStatutChanged: (s) => sd(() => statut = s),
        onCancel: () => Navigator.pop(ctx),
        onConfirm: () async {
          if (titreCtrl.text.trim().isEmpty) { _snack(ctx, 'Titre obligatoire', kRed); return; }
          await TacheService.addTache(Tache(
            id: '', projetId: widget.project.id,
            titre: titreCtrl.text.trim(), description: descCtrl.text.trim(),
            statut: statut,
            dateDebut: debutCtrl.text.trim().isEmpty ? null : debutCtrl.text.trim(),
            dateFin:   finCtrl.text.trim().isEmpty   ? null : finCtrl.text.trim(),
            budgetEstime: double.tryParse(budgetCtrl.text.replaceAll(' ', '')) ?? 0,
          ));
          Navigator.pop(ctx); _load();
          _snack(context, 'Tâche ajoutée avec succès', kAccent);
        },
      );
    }));
  }

  // ── Dialog Modifier ─────────────────────────────────────────────────────────
  void _showEditTacheDialog(BuildContext context, Tache t) {
    final titreCtrl  = TextEditingController(text: t.titre);
    final descCtrl   = TextEditingController(text: t.description);
    final debutCtrl  = TextEditingController(text: t.dateDebut ?? '');
    final finCtrl    = TextEditingController(text: t.dateFin ?? '');
    final budgetCtrl = TextEditingController(text: t.budgetEstime > 0 ? t.budgetEstime.toInt().toString() : '');
    String statut = t.statut;

    showDialog(context: context, builder: (_) => StatefulBuilder(builder: (ctx, sd) {
      return _TacheDialog(
        title: 'Modifier la tâche', subtitle: 'Mettez à jour les informations',
        icon: LucideIcons.pencil, btnLabel: 'Enregistrer',
        titreCtrl: titreCtrl, descCtrl: descCtrl,
        debutCtrl: debutCtrl, finCtrl: finCtrl, budgetCtrl: budgetCtrl,
        statut: statut, onStatutChanged: (s) => sd(() => statut = s),
        onCancel: () => Navigator.pop(ctx),
        onConfirm: () async {
          if (titreCtrl.text.trim().isEmpty) { _snack(ctx, 'Titre obligatoire', kRed); return; }
          await TacheService.updateTache(Tache(
            id: t.id, projetId: t.projetId,
            titre: titreCtrl.text.trim(), description: descCtrl.text.trim(),
            statut: statut,
            dateDebut: debutCtrl.text.trim().isEmpty ? null : debutCtrl.text.trim(),
            dateFin:   finCtrl.text.trim().isEmpty   ? null : finCtrl.text.trim(),
            budgetEstime: double.tryParse(budgetCtrl.text.replaceAll(' ', '')) ?? 0,
            createdAt: t.createdAt,
          ));
          Navigator.pop(ctx); _load();
          _snack(context, 'Tâche modifiée avec succès', kAccent);
        },
      );
    }));
  }

  // ── Dialog Consulter ────────────────────────────────────────────────────────
  void _showViewTacheDialog(BuildContext context, Tache t) {
    final color = _tacheColor(t.statut);
    showDialog(context: context, builder: (_) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 440),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Header coloré
          Container(
            decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Row(children: [
              Container(width: 44, height: 44, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: const Icon(LucideIcons.checkSquare, color: Colors.white, size: 22)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t.titre, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white)),
                const SizedBox(height: 4),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(10)),
                    child: Text(t.statutLabel, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
              ])),
            ]),
          ),
          // Détails
          Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (t.description.isNotEmpty) ...[
              const Text('Description', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kTextSub)),
              const SizedBox(height: 6),
              Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE5E7EB))),
                  child: Text(t.description, style: const TextStyle(fontSize: 13, color: kTextMain))),
              const SizedBox(height: 14),
            ],
            Row(children: [
              Expanded(child: _ViewInfoTile(icon: LucideIcons.calendarDays,  label: 'Début',  value: t.dateDebut ?? '—')),
              const SizedBox(width: 10),
              Expanded(child: _ViewInfoTile(icon: LucideIcons.calendarCheck, label: 'Fin',    value: t.dateFin ?? '—')),
            ]),
            const SizedBox(height: 10),
            _ViewInfoTile(icon: LucideIcons.banknote, label: 'Budget estimé', value: t.budgetEstime > 0 ? _fmtNum(t.budgetEstime) : '—'),
            if (t.createdAt.isNotEmpty) ...[
              const SizedBox(height: 10),
              _ViewInfoTile(icon: LucideIcons.clock, label: 'Créée le', value: t.createdAt.length > 10 ? t.createdAt.substring(0, 10) : t.createdAt),
            ],
          ])),
          Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 20), child: SizedBox(width: double.infinity,
            child: ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: color, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: const Text('Fermer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
          )),
        ]),
      ),
    ));
  }
}

// ── Carte de progression ───────────────────────────────────────────────────────
class _ProgressionCard extends StatelessWidget {
  final int total, terminees, enCours, enAttente;
  final double progression;
  const _ProgressionCard({required this.total, required this.terminees, required this.enCours, required this.enAttente, required this.progression});

  @override
  Widget build(BuildContext context) {
    final pct = (progression * 100).round();
    Color barColor = kAccent;
    if (pct == 100) barColor = const Color(0xFF10B981);
    else if (pct >= 70) barColor = const Color(0xFF3B82F6);
    else if (pct >= 40) barColor = kAccent;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [barColor.withOpacity(0.08), barColor.withOpacity(0.03)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: barColor.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: barColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)), child: Icon(LucideIcons.target, color: barColor, size: 18)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Progression des tâches', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: kTextMain)),
            Text(total == 0 ? 'Aucune tâche' : '$terminees tâche(s) terminée(s) sur $total', style: const TextStyle(color: kTextSub, fontSize: 12)),
          ])),
          Text('$pct%', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: barColor)),
        ]),
        const SizedBox(height: 14),
        ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(
          value: progression, minHeight: 10,
          backgroundColor: barColor.withOpacity(0.15),
          valueColor: AlwaysStoppedAnimation<Color>(barColor),
        )),
        const SizedBox(height: 12),
        // Mini légende
        Row(children: [
          _LegendDot(color: const Color(0xFF10B981), label: 'Terminées ($terminees)'),
          const SizedBox(width: 16),
          _LegendDot(color: const Color(0xFF3B82F6), label: 'En cours ($enCours)'),
          const SizedBox(width: 16),
          _LegendDot(color: const Color(0xFF9CA3AF), label: 'Planifiées ($enAttente)'),
        ]),
      ]),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color; final String label;
  const _LegendDot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 5),
    Text(label, style: const TextStyle(fontSize: 11, color: kTextSub)),
  ]);
}

// ── Carte tâche avec actions ──────────────────────────────────────────────────
class _TacheCard extends StatelessWidget {
  final Tache tache;
  final int index;
  final ValueChanged<String> onStatusChanged;
  final VoidCallback onDelete, onEdit, onView;
  const _TacheCard({required this.tache, required this.index, required this.onStatusChanged, required this.onDelete, required this.onEdit, required this.onView});

  @override
  Widget build(BuildContext context) {
    final color = _tacheColor(tache.statut);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBg, borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          // Numéro
          Container(width: 26, height: 26, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
              child: Center(child: Text('$index', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)))),
          const SizedBox(width: 10),
          Expanded(child: Text(tache.titre, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: kTextMain))),
          // Status dropdown
          Material(color: Colors.transparent, child: PopupMenuButton<String>(
            onSelected: onStatusChanged,
            itemBuilder: (_) => [
              for (final s in ['en_attente', 'en_cours', 'termine'])
                PopupMenuItem(value: s, child: Row(children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: _tacheColor(s), shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text(_tacheLabel(s), style: const TextStyle(fontSize: 13)),
                ])),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text(tache.statutLabel, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
                const SizedBox(width: 4),
                Icon(LucideIcons.chevronsUpDown, size: 11, color: color),
              ]),
            ),
          )),
          const SizedBox(width: 4),
          // Actions
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'view')   onView();
              if (v == 'edit')   onEdit();
              if (v == 'delete') onDelete();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'view',   child: Row(children: [Icon(LucideIcons.eye,    size: 15, color: kTextSub), SizedBox(width: 8), Text('Consulter')])),
              const PopupMenuItem(value: 'edit',   child: Row(children: [Icon(LucideIcons.pencil, size: 15, color: kAccent),  SizedBox(width: 8), Text('Modifier')])),
              const PopupMenuItem(value: 'delete', child: Row(children: [Icon(LucideIcons.trash2, size: 15, color: kRed),     SizedBox(width: 8), Text('Supprimer', style: TextStyle(color: kRed))])),
            ],
            child: const Padding(padding: EdgeInsets.all(4), child: Icon(LucideIcons.moreVertical, size: 16, color: kTextSub)),
          ),
        ]),
        if (tache.description.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(tache.description, style: const TextStyle(color: kTextSub, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
        const SizedBox(height: 10),
        Wrap(spacing: 16, runSpacing: 4, children: [
          if (tache.dateDebut != null) _TacheChip(icon: LucideIcons.calendarDays,  text: tache.dateDebut!),
          if (tache.dateFin   != null) _TacheChip(icon: LucideIcons.calendarCheck, text: tache.dateFin!),
          if (tache.budgetEstime > 0)  _TacheChip(icon: LucideIcons.banknote,      text: _fmtNum(tache.budgetEstime)),
        ]),
      ]),
    );
  }
}

// ── Vue Gantt ─────────────────────────────────────────────────────────────────
class _GanttView extends StatelessWidget {
  final List<Tache> taches;
  const _GanttView({required this.taches});

  @override
  Widget build(BuildContext context) {
    // Tâches avec dates seulement
    final withDates = taches.where((t) => t.dateDebut != null && t.dateFin != null).toList();
    final withoutDates = taches.where((t) => t.dateDebut == null || t.dateFin == null).toList();

    if (withDates.isEmpty) return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: kCardBg, borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        const Icon(LucideIcons.calendarOff, size: 36, color: kTextSub),
        const SizedBox(height: 12),
        const Text('Aucune tâche avec des dates définies', style: TextStyle(color: kTextSub, fontSize: 14)),
        const SizedBox(height: 6),
        const Text('Ajoutez des dates de début et fin à vos tâches pour afficher le Gantt', style: TextStyle(color: kTextSub, fontSize: 12), textAlign: TextAlign.center),
      ]),
    );

    // Calcul période globale
    DateTime? minDate, maxDate;
    for (final t in withDates) {
      final debut = DateTime.tryParse(t.dateDebut!);
      final fin   = DateTime.tryParse(t.dateFin!);
      if (debut != null) { minDate = minDate == null ? debut : (debut.isBefore(minDate) ? debut : minDate); }
      if (fin   != null) { maxDate = maxDate == null ? fin   : (fin.isAfter(maxDate)    ? fin   : maxDate); }
    }
    if (minDate == null || maxDate == null) return const SizedBox();

    final totalDays = maxDate.difference(minDate).inDays + 1;

    return Container(
      decoration: BoxDecoration(color: kCardBg, borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // En-tête
        Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 12), child: Row(children: [
          const Icon(LucideIcons.barChart2, size: 16, color: kTextSub),
          const SizedBox(width: 8),
          const Text('Diagramme de Gantt', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: kTextMain)),
          const Spacer(),
          Text('${totalDays}j', style: const TextStyle(color: kTextSub, fontSize: 12)),
        ])),
        const Divider(height: 1, color: Color(0xFFF3F4F6)),

        // En-tête colonnes
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(children: [
            const SizedBox(width: 140, child: Text('Tâche', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kTextSub))),
            const Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Début', style: TextStyle(fontSize: 11, color: kTextSub)),
              Text('Fin', style: TextStyle(fontSize: 11, color: kTextSub)),
            ])),
          ]),
        ),

        // Lignes Gantt
        ...withDates.map((t) {
          final debut = DateTime.tryParse(t.dateDebut!)!;
          final fin   = DateTime.tryParse(t.dateFin!)!;
          final startPct = debut.difference(minDate!).inDays / totalDays;
          final widthPct = (fin.difference(debut).inDays + 1) / totalDays;
          final color = _tacheColor(t.statut);

          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(children: [
              SizedBox(width: 140, child: Row(children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Expanded(child: Text(t.titre, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: kTextMain), overflow: TextOverflow.ellipsis)),
              ])),
              Expanded(child: Container(
                height: 28,
                decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(4)),
                child: LayoutBuilder(builder: (ctx, constraints) {
                  final totalWidth = constraints.maxWidth;
                  final barLeft  = (startPct * totalWidth).clamp(0.0, totalWidth);
                  final barWidth = (widthPct * totalWidth).clamp(8.0, totalWidth - barLeft);
                  return Stack(children: [
                    // Grilles verticales
                    ...List.generate(4, (i) => Positioned(
                      left: (i + 1) * totalWidth / 5,
                      top: 0, bottom: 0,
                      child: Container(width: 0.5, color: const Color(0xFFE5E7EB)),
                    )),
                    // Barre
                    Positioned(
                      left: barLeft, top: 4, bottom: 4, width: barWidth,
                      child: Container(
                        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
                        child: Center(child: FittedBox(fit: BoxFit.scaleDown, child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(t.statutLabel, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                        ))),
                      ),
                    ),
                  ]);
                }),
              )),
            ]),
          );
        }),

        // Tâches sans dates
        if (withoutDates.isNotEmpty) ...[
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          Padding(padding: const EdgeInsets.fromLTRB(16, 10, 16, 6), child: Row(children: [
            const Icon(LucideIcons.alertCircle, size: 13, color: kTextSub),
            const SizedBox(width: 6),
            Text('${withoutDates.length} tâche(s) sans dates — non affichées', style: const TextStyle(color: kTextSub, fontSize: 12)),
          ])),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Wrap(spacing: 8, runSpacing: 6, children: withoutDates.map((t) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(20)),
              child: Text(t.titre, style: const TextStyle(fontSize: 11, color: kTextSub)),
            )).toList()),
          ),
        ],
        const SizedBox(height: 4),
      ]),
    );
  }
}

// ── Dialog mutualisé Tâche ────────────────────────────────────────────────────
class _TacheDialog extends StatelessWidget {
  final String title, subtitle, btnLabel;
  final IconData icon;
  final TextEditingController titreCtrl, descCtrl, debutCtrl, finCtrl, budgetCtrl;
  final String statut;
  final ValueChanged<String> onStatutChanged;
  final VoidCallback onCancel, onConfirm;

  const _TacheDialog({
    required this.title, required this.subtitle, required this.btnLabel, required this.icon,
    required this.titreCtrl, required this.descCtrl, required this.debutCtrl,
    required this.finCtrl, required this.budgetCtrl,
    required this.statut, required this.onStatutChanged,
    required this.onCancel, required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) => Dialog(
    insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 480),
      child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        _DialogHeader(icon: icon, title: title, subtitle: subtitle),
        Padding(padding: const EdgeInsets.all(20), child: Column(children: [
          _DField(icon: LucideIcons.checkSquare, label: 'TITRE *',    hint: 'Ex: Fondations', controller: titreCtrl),
          const SizedBox(height: 12),
          _DField(icon: LucideIcons.fileText,    label: 'DESCRIPTION', hint: 'Détails de la tâche...', controller: descCtrl, maxLines: 2),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _DField(icon: LucideIcons.calendar, label: 'DATE DÉBUT', hint: '2025-01-15', controller: debutCtrl)),
            const SizedBox(width: 12),
            Expanded(child: _DField(icon: LucideIcons.calendar, label: 'DATE FIN',   hint: '2025-02-28', controller: finCtrl)),
          ]),
          const SizedBox(height: 12),
          _DField(icon: LucideIcons.banknote, label: 'BUDGET ESTIMÉ (DT)', hint: '50000', controller: budgetCtrl, keyboardType: TextInputType.number),
          const SizedBox(height: 14),
          const Align(alignment: Alignment.centerLeft, child: Text('STATUT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kTextSub, letterSpacing: 0.5))),
          const SizedBox(height: 8),
          Row(children: [
            for (final s in ['en_attente', 'en_cours', 'termine'])
              Expanded(child: Padding(
                padding: EdgeInsets.only(right: s == 'termine' ? 0 : 8),
                child: GestureDetector(onTap: () => onStatutChanged(s), child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: statut == s ? _tacheColor(s).withOpacity(0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: statut == s ? _tacheColor(s) : const Color(0xFFE5E7EB), width: statut == s ? 2 : 1),
                  ),
                  child: Text(_tacheLabel(s), textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, fontWeight: statut == s ? FontWeight.w700 : FontWeight.w500, color: statut == s ? _tacheColor(s) : kTextSub)),
                )),
              )),
          ]),
        ])),
        _DialogActions(onCancel: onCancel, onConfirm: onConfirm, label: btnLabel),
      ])),
    ),
  );
}

// ── Widget info pour dialog consulter ────────────────────────────────────────
class _ViewInfoTile extends StatelessWidget {
  final IconData icon; final String label, value;
  const _ViewInfoTile({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE5E7EB))),
    child: Row(children: [
      Icon(icon, size: 14, color: kTextSub),
      const SizedBox(width: 8),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 10, color: kTextSub)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kTextMain)),
      ]),
    ]),
  );
}

// ── Toggle vue ────────────────────────────────────────────────────────────────
class _ViewToggleBtn extends StatelessWidget {
  final String label; final IconData icon; final bool active; final VoidCallback onTap;
  const _ViewToggleBtn({required this.label, required this.icon, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(color: active ? kAccent : Colors.transparent, borderRadius: BorderRadius.circular(6)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: active ? Colors.white : kTextSub),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: active ? Colors.white : kTextSub)),
      ]),
    ),
  );
}

// ── Filtre helpers ────────────────────────────────────────────────────────────
Color _filterColor(String f) {
  switch (f) { case 'en_cours': return const Color(0xFF3B82F6); case 'termine': return const Color(0xFF10B981); case 'en_attente': return const Color(0xFF9CA3AF); default: return kAccent; }
}
String _filterLabel(String f) {
  switch (f) { case 'tous': return 'Tous'; case 'en_cours': return 'En cours'; case 'termine': return 'Terminées'; default: return 'Planifiées'; }
}

// ══════════════════════════════════════════════════════════════════════════════
//  ONGLET FINANCES (inchangé)
// ══════════════════════════════════════════════════════════════════════════════
class _FinancesTab extends StatefulWidget {
  final Project project; final String Function(double) fmt;
  const _FinancesTab({required this.project, required this.fmt});
  @override State<_FinancesTab> createState() => _FinancesTabState();
}
class _FinancesTabState extends State<_FinancesTab> {
  List<Facture> factures = []; bool loading = true;
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    try { final data = await FactureService.getFactures(widget.project.id); setState(() { factures = data; loading = false; }); }
    catch (e) { setState(() => loading = false); }
  }
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final pad = isMobile ? 16.0 : 28.0;
    final p = widget.project;
    final pct = p.budgetTotal > 0 ? p.budgetDepense / p.budgetTotal : 0.0;
    if (loading) return const Center(child: CircularProgressIndicator(color: kAccent));
    return SingleChildScrollView(padding: EdgeInsets.all(pad), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Finances', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kTextMain)), SizedBox(height: 2), Text('Budget, factures et suivi financier', style: TextStyle(color: kTextSub, fontSize: 12))])),
        ElevatedButton.icon(onPressed: () => _showAddFactureDialog(context), icon: const Icon(LucideIcons.plus, size: 14, color: Colors.white), label: const Text('Nouvelle facture', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)), style: ElevatedButton.styleFrom(backgroundColor: kAccent, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))),
      ]),
      const SizedBox(height: 20),
      IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Expanded(child: _KpiCard(label: 'Budget total', value: widget.fmt(p.budgetTotal),   color: kAccent,                 icon: LucideIcons.dollarSign)),
        const SizedBox(width: 10),
        Expanded(child: _KpiCard(label: 'Consommé',     value: widget.fmt(p.budgetDepense), color: const Color(0xFF3B82F6), icon: LucideIcons.trendingUp)),
        const SizedBox(width: 10),
        Expanded(child: _KpiCard(label: 'Restant',      value: widget.fmt(p.budgetTotal - p.budgetDepense), color: const Color(0xFF10B981), icon: LucideIcons.trendingDown)),
        const SizedBox(width: 10),
        Expanded(child: _KpiCard(label: 'Factures',     value: '${factures.length}',        color: const Color(0xFF8B5CF6), icon: LucideIcons.fileText)),
      ])),
      const SizedBox(height: 16),
      _SectionCard(title: 'Utilisation du budget', child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Budget consommé', style: TextStyle(color: kTextSub, fontSize: 13)), Text('${(pct * 100).toStringAsFixed(1)}%', style: TextStyle(color: pct > 0.9 ? kRed : kTextMain, fontWeight: FontWeight.w700, fontSize: 13))]),
        const SizedBox(height: 8),
        ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: pct.clamp(0.0, 1.0), minHeight: 10, backgroundColor: const Color(0xFFE5E7EB), valueColor: AlwaysStoppedAnimation<Color>(pct > 0.9 ? kRed : kAccent))),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(widget.fmt(p.budgetDepense), style: const TextStyle(color: kTextSub, fontSize: 11)), Text(widget.fmt(p.budgetTotal), style: const TextStyle(color: kTextSub, fontSize: 11))]),
      ])),
      const SizedBox(height: 16),
      _SectionCard(title: 'Factures (${factures.length})', child: factures.isEmpty ? _EmptyState(icon: LucideIcons.fileText, message: 'Aucune facture') : Column(children: factures.map((f) => _FactureRow(facture: f, fmt: widget.fmt, onStatusChanged: (s) async { await FactureService.updateStatut(f.id, s); _load(); }, onDelete: () async { await FactureService.deleteFacture(f.id); _load(); })).toList())),
    ]));
  }
  void _showAddFactureDialog(BuildContext context) {
    final numCtrl = TextEditingController(); final montantCtrl = TextEditingController(); final echeanceCtrl = TextEditingController(); String statut = 'en_attente';
    showDialog(context: context, builder: (_) => StatefulBuilder(builder: (ctx, sd) {
      return Dialog(insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420), child: Column(mainAxisSize: MainAxisSize.min, children: [
        _DialogHeader(icon: LucideIcons.filePlus, title: 'Nouvelle facture', subtitle: 'Ajoutez une facture au projet'),
        Padding(padding: const EdgeInsets.all(20), child: Column(children: [
          _DField(icon: LucideIcons.hash, label: 'NUMÉRO *', hint: 'FAC-2025-001', controller: numCtrl),
          const SizedBox(height: 12),
          _DField(icon: LucideIcons.banknote, label: 'MONTANT (DT) *', hint: '150000', controller: montantCtrl, keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          _DField(icon: LucideIcons.calendar, label: "DATE D'ÉCHÉANCE", hint: '2025-03-31', controller: echeanceCtrl),
          const SizedBox(height: 14),
          const Align(alignment: Alignment.centerLeft, child: Text('STATUT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kTextSub, letterSpacing: 0.5))),
          const SizedBox(height: 8),
          Row(children: [for (final s in ['en_attente', 'payee', 'en_retard']) Expanded(child: Padding(padding: EdgeInsets.only(right: s == 'en_retard' ? 0 : 8), child: GestureDetector(onTap: () => sd(() => statut = s), child: AnimatedContainer(duration: const Duration(milliseconds: 150), padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: statut == s ? _factureColor(s).withOpacity(0.1) : Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: statut == s ? _factureColor(s) : const Color(0xFFE5E7EB), width: statut == s ? 2 : 1)), child: Text(_factureLabel(s), textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: statut == s ? FontWeight.w700 : FontWeight.w500, color: statut == s ? _factureColor(s) : kTextSub))))))]),
        ])),
        _DialogActions(onCancel: () => Navigator.pop(ctx), onConfirm: () async {
          if (numCtrl.text.trim().isEmpty || montantCtrl.text.trim().isEmpty) { _snack(ctx, 'Champs obligatoires', kRed); return; }
          final montantVal = double.tryParse(montantCtrl.text.replaceAll(' ', ''));
          if (montantVal == null) { _snack(ctx, 'Montant invalide', kRed); return; }
          if (montantVal <= 0) { _snack(ctx, 'Le montant doit être supérieur à 0', kRed); return; }
          await FactureService.addFacture(Facture(id: '', projetId: widget.project.id, numero: numCtrl.text.trim(), montant: montantVal, statut: statut, dateEcheance: echeanceCtrl.text.trim().isEmpty ? null : echeanceCtrl.text.trim(), createdAt: DateTime.now().toIso8601String()));
          Navigator.pop(ctx); _load(); _snack(context, 'Facture ajoutée', kAccent);
        }, label: 'Ajouter'),
      ])));
    }));
  }
}

class _FactureRow extends StatelessWidget {
  final Facture facture; final String Function(double) fmt; final ValueChanged<String> onStatusChanged; final VoidCallback onDelete;
  const _FactureRow({required this.facture, required this.fmt, required this.onStatusChanged, required this.onDelete});
  @override
  Widget build(BuildContext context) {
    final color = _factureColor(facture.statut);
    return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE5E7EB))), child: Row(children: [
      Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)), child: const Icon(LucideIcons.fileText, color: Color(0xFF3B82F6), size: 18)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(facture.numero, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: kTextMain)), Text(fmt(facture.montant), style: const TextStyle(color: kTextSub, fontSize: 12)), if (facture.dateEcheance != null) Text('Échéance : ${facture.dateEcheance}', style: const TextStyle(color: kTextSub, fontSize: 11))])),
      Material(color: Colors.transparent, child: PopupMenuButton<String>(onSelected: onStatusChanged, itemBuilder: (_) => ['en_attente', 'payee', 'en_retard'].map((s) => PopupMenuItem(value: s, child: Text(_factureLabel(s)))).toList(), child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Text(facture.statutLabel, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700))))),
      const SizedBox(width: 8),
      IconButton(onPressed: onDelete, icon: const Icon(LucideIcons.trash2, size: 15, color: kRed), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
    ]));
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  ONGLETS DOCUMENTS / ÉQUIPE / COMMENTAIRES (identiques à avant)
// ══════════════════════════════════════════════════════════════════════════════
class _DocumentsTab extends StatefulWidget { final Project project; const _DocumentsTab({required this.project}); @override State<_DocumentsTab> createState() => _DocumentsTabState(); }
class _DocumentsTabState extends State<_DocumentsTab> {
  List<Document> documents = []; bool loading = true;
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async { try { final data = await DocumentService.getDocuments(widget.project.id); setState(() { documents = data; loading = false; }); } catch (e) { setState(() => loading = false); } }
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800; final pad = isMobile ? 16.0 : 28.0;
    if (loading) return const Center(child: CircularProgressIndicator(color: kAccent));
    return SingleChildScrollView(padding: EdgeInsets.all(pad), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Documents', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kTextMain)), SizedBox(height: 2), Text('Plans, devis et autres fichiers', style: TextStyle(color: kTextSub, fontSize: 12))])),
        ElevatedButton.icon(onPressed: () => _showAddDocDialog(context), icon: const Icon(LucideIcons.upload, size: 14, color: Colors.white), label: Text(isMobile ? 'Ajouter' : 'Ajouter un document', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)), style: ElevatedButton.styleFrom(backgroundColor: kAccent, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))),
      ]),
      const SizedBox(height: 20),
      if (documents.isEmpty) _EmptyState(icon: LucideIcons.folder, message: 'Aucun document pour ce projet')
      else LayoutBuilder(builder: (ctx, constraints) {
        final cols = constraints.maxWidth > 600 ? 2 : 1;
        final rows = <Widget>[];
        for (int i = 0; i < documents.length; i += cols) {
          final row = documents.skip(i).take(cols).toList();
          rows.add(IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (int j = 0; j < row.length; j++) ...[if (j > 0) const SizedBox(width: 14), Expanded(child: _DocCard(doc: row[j], onDelete: () async { await DocumentService.deleteDocument(row[j].id); _load(); }))], if (row.length < cols) ...[const SizedBox(width: 14), const Expanded(child: SizedBox())]])));
          if (i + cols < documents.length) rows.add(const SizedBox(height: 14));
        }
        return Column(children: rows);
      }),
    ]));
  }
  void _showAddDocDialog(BuildContext context) {
    final nomCtrl = TextEditingController(); final urlCtrl = TextEditingController(); String type = 'pdf';
    showDialog(context: context, builder: (_) => StatefulBuilder(builder: (ctx, sd) {
      return Dialog(insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420), child: Column(mainAxisSize: MainAxisSize.min, children: [
        _DialogHeader(icon: LucideIcons.filePlus2, title: 'Ajouter un document', subtitle: 'Renseignez les informations du fichier'),
        Padding(padding: const EdgeInsets.all(20), child: Column(children: [_DField(icon: LucideIcons.file, label: 'NOM DU FICHIER *', hint: 'Plan architectural V2', controller: nomCtrl), const SizedBox(height: 12), _DField(icon: LucideIcons.link, label: 'URL DU FICHIER *', hint: 'https://...', controller: urlCtrl), const SizedBox(height: 14), const Align(alignment: Alignment.centerLeft, child: Text('TYPE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kTextSub, letterSpacing: 0.5))), const SizedBox(height: 8), Wrap(spacing: 8, children: ['pdf', 'dwg', 'xlsx', 'image', 'autre'].map((t) => GestureDetector(onTap: () => sd(() => type = t), child: AnimatedContainer(duration: const Duration(milliseconds: 150), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: type == t ? kAccent.withOpacity(0.1) : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: type == t ? kAccent : const Color(0xFFE5E7EB), width: type == t ? 2 : 1)), child: Text(t.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: type == t ? FontWeight.w700 : FontWeight.w500, color: type == t ? kAccent : kTextSub))))).toList())])),
        _DialogActions(onCancel: () => Navigator.pop(ctx), onConfirm: () async { if (nomCtrl.text.trim().isEmpty || urlCtrl.text.trim().isEmpty) { _snack(ctx, 'Champs obligatoires', kRed); return; } final url = urlCtrl.text.trim(); if (!url.startsWith('http://') && !url.startsWith('https://')) { _snack(ctx, 'URL invalide', kRed); return; } await DocumentService.addDocument(Document(id: '', projetId: widget.project.id, nom: nomCtrl.text.trim(), url: url, type: type)); Navigator.pop(ctx); _load(); _snack(context, 'Document ajouté', kAccent); }, label: 'Ajouter'),
      ])));
    }));
  }
}

class _DocCard extends StatelessWidget {
  final Document doc; final VoidCallback onDelete;
  const _DocCard({required this.doc, required this.onDelete});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: kCardBg, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)), child: const Icon(LucideIcons.fileText, color: Color(0xFF3B82F6), size: 20)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(doc.nom, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: kTextMain), overflow: TextOverflow.ellipsis), const SizedBox(height: 3), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: kAccent, borderRadius: BorderRadius.circular(20)), child: Text(doc.type.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)))])), IconButton(onPressed: onDelete, icon: const Icon(LucideIcons.trash2, size: 15, color: kRed), padding: EdgeInsets.zero, constraints: const BoxConstraints())]), const SizedBox(height: 12), const Divider(height: 1, color: Color(0xFFF3F4F6)), const SizedBox(height: 10), SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(LucideIcons.externalLink, size: 13, color: kTextSub), label: const Text('Ouvrir', style: TextStyle(color: kTextSub, fontSize: 12)), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8), side: const BorderSide(color: Color(0xFFE5E7EB)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))))]));
}

class _EquipeTab extends StatefulWidget { final Project project; const _EquipeTab({required this.project}); @override State<_EquipeTab> createState() => _EquipeTabState(); }
class _EquipeTabState extends State<_EquipeTab> {
  List<Membre> membres = []; bool loading = true;
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async { try { final data = await ProjectMemberService.getMembres(widget.project.id); setState(() { membres = data; loading = false; }); } catch (e) { setState(() => loading = false); } }
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800; final pad = isMobile ? 16.0 : 28.0;
    if (loading) return const Center(child: CircularProgressIndicator(color: kAccent));
    return SingleChildScrollView(padding: EdgeInsets.all(pad), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Équipe du projet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kTextMain)), const SizedBox(height: 4), Text('Chef de projet : ${widget.project.chef}', style: const TextStyle(color: kTextSub, fontSize: 13)), const SizedBox(height: 20), if (membres.isEmpty) _EmptyState(icon: LucideIcons.users, message: 'Aucun membre assigné à ce projet') else LayoutBuilder(builder: (ctx, constraints) { final cols = constraints.maxWidth > 700 ? 3 : constraints.maxWidth > 450 ? 2 : 1; final rows = <Widget>[]; for (int i = 0; i < membres.length; i += cols) { final row = membres.skip(i).take(cols).toList(); rows.add(IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (int j = 0; j < row.length; j++) ...[if (j > 0) const SizedBox(width: 14), Expanded(child: _MembreCard(membre: row[j]))], if (row.length < cols) ...[const SizedBox(width: 14), const Expanded(child: SizedBox())]]))); if (i + cols < membres.length) rows.add(const SizedBox(height: 14)); } return Column(children: rows); })]));
  }
}

class _MembreCard extends StatelessWidget {
  final Membre membre; const _MembreCard({required this.membre});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: kCardBg, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(22)), child: const Icon(LucideIcons.user, color: Color(0xFF3B82F6), size: 22)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(membre.nom, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: kTextMain), overflow: TextOverflow.ellipsis), const SizedBox(height: 4), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: const Color(0xFF374151), borderRadius: BorderRadius.circular(20)), child: Text(membre.role, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)))]))]), const SizedBox(height: 12), const Divider(height: 1, color: Color(0xFFF3F4F6)), const SizedBox(height: 10), Row(children: [const Icon(LucideIcons.mail, size: 13, color: kTextSub), const SizedBox(width: 6), Expanded(child: Text(membre.email, style: const TextStyle(color: kTextSub, fontSize: 12), overflow: TextOverflow.ellipsis))]), const SizedBox(height: 6), Row(children: [const Icon(LucideIcons.phone, size: 13, color: kTextSub), const SizedBox(width: 6), Text(membre.telephone, style: const TextStyle(color: kTextSub, fontSize: 12))])]));
}

class _CommentairesTab extends StatefulWidget { final Project project; const _CommentairesTab({required this.project}); @override State<_CommentairesTab> createState() => _CommentairesTabState(); }
class _CommentairesTabState extends State<_CommentairesTab> {
  List<Commentaire> commentaires = []; bool loading = true; final _ctrl = TextEditingController(); final _scroll = ScrollController();
  @override void initState() { super.initState(); _load(); }
  @override void dispose() { _ctrl.dispose(); _scroll.dispose(); super.dispose(); }
  Future<void> _load() async { try { final data = await CommentaireService.getCommentaires(widget.project.id); setState(() { commentaires = data; loading = false; }); Future.delayed(const Duration(milliseconds: 100), () { if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent); }); } catch (e) { setState(() => loading = false); } }
  Future<void> _send() async { final text = _ctrl.text.trim(); if (text.isEmpty) { _snack(context, 'Le commentaire ne peut pas être vide', kRed); return; } _ctrl.clear(); await CommentaireService.addCommentaire(Commentaire(id: '', projetId: widget.project.id, auteur: widget.project.chef.isEmpty ? 'Architecte' : widget.project.chef, role: 'architecte', contenu: text, createdAt: DateTime.now().toIso8601String())); _load(); }
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800; final pad = isMobile ? 16.0 : 28.0;
    if (loading) return const Center(child: CircularProgressIndicator(color: kAccent));
    return Padding(padding: EdgeInsets.all(pad), child: Column(children: [Expanded(child: Container(decoration: BoxDecoration(color: kCardBg, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))]), child: Column(children: [Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 10), child: Row(children: [const Icon(LucideIcons.messageSquare, size: 16, color: kTextSub), const SizedBox(width: 8), const Text('Fil de discussion', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: kTextMain)), const Spacer(), Text('${commentaires.length} message(s)', style: const TextStyle(color: kTextSub, fontSize: 12))])), const Divider(height: 1, color: Color(0xFFF3F4F6)), Expanded(child: commentaires.isEmpty ? _EmptyState(icon: LucideIcons.messageCircle, message: 'Aucun message') : ListView.builder(controller: _scroll, padding: const EdgeInsets.all(16), itemCount: commentaires.length, itemBuilder: (_, i) => _BubbleRow(commentaire: commentaires[i])))]))), const SizedBox(height: 12), Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), decoration: BoxDecoration(color: kCardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))), child: Row(children: [Expanded(child: TextField(controller: _ctrl, onSubmitted: (_) => _send(), style: const TextStyle(fontSize: 13, color: kTextMain), decoration: const InputDecoration(hintText: 'Écrire un commentaire...', hintStyle: TextStyle(color: kTextSub), border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero))), GestureDetector(onTap: _send, child: Container(width: 36, height: 36, decoration: BoxDecoration(color: kAccent, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.send_rounded, color: Colors.white, size: 16)))]))]));
  }
}

class _BubbleRow extends StatelessWidget {
  final Commentaire commentaire; const _BubbleRow({required this.commentaire});
  @override
  Widget build(BuildContext context) { final isArchi = commentaire.role == 'architecte'; return Padding(padding: const EdgeInsets.only(bottom: 14), child: Column(crossAxisAlignment: isArchi ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [Row(mainAxisAlignment: isArchi ? MainAxisAlignment.end : MainAxisAlignment.start, children: [Text(commentaire.auteur, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: kTextMain)), const SizedBox(width: 6), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(4)), child: Text(isArchi ? 'ARCHITECTE' : 'CLIENT', style: const TextStyle(color: kTextSub, fontSize: 9, fontWeight: FontWeight.w700))), const SizedBox(width: 6), Text(commentaire.createdAt.length > 10 ? commentaire.createdAt.substring(0, 10) : commentaire.createdAt, style: const TextStyle(color: kTextSub, fontSize: 10))]), const SizedBox(height: 5), Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), decoration: BoxDecoration(color: isArchi ? kAccent : const Color(0xFFF3F4F6), borderRadius: BorderRadius.only(topLeft: const Radius.circular(14), topRight: const Radius.circular(14), bottomLeft: Radius.circular(isArchi ? 14 : 0), bottomRight: Radius.circular(isArchi ? 0 : 14))), child: Text(commentaire.contenu, style: TextStyle(color: isArchi ? Colors.white : kTextMain, fontSize: 13)))])); }
}

// ══════════════════════════════════════════════════════════════════════════════
//  WIDGETS COMMUNS
// ══════════════════════════════════════════════════════════════════════════════
class _StatusBadge extends StatelessWidget { final String label; final Color color; const _StatusBadge({required this.label, required this.color}); @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)), child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700))); }
class _AccessToggle extends StatefulWidget { @override State<_AccessToggle> createState() => _AccessToggleState(); }
class _AccessToggleState extends State<_AccessToggle> { bool _value = true; @override Widget build(BuildContext context) => Material(color: Colors.transparent, child: Row(mainAxisSize: MainAxisSize.min, children: [Switch(value: _value, onChanged: (v) => setState(() => _value = v), activeColor: kAccent), const Text('Accès Portail Client', style: TextStyle(color: kTextSub, fontSize: 12))])); }
class _InfoCard extends StatelessWidget { final IconData icon; final String label, value; const _InfoCard({required this.icon, required this.label, required this.value}); @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE5E7EB))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(icon, size: 13, color: kTextSub), const SizedBox(width: 6), Text(label, style: const TextStyle(color: kTextSub, fontSize: 11))]), const SizedBox(height: 6), Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: kTextMain))])); }
class _InfoChip extends StatelessWidget { final IconData icon; final String text; const _InfoChip({required this.icon, required this.text}); @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE5E7EB))), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 12, color: kTextSub), const SizedBox(width: 5), Text(text, style: const TextStyle(color: kTextSub, fontSize: 11))])); }
class _KpiCard extends StatelessWidget { final String label, value; final Color color; final IconData icon; const _KpiCard({required this.label, required this.value, required this.color, required this.icon}); @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: kCardBg, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 16)), const SizedBox(height: 8), FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: kTextMain))), const SizedBox(height: 2), Text(label, style: const TextStyle(color: kTextSub, fontSize: 11), overflow: TextOverflow.ellipsis)])); }
class _SectionCard extends StatelessWidget { final String title; final Widget child; const _SectionCard({required this.title, required this.child}); @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: kCardBg, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: kTextMain)), const SizedBox(height: 14), child])); }
class _TacheChip extends StatelessWidget { final IconData icon; final String text; const _TacheChip({required this.icon, required this.text}); @override Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 12, color: kTextSub), const SizedBox(width: 4), Text(text, style: const TextStyle(color: kTextSub, fontSize: 11))]); }
class _EmptyState extends StatelessWidget { final IconData icon; final String message; const _EmptyState({required this.icon, required this.message}); @override Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 30), child: Column(children: [Icon(icon, size: 40, color: kTextSub.withOpacity(0.4)), const SizedBox(height: 12), Text(message, style: TextStyle(color: kTextSub.withOpacity(0.7), fontSize: 14))]))); }
class _DialogHeader extends StatelessWidget { final IconData icon; final String title, subtitle; const _DialogHeader({required this.icon, required this.title, required this.subtitle}); @override Widget build(BuildContext context) => Container(decoration: BoxDecoration(color: kAccent.withOpacity(0.08), borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), border: Border(bottom: BorderSide(color: kAccent.withOpacity(0.15)))), padding: const EdgeInsets.fromLTRB(20, 18, 20, 16), child: Row(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: kAccent.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: kAccent, size: 20)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: kAccent)), const SizedBox(height: 2), Text(subtitle, style: const TextStyle(color: kTextSub, fontSize: 12))]))])); }
class _DialogActions extends StatelessWidget { final VoidCallback onCancel, onConfirm; final String label; const _DialogActions({required this.onCancel, required this.onConfirm, required this.label}); @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.fromLTRB(20, 14, 20, 20), decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFE5E7EB)))), child: Row(children: [Expanded(child: OutlinedButton(onPressed: onCancel, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 13), side: const BorderSide(color: Color(0xFFD1D5DB)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: const Text('Annuler', style: TextStyle(color: kTextSub, fontWeight: FontWeight.w600)))), const SizedBox(width: 10), Expanded(child: ElevatedButton(onPressed: onConfirm, style: ElevatedButton.styleFrom(backgroundColor: kAccent, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))))])); }
class _DField extends StatelessWidget { final IconData icon; final String label, hint; final TextEditingController controller; final TextInputType keyboardType; final int maxLines; const _DField({required this.icon, required this.label, required this.hint, required this.controller, this.keyboardType = TextInputType.text, this.maxLines = 1}); @override Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kTextSub, letterSpacing: 0.5)), const SizedBox(height: 6), TextField(controller: controller, keyboardType: keyboardType, maxLines: maxLines, style: const TextStyle(fontSize: 13, color: kTextMain), decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: kTextSub), prefixIcon: maxLines == 1 ? Icon(icon, size: 14, color: kTextSub) : null, isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: maxLines > 1 ? 14 : 10, vertical: maxLines > 1 ? 12 : 11), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kAccent, width: 2))))]); }

Color _tacheColor(String s) { switch (s) { case 'en_cours': return kAccent; case 'termine': return const Color(0xFF10B981); default: return const Color(0xFF9CA3AF); } }
String _tacheLabel(String s) { switch (s) { case 'en_cours': return 'En cours'; case 'termine': return 'Terminé'; default: return 'Planifié'; } }
Color _factureColor(String s) { switch (s) { case 'payee': return const Color(0xFF10B981); case 'en_retard': return kRed; default: return kAccent; } }
String _factureLabel(String s) { switch (s) { case 'payee': return 'Payée'; case 'en_retard': return 'En retard'; default: return 'En attente'; } }
String _fmtNum(double v) { if (v == 0) return '0 DT'; final s = v.toInt().toString(); final buf = StringBuffer(); int c = 0; for (int i = s.length - 1; i >= 0; i--) { if (c > 0 && c % 3 == 0) buf.write('.'); buf.write(s[i]); c++; } return '${buf.toString().split('').reversed.join()} DT'; }
void _snack(BuildContext context, String msg, Color color) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))); }