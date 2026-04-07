// ══════════════════════════════════════════════════════════════════════════════
//  CORRECTIONS APPLIQUÉES:
//  1. Dialog: ajout de margin + insetPadding pour respecter les bords mobiles
//  2. _MembreDialog: Row NOM+RÔLE → Column sur petits écrans
//  3. Stats: texte tronqué avec Flexible/FittedBox
//  4. Boutons dialog: Row → Wrap pour éviter overflow
// ══════════════════════════════════════════════════════════════════════════════

import 'package:archi_manager/Service/membre_service.dart';
import 'package:archi_manager/Service/projet_service.dart';
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
  List<Membre> membres = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadMembres();
  }

  Future<void> loadMembres() async {
    try {
      final data = await MembreService.getMembres();
      setState(() { membres = data; isLoading = false; });
    } catch (e) { debugPrint('Erreur membres: $e'); }
  }

  void showAddMembreDialog() {
    final nomCtrl        = TextEditingController();
    final roleCtrl       = TextEditingController();
    final specialiteCtrl = TextEditingController();
    final emailCtrl      = TextEditingController();
    final telCtrl        = TextEditingController();
    bool disponible      = true;

    showDialog(
      context: context,
      // ✅ FIX 1: insetPadding garantit un espace sur les bords
      builder: (context) => StatefulBuilder(builder: (context, sd) {
        return _MembreDialog(
          title: 'Ajouter un membre',
          subtitle: 'Remplissez les informations du nouveau membre',
          icon: LucideIcons.userPlus,
          nomCtrl: nomCtrl,
          roleCtrl: roleCtrl,
          specialiteCtrl: specialiteCtrl,
          emailCtrl: emailCtrl,
          telCtrl: telCtrl,
          disponible: disponible,
          onDisponibleChanged: (v) => sd(() => disponible = v),
          btnLabel: 'Ajouter le membre',
          btnIcon: LucideIcons.userPlus,
          onSubmit: () async {
            await MembreService.addMembre(Membre(
              id: null,
              nom: nomCtrl.text,
              role: roleCtrl.text,
              specialite: specialiteCtrl.text,
              email: emailCtrl.text,
              telephone: telCtrl.text,
              disponible: disponible,
              projetsAssignes: [],
            ));
            Navigator.pop(context);
            loadMembres();
            _showSnack(context, 'Membre ajouté avec succès', kAccent);
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final pad = isMobile ? 16.0 : 28.0;

    if (isLoading) return const Center(child: CircularProgressIndicator());

    final filtered    = membres.where((m) => m.nom.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    final disponibles = filtered.where((m) => m.disponible).toList();
    final actifs      = filtered.where((m) => !m.disponible).toList();
    final total       = filtered.length;

    return Container(
      color: kBg,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(pad, pad, pad, pad + 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Header ────────────────────────────────────────────────
            Row(children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Gestion de l\'équipe',
                      style: TextStyle(
                          fontSize: isMobile ? 22 : 28,
                          fontWeight: FontWeight.w800, color: kTextMain)),
                  const SizedBox(height: 4),
                  Text('Gérez votre équipe et leurs assignations aux projets',
                      style: TextStyle(color: kTextSub, fontSize: isMobile ? 12 : 14)),
                ],
              )),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: showAddMembreDialog,
                icon: const Icon(LucideIcons.userPlus, size: 15, color: Colors.white),
                label: Text(isMobile ? 'Ajouter' : 'Ajouter un membre',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccent, elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 18, vertical: isMobile ? 10 : 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ]),

            const SizedBox(height: 20),

            // ── Search ────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: kCardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: TextField(
                controller: searchController,
                onChanged: (v) => setState(() => searchQuery = v),
                decoration: const InputDecoration(
                  icon: Icon(LucideIcons.search, size: 18, color: kTextSub),
                  hintText: 'Rechercher un membre...',
                  hintStyle: TextStyle(color: kTextSub),
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Stats ─────────────────────────────────────────────────
            // ✅ FIX 2: IntrinsicHeight + stretch pour égaliser la hauteur
            IntrinsicHeight(
              child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Expanded(child: _StatCard(title: 'Total', value: '$total', icon: LucideIcons.users, color: kAccent)),
                const SizedBox(width: 10),
                Expanded(child: _StatCard(title: 'En activité', value: '${actifs.length}', icon: LucideIcons.activity, color: const Color(0xFF6B7280))),
                const SizedBox(width: 10),
                Expanded(child: _StatCard(title: 'Disponibles', value: '${disponibles.length}', icon: LucideIcons.checkCircle, color: const Color(0xFF10B981))),
              ]),
            ),

            const SizedBox(height: 24),

            // ── Disponibles ───────────────────────────────────────────
            if (disponibles.isNotEmpty) ...[
              _SectionTitle(icon: LucideIcons.checkCircle, color: kAccent, label: 'Membres disponibles'),
              const SizedBox(height: 14),
              LayoutBuilder(builder: (context, constraints) {
                final cols = constraints.maxWidth > 900 ? 3 : constraints.maxWidth > 580 ? 2 : 1;
                final rows = <Widget>[];
                for (int i = 0; i < disponibles.length; i += cols) {
                  final rowItems = disponibles.skip(i).take(cols).toList();
                  rows.add(IntrinsicHeight(
                    child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      for (int j = 0; j < rowItems.length; j++) ...[
                        if (j > 0) const SizedBox(width: 16),
                        Expanded(child: MembreDisponibleCard(
                          membre: rowItems[j],
                          onAssign: () => showAssignDialog(context, rowItems[j], loadMembres),
                          onEdit:   () => showEditDialog(context, rowItems[j], loadMembres),
                          onDelete: () async {
                            if (rowItems[j].id == null) return;
                            await MembreService.deleteMembre(rowItems[j].id!);
                            _showSnack(context, 'Membre supprimé', kRed);
                            loadMembres();
                          },
                        )),
                      ],
                      for (int k = rowItems.length; k < cols; k++) ...[
                        const SizedBox(width: 16),
                        const Expanded(child: SizedBox()),
                      ],
                    ]),
                  ));
                  if (i + cols < disponibles.length) rows.add(const SizedBox(height: 16));
                }
                return Column(children: rows);
              }),
              const SizedBox(height: 24),
            ],

            // ── En activité ───────────────────────────────────────────
            if (actifs.isNotEmpty) ...[
              _SectionTitle(icon: LucideIcons.briefcase, color: const Color(0xFF6B7280), label: 'Membres en activité'),
              const SizedBox(height: 14),
              ...actifs.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: MembreActifRow(
                  membre: m,
                  onView:   () => showViewDialog(context, m),
                  onEdit:   () => showEditDialog(context, m, loadMembres),
                  onDelete: () async {
                    if (m.id == null) return;
                    await MembreService.deleteMembre(m.id!);
                    _showSnack(context, 'Membre supprimé', kRed);
                    loadMembres();
                  },
                ),
              )),
            ],

            if (filtered.isEmpty)
              Center(child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(children: const [
                  Icon(LucideIcons.users, size: 40, color: kTextSub),
                  SizedBox(height: 12),
                  Text('Aucun membre trouvé',
                      style: TextStyle(color: kTextSub, fontSize: 15, fontWeight: FontWeight.w500)),
                ]),
              )),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  POPUP MODIFIER
// ══════════════════════════════════════════════════════════════════════════════
void showEditDialog(BuildContext context, Membre membre, VoidCallback onRefresh) {
  final nomCtrl        = TextEditingController(text: membre.nom);
  final roleCtrl       = TextEditingController(text: membre.role);
  final specialiteCtrl = TextEditingController(text: membre.specialite);
  final emailCtrl      = TextEditingController(text: membre.email);
  final telCtrl        = TextEditingController(text: membre.telephone);
  bool disponible      = membre.disponible;

  showDialog(
    context: context,
    builder: (_) => StatefulBuilder(builder: (context, sd) {
      return _MembreDialog(
        title: 'Modifier le membre',
        subtitle: 'Mettez à jour les informations',
        icon: LucideIcons.pencil,
        iconBg: const Color(0xFFE0F2FE),
        iconColor: const Color(0xFFF5A623),
        nomCtrl: nomCtrl,
        roleCtrl: roleCtrl,
        specialiteCtrl: specialiteCtrl,
        emailCtrl: emailCtrl,
        telCtrl: telCtrl,
        disponible: disponible,
        onDisponibleChanged: (v) => sd(() => disponible = v),
        btnLabel: 'Enregistrer',
        btnIcon: LucideIcons.save,
        onSubmit: () async {
          await MembreService.updateMembre(Membre(
            id: membre.id,
            nom: nomCtrl.text,
            role: roleCtrl.text,
            specialite: specialiteCtrl.text,
            email: emailCtrl.text,
            telephone: telCtrl.text,
            disponible: disponible,
            projetsAssignes: membre.projetsAssignes,
          ));
          Navigator.pop(context);
          _showSnack(context, 'Membre modifié avec succès', const Color(0xFF0284C7));
          onRefresh();
        },
      );
    }),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
//  POPUP ASSIGNER
// ══════════════════════════════════════════════════════════════════════════════
void showAssignDialog(BuildContext context, Membre membre, VoidCallback onRefresh) async {
  final projets = await ProjetService.getProjets();
  String? selectedId;

  showDialog(
    context: context,
    builder: (_) => StatefulBuilder(builder: (context, sd) {
      return Dialog(
        // ✅ FIX 3: insetPadding pour que la dialog respecte les bords
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(mainAxisSize: MainAxisSize.min, children: [

            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
              decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB)))),
              child: Row(children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: kAccent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(19),
                  ),
                  child: const Icon(LucideIcons.folderInput, color: kAccent, size: 17),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Assigner à un projet',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: kTextMain)),
                    const SizedBox(height: 2),
                    Text('Membre : ${membre.nom}',
                        style: const TextStyle(color: kTextSub, fontSize: 12),
                        overflow: TextOverflow.ellipsis),
                  ],
                )),
              ]),
            ),

            // Contenu
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // Carte membre
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(children: [
                    Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: kAccent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(19),
                      ),
                      child: const Icon(LucideIcons.user, color: kAccent, size: 17),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(membre.nom,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: kTextMain),
                          overflow: TextOverflow.ellipsis),
                      Text(membre.role,
                          style: const TextStyle(color: kTextSub, fontSize: 11),
                          overflow: TextOverflow.ellipsis),
                    ])),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Disponible',
                          style: TextStyle(color: Color(0xFF16A34A), fontSize: 10, fontWeight: FontWeight.w600)),
                    ),
                  ]),
                ),

                const SizedBox(height: 16),

                const Text('PROJET', style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600,
                    color: kTextSub, letterSpacing: 0.5)),
                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedId,
                      hint: const Text('Sélectionner un projet',
                          style: TextStyle(color: kTextSub, fontSize: 13)),
                      isExpanded: true,
                      icon: const Icon(LucideIcons.chevronsUpDown, size: 16, color: kTextSub),
                      items: projets.map<DropdownMenuItem<String>>((p) {
                        return DropdownMenuItem(
                          value: p['id'].toString(),
                          child: Row(children: [
                            Container(
                              width: 8, height: 8,
                              decoration: BoxDecoration(
                                color: kAccent,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: Text(p['titre'] ?? '',
                                style: const TextStyle(fontSize: 13, color: kTextMain),
                                overflow: TextOverflow.ellipsis)),
                          ]),
                        );
                      }).toList(),
                      onChanged: (v) => sd(() => selectedId = v),
                    ),
                  ),
                ),
              ]),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
              decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0xFFE5E7EB)))),
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Annuler', style: TextStyle(color: kTextSub)),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: selectedId == null ? null : () async {
                    final selectedProjet = projets.firstWhere((p) => p['id'].toString() == selectedId);
                    await MembreService.assignMembre(membre: membre, projet: selectedProjet['titre']);
                    Navigator.pop(context);
                    _showSnack(context, 'Assigné avec succès', kAccent);
                    onRefresh();
                  },
                  icon: const Icon(LucideIcons.check, size: 14, color: Colors.white),
                  label: const Text('Assigner',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedId == null ? const Color(0xFFD1D5DB) : kAccent,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      );
    }),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
//  POPUP VIEW
// ══════════════════════════════════════════════════════════════════════════════
void showViewDialog(BuildContext context, Membre membre) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      // ✅ FIX: insetPadding
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(mainAxisSize: MainAxisSize.min, children: [

          Container(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB)))),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(LucideIcons.user, color: Color(0xFF3B82F6), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(membre.nom,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: kTextMain),
                    overflow: TextOverflow.ellipsis),
                Text(membre.role,
                    style: const TextStyle(color: kTextSub, fontSize: 12)),
              ])),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: membre.disponible ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  membre.disponible ? 'Disponible' : 'En activité',
                  style: TextStyle(
                    color: membre.disponible ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                    fontSize: 10, fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ]),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              _ViewRow(icon: LucideIcons.settings, label: 'Spécialité', value: membre.specialite),
              const SizedBox(height: 10),
              _ViewRow(icon: LucideIcons.mail, label: 'Email', value: membre.email),
              const SizedBox(height: 10),
              _ViewRow(icon: LucideIcons.phone, label: 'Téléphone', value: membre.telephone),
              if (membre.projetsAssignes.isNotEmpty) ...[
                const SizedBox(height: 14),
                const Divider(color: Color(0xFFF3F4F6)),
                const SizedBox(height: 10),
                Row(children: const [
                  Icon(LucideIcons.folder, size: 14, color: kTextSub),
                  SizedBox(width: 8),
                  Text('Projets assignés',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: kTextMain)),
                ]),
                const SizedBox(height: 8),
                ...membre.projetsAssignes.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: kAccent.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(children: [
                      Container(width: 6, height: 6,
                          decoration: BoxDecoration(color: kAccent, borderRadius: BorderRadius.circular(3))),
                      const SizedBox(width: 8),
                      Expanded(child: Text(p, style: const TextStyle(color: kTextMain, fontSize: 12, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
                    ]),
                  ),
                )),
              ],
            ]),
          ),

          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Color(0xFFD1D5DB)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Fermer', style: TextStyle(color: kTextSub)),
              ),
            ),
          ),
        ]),
      ),
    ),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
//  SHARED MEMBRE DIALOG — CORRIGÉ
// ══════════════════════════════════════════════════════════════════════════════
class _MembreDialog extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color? iconBg;
  final Color? iconColor;
  final TextEditingController nomCtrl;
  final TextEditingController roleCtrl;
  final TextEditingController specialiteCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController telCtrl;
  final bool disponible;
  final ValueChanged<bool> onDisponibleChanged;
  final String btnLabel;
  final IconData btnIcon;
  final VoidCallback onSubmit;

  const _MembreDialog({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.iconBg,
    this.iconColor,
    required this.nomCtrl,
    required this.roleCtrl,
    required this.specialiteCtrl,
    required this.emailCtrl,
    required this.telCtrl,
    required this.disponible,
    required this.onDisponibleChanged,
    required this.btnLabel,
    required this.btnIcon,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final bg    = iconBg    ?? kAccent.withOpacity(0.12);
    final color = iconColor ?? kAccent;
    // ✅ FIX 4: Détecter la largeur pour adapter le layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 420;

    return Dialog(
      // ✅ FIX 5: insetPadding crucial — empêche tout overflow horizontal
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [

            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
              decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB)))),
              child: Row(children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(19)),
                  child: Icon(icon, color: color, size: 17),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: kTextMain)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: kTextSub, fontSize: 12), overflow: TextOverflow.ellipsis),
                ])),
              ]),
            ),

            // Champs
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                // ✅ FIX 6: Sur petits écrans → Column, sinon Row
                if (isNarrow) ...[
                  _DialogField(icon: LucideIcons.user,      label: 'NOM COMPLET', hint: 'Ahmed Ben Ali', controller: nomCtrl),
                  const SizedBox(height: 12),
                  _DialogField(icon: LucideIcons.briefcase, label: 'RÔLE',        hint: 'Architecte',   controller: roleCtrl),
                ] else
                  Row(children: [
                    Expanded(child: _DialogField(icon: LucideIcons.user,      label: 'NOM COMPLET', hint: 'Ahmed Ben Ali', controller: nomCtrl)),
                    const SizedBox(width: 12),
                    Expanded(child: _DialogField(icon: LucideIcons.briefcase, label: 'RÔLE',        hint: 'Architecte',   controller: roleCtrl)),
                  ]),
                const SizedBox(height: 12),
                _DialogField(icon: LucideIcons.settings, label: 'SPÉCIALITÉ', hint: 'Béton armé',     controller: specialiteCtrl),
                const SizedBox(height: 12),
                _DialogField(icon: LucideIcons.mail,     label: 'EMAIL',       hint: 'email@archi.ma', controller: emailCtrl, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 12),
                _DialogField(icon: LucideIcons.phone,    label: 'TÉLÉPHONE',   hint: '0661234567',     controller: telCtrl,   keyboardType: TextInputType.phone),
                const SizedBox(height: 12),
                // Toggle
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(children: [
                    const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Statut disponibilité',
                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: kTextMain)),
                      SizedBox(height: 2),
                      Text('Activer si le membre est disponible',
                          style: TextStyle(color: kTextSub, fontSize: 11)),
                    ])),
                    Switch(value: disponible, onChanged: onDisponibleChanged, activeColor: kAccent),
                  ]),
                ),
              ]),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFE5E7EB)))),
              // ✅ FIX 7: Row avec MainAxisAlignment.end + bouton flexible
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Annuler', style: TextStyle(color: kTextSub)),
                ),
                const SizedBox(width: 10),
                // ✅ FIX 8: Flexible pour éviter overflow du bouton principal
                Flexible(
                  child: ElevatedButton.icon(
                    onPressed: onSubmit,
                    icon: Icon(btnIcon, size: 14, color: Colors.white),
                    label: Text(btnLabel,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  HELPERS
// ══════════════════════════════════════════════════════════════════════════════
class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  const _SectionTitle({required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, color: color, size: 18),
    const SizedBox(width: 8),
    Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: kTextMain)),
  ]);
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: kCardBg,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
    ),
    // ✅ FIX 9: Column au lieu de Row pour éviter l'overflow sur petites cartes
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: kTextMain)),
        ),
        const SizedBox(height: 2),
        Text(title, style: const TextStyle(color: kTextSub, fontSize: 11), overflow: TextOverflow.ellipsis),
      ],
    ),
  );
}

class _ViewRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _ViewRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 14, color: kTextSub),
    const SizedBox(width: 10),
    Text('$label : ', style: const TextStyle(color: kTextSub, fontSize: 13)),
    Expanded(child: Text(value, style: const TextStyle(color: kTextMain, fontSize: 13, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
  ]);
}

class _DialogField extends StatelessWidget {
  final IconData icon;
  final String label, hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  const _DialogField({required this.icon, required this.label, required this.hint, required this.controller, this.keyboardType = TextInputType.text});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: kTextSub, letterSpacing: 0.5)),
    const SizedBox(height: 6),
    TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 13, color: kTextMain),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: kTextSub),
        prefixIcon: Icon(icon, size: 14, color: kTextSub),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
        filled: true, fillColor: Colors.white,
        border:        OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kAccent, width: 2)),
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