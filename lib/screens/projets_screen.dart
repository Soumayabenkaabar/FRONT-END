import 'package:archi_manager/Service/client_service.dart';
import 'package:archi_manager/Service/membre_service.dart';
import 'package:archi_manager/screens/projet_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/colors.dart';
import '../models/project.dart';
import '../service/projet_service.dart';
import '../widgets/project_full_card.dart';

class ProjetsScreen extends StatefulWidget {
  const ProjetsScreen({super.key});

  @override
  State<ProjetsScreen> createState() => _ProjetsScreenState();
}

class _ProjetsScreenState extends State<ProjetsScreen> {
  String selectedFilter = "Tous";
  List<Project> projets = [];
  bool isLoading = true;

  // ── Statuts disponibles ───────────────────────────────────────────────────
  static const List<String> _statuts = [
    'En cours',
    'Planification',
    'Terminé',
  ];

  @override
  void initState() {
    super.initState();
    loadProjets();
  }

  Future<void> loadProjets() async {
    try {
      final data = await ProjetService.getProjets();
      setState(() {
        projets = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Erreur projets: $e');
      setState(() => isLoading = false);
    }
  }

  // ── Filtre local ──────────────────────────────────────────────────────────
  List<Project> get _filtered {
    if (selectedFilter == 'Tous') return projets;
    return projets.where((p) => p.statut == selectedFilter).toList();
  }

  // ── Couleur statut ────────────────────────────────────────────────────────
  Color _statusColor(String status) {
    switch (status) {
      case 'En cours':      return const Color(0xFF3B82F6);
      case 'Planification': return kAccent;
      case 'Terminé':       return const Color(0xFF10B981);
      default:              return const Color(0xFF6B7280);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  POPUP AJOUTER PROJET
  // ══════════════════════════════════════════════════════════════════════════
  void showAddProjetDialog() {
    final titreCtrl       = TextEditingController();
    final descCtrl        = TextEditingController();
    final clientCtrl      = TextEditingController();
    final localisationCtrl = TextEditingController();
    final chefCtrl        = TextEditingController();
    final budgetCtrl      = TextEditingController();
    final dateDebutCtrl   = TextEditingController();
    final dateFinCtrl     = TextEditingController();
    bool isSaving = false;
    String statut         = 'En cours';
final clients = await ClientService.getClients();
final membres = await MembreService.getMembres();

String? selectedClientId;
String? selectedChef;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (context, sd) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [

                // ── Header ────────────────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: kAccent.withOpacity(0.08),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    border: Border(bottom: BorderSide(color: kAccent.withOpacity(0.2))),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                  child: Row(children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: kAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(LucideIcons.folderPlus, color: kAccent, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Nouveau projet',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: kAccent)),
                      const SizedBox(height: 3),
                      const Text('Créez un nouveau projet de construction',
                          style: TextStyle(color: kTextSub, fontSize: 12),
                          overflow: TextOverflow.ellipsis),
                    ])),
                  ]),
                ),

                // ── Champs ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(children: [

                    // Titre
                    _ProjetField(
                      icon: LucideIcons.building2,
                      label: 'TITRE DU PROJET',
                      hint: 'Villa Carthage',
                      controller: titreCtrl,
                    ),
                    const SizedBox(height: 12),

                    // Description
                    _ProjetField(
                      icon: LucideIcons.fileText,
                      label: 'DESCRIPTION',
                      hint: 'Construction villa R+1 avec piscine...',
                      controller: descCtrl,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),

                    // Client + Localisation
                    Row(children: [
                      Expanded(child: _ProjetField(
                        icon: LucideIcons.user,
                        label: 'CLIENT',
                        hint: 'Groupe OCP',
                        controller: clientCtrl,
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _ProjetField(
                        icon: LucideIcons.mapPin,
                        label: 'LOCALISATION',
                        hint: 'Tunis',
                        controller: localisationCtrl,
                      )),
                    ]),
                    const SizedBox(height: 12),

                    // Chef + Budget
                    Row(children: [
                      Expanded(child: _ProjetField(
                        icon: LucideIcons.hardHat,
                        label: 'CHEF DE PROJET',
                        hint: 'Ahmed Ben Ali',
                        controller: chefCtrl,
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _ProjetField(
                        icon: LucideIcons.banknote,
                        label: 'BUDGET (DT)',
                        hint: '8500000',
                        controller: budgetCtrl,
                        keyboardType: TextInputType.number,
                      )),
                    ]),
                    const SizedBox(height: 12),

                    // Date début + Date fin
                    Row(children: [
                      Expanded(child: _ProjetField(
                        icon: LucideIcons.calendarDays,
                        label: 'DATE DÉBUT',
                        hint: 'Jan 2025',
                        controller: dateDebutCtrl,
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _ProjetField(
                        icon: LucideIcons.calendarCheck,
                        label: 'DATE FIN',
                        hint: 'Déc 2025',
                        controller: dateFinCtrl,
                      )),
                    ]),
                    const SizedBox(height: 14),

                    // Statut selector
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('STATUT',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                              color: kTextSub, letterSpacing: 0.5)),
                      const SizedBox(height: 8),
                      Row(children: _statuts.map((s) {
                        final isSelected = statut == s;
                        return Expanded(child: Padding(
                          padding: EdgeInsets.only(right: s == _statuts.last ? 0 : 8),
                          child: GestureDetector(
                            onTap: () => sd(() => statut = s),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? _statusColor(s).withOpacity(0.1) : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? _statusColor(s) : const Color(0xFFE5E7EB),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(children: [
                                Container(
                                  width: 8, height: 8,
                                  decoration: BoxDecoration(
                                    color: isSelected ? _statusColor(s) : const Color(0xFFD1D5DB),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(s,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      color: isSelected ? _statusColor(s) : kTextSub,
                                    )),
                              ]),
                            ),
                          ),
                        ));
                      }).toList()),
                    ]),
                  ]),
                ),

                // ── Actions ────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                  decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Color(0xFFE5E7EB)))),
                  child: Row(children: [
                    Expanded(child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: const BorderSide(color: Color(0xFFD1D5DB)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Annuler',
                          style: TextStyle(color: kTextSub, fontWeight: FontWeight.w600)),
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: ElevatedButton.icon(
                      onPressed: isSaving
    ? null
    : () async {
        if (titreCtrl.text.trim().isEmpty) {
          _showSnack(context, 'Le titre est obligatoire', kRed);
          return;
        }

        sd(() => isSaving = true);

        try {
          final nouveau = Project(
            id: '',
            clientId: '',
            titre: titreCtrl.text.trim(),
            description: descCtrl.text.trim(),
            statut: statut,
            avancement: 0,
            dateDebut: dateDebutCtrl.text.trim().isEmpty
                ? null
                : dateDebutCtrl.text.trim(),
            dateFin: dateFinCtrl.text.trim().isEmpty
                ? null
                : dateFinCtrl.text.trim(),
            budgetTotal: double.tryParse(
                    budgetCtrl.text.replaceAll(' ', '')) ??
                0,
            budgetDepense: 0,
            client: clientCtrl.text.trim(),
            localisation: localisationCtrl.text.trim(),
            chef: chefCtrl.text.trim(),
            taches: 0,
          );

          await ProjetService.addProjet(nouveau);

          Navigator.pop(context);
          loadProjets();

          _showSnack(context, 'Projet créé avec succès', kAccent);
        } catch (e) {
          _showSnack(context, 'Erreur lors de création', kRed);
        }

        sd(() => isSaving = false);
      },
                      icon: const Icon(LucideIcons.folderPlus, size: 15, color: Colors.white),
                      label: const Text('Créer le projet',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAccent, elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    )),
                  ]),
                ),
              ]),
            ),
          ),
        );
      }),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final pad = isMobile ? 16.0 : 28.0;
    final filtered = _filtered;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: kAccent));
    }

    return Container(
      color: kBg,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(pad, pad, pad, pad + 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Header ─────────────────────────────────────────────────
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Mes Projets',
                    style: TextStyle(
                        fontSize: isMobile ? 26 : 28,
                        fontWeight: FontWeight.w800,
                        color: kTextMain)),
                const SizedBox(height: 6),
                const Text('Gérez tous vos projets de construction',
                    style: TextStyle(color: kTextSub, fontSize: 13)),
              ])),
              ElevatedButton.icon(
                onPressed: showAddProjetDialog,
                icon: const Icon(LucideIcons.plus, size: 15, color: Colors.white),
                label: Text(
                  isMobile ? 'Nouveau' : 'Nouveau projet',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccent,
                  padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 12 : 18,
                      vertical: isMobile ? 10 : 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ]),

            const SizedBox(height: 20),

            // ── Stats rapides ──────────────────────────────────────────
            IntrinsicHeight(
              child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Expanded(child: _MiniStat(
                    label: 'Total', value: '${projets.length}',
                    icon: LucideIcons.layoutGrid, color: kAccent)),
                const SizedBox(width: 10),
                Expanded(child: _MiniStat(
                    label: 'En cours',
                    value: '${projets.where((p) => p.statut == "En cours").length}',
                    icon: LucideIcons.activity, color: const Color(0xFF3B82F6))),
                const SizedBox(width: 10),
                Expanded(child: _MiniStat(
                    label: 'Terminés',
                    value: '${projets.where((p) => p.statut == "Terminé").length}',
                    icon: LucideIcons.checkCircle, color: const Color(0xFF10B981))),
              ]),
            ),

            const SizedBox(height: 20),

            // ── Filtres ────────────────────────────────────────────────
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                _buildFilter('Tous'),
                _buildFilter('En cours'),
                _buildFilter('Planification'),
                _buildFilter('Terminé'),
              ]),
            ),

            const SizedBox(height: 20),

            // ── Liste projets ──────────────────────────────────────────
            if (filtered.isEmpty)
              Center(child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Column(children: [
                  Icon(LucideIcons.folderOpen, size: 48, color: kTextSub.withOpacity(0.4)),
                  const SizedBox(height: 14),
                  Text(
                    selectedFilter == 'Tous'
                        ? 'Aucun projet trouvé'
                        : 'Aucun projet "$selectedFilter"',
                    style: const TextStyle(color: kTextSub, fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text('Appuyez sur "Nouveau projet" pour commencer',
                      style: TextStyle(color: kTextSub.withOpacity(0.6), fontSize: 13)),
                ]),
              ))
            else
              LayoutBuilder(builder: (context, constraints) {
                if (constraints.maxWidth > 900) {
                  return _ProjetGrid(projects: filtered, columns: 3, onRefresh: loadProjets);
                }
                if (constraints.maxWidth > 580) {
                  return _ProjetGrid(projects: filtered, columns: 2, onRefresh: loadProjets);
                }
                return Column(
                  children: filtered.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GestureDetector(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) =>
                              ProjetDetailScreen(project: p, projectIndex: 0))),
                      child: ProjectFullCard(project: p),
                    ),
                  )).toList(),
                );
              }),
          ],
        ),
      ),
    );
  }

  // ── Filter button ─────────────────────────────────────────────────────────
  Widget _buildFilter(String label) {
    final isSelected = selectedFilter == label;
    final color = label == 'Tous' ? kAccent : _statusColor(label);

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () => setState(() => selectedFilter = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? color : kCardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? color : const Color(0xFFE5E7EB),
              width: isSelected ? 0 : 1,
            ),
          ),
          child: Text(label,
              style: TextStyle(
                  color: isSelected ? Colors.white : kTextSub,
                  fontWeight: FontWeight.w600,
                  fontSize: 12)),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  GRID DESKTOP/TABLETTE
// ══════════════════════════════════════════════════════════════════════════════
class _ProjetGrid extends StatelessWidget {
  final List<Project> projects;
  final int columns;
  final VoidCallback onRefresh;

  const _ProjetGrid({required this.projects, required this.columns, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (int i = 0; i < projects.length; i += columns) {
      final rowItems = projects.skip(i).take(columns).toList();
      rows.add(IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          for (int j = 0; j < rowItems.length; j++) ...[
            if (j > 0) const SizedBox(width: 20),
            Expanded(child: GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) =>
                      ProjetDetailScreen(project: rowItems[j], projectIndex: 0))),
              child: ProjectFullCard(project: rowItems[j]),
            )),
          ],
          for (int k = rowItems.length; k < columns; k++) ...[
            const SizedBox(width: 20),
            const Expanded(child: SizedBox()),
          ],
        ]),
      ));
      if (i + columns < projects.length) rows.add(const SizedBox(height: 20));
    }
    return Column(children: rows);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  HELPERS
// ══════════════════════════════════════════════════════════════════════════════
class _MiniStat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _MiniStat({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: kCardBg,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: color, size: 16),
      ),
      const SizedBox(height: 8),
      FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
          child: Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: kTextMain))),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(color: kTextSub, fontSize: 11), overflow: TextOverflow.ellipsis),
    ]),
  );
}

class _ProjetField extends StatelessWidget {
  final IconData icon;
  final String label, hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final int maxLines;

  const _ProjetField({
    required this.icon,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kTextSub, letterSpacing: 0.5)),
    const SizedBox(height: 6),
    TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 13, color: kTextMain),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: kTextSub),
        prefixIcon: maxLines == 1 ? Icon(icon, size: 14, color: kTextSub) : null,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
            horizontal: maxLines > 1 ? 14 : 10,
            vertical: maxLines > 1 ? 12 : 11),
        filled: true,
        fillColor: Colors.white,
        border:        OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: kAccent, width: 2)),
      ),
    ),
  ]);
}

void _showSnack(BuildContext context, String msg, Color color) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg),
    backgroundColor: color,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ));
}