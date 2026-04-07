import 'package:archi_manager/Service/membre_service.dart';
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
      setState(() {
        membres = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Erreur membres: $e');
    }
  }

  // ── Popup Ajouter un membre ──────────────────────────────────────────────────
  void showAddMembreDialog() {
    final nomCtrl        = TextEditingController();
    final roleCtrl       = TextEditingController();
    final specialiteCtrl = TextEditingController();
    final emailCtrl      = TextEditingController();
    final telCtrl        = TextEditingController();
    bool disponible      = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // ── Header ────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                    decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: Color(0xFFE5E7EB))),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: kAccent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(19),
                          ),
                          child: const Icon(LucideIcons.users,
                              color: kAccent, size: 17),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Ajouter un membre',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: kTextMain)),
                            SizedBox(height: 2),
                            Text('Remplissez les informations du membre',
                                style: TextStyle(
                                    color: kTextSub, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ── Champs ────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _DialogField(
                                icon: LucideIcons.user,
                                label: 'NOM COMPLET',
                                hint: 'Ahmed Ben Ali',
                                controller: nomCtrl,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _DialogField(
                                icon: LucideIcons.briefcase,
                                label: 'RÔLE',
                                hint: 'Architecte',
                                controller: roleCtrl,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _DialogField(
                          icon: LucideIcons.settings,
                          label: 'SPÉCIALITÉ',
                          hint: 'Béton armé',
                          controller: specialiteCtrl,
                        ),
                        const SizedBox(height: 14),
                        _DialogField(
                          icon: LucideIcons.mail,
                          label: 'EMAIL',
                          hint: 'email@archi.ma',
                          controller: emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 14),
                        _DialogField(
                          icon: LucideIcons.phone,
                          label: 'TÉLÉPHONE',
                          hint: '0661234567',
                          controller: telCtrl,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 14),

                        // Toggle disponible
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: const Color(0xFFE5E7EB)),
                          ),
                          child: Row(
                            children: [
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text('Disponible',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 13,
                                            color: kTextMain)),
                                    SizedBox(height: 2),
                                    Text('Disponible par défaut',
                                        style: TextStyle(
                                            color: kTextSub,
                                            fontSize: 11)),
                                  ],
                                ),
                              ),
                              Switch(
                                value: disponible,
                                onChanged: (v) => setStateDialog(
                                    () => disponible = v),
                                activeColor: kAccent,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Actions ───────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                    decoration: const BoxDecoration(
                      border: Border(
                          top: BorderSide(color: Color(0xFFE5E7EB))),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            side: const BorderSide(
                                color: Color(0xFFD1D5DB)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Annuler',
                              style: TextStyle(color: kTextSub)),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: () async {
                            await MembreService.addMembre(
                              Membre(
                                id: '',
                                nom: nomCtrl.text,
                                role: roleCtrl.text,
                                specialite: specialiteCtrl.text,
                                email: emailCtrl.text,
                                telephone: telCtrl.text,
                                disponible: disponible,
                                projetsAssignes: [],
                              ),
                            );
                            Navigator.pop(context);
                            loadMembres();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    const Text('Membre ajouté avec succès'),
                                backgroundColor: kAccent,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(8)),
                              ),
                            );
                          },
                          icon: const Icon(LucideIcons.userPlus,
                              size: 14, color: Colors.white),
                          label: const Text('Ajouter le membre',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kAccent,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final pad = isMobile ? 16.0 : 28.0;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filtered = membres.where((m) {
      return m.nom.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

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

            // ── Header ──────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gestion de l\'équipe',
                        style: TextStyle(
                          fontSize: isMobile ? 22 : 28,
                          fontWeight: FontWeight.w800,
                          color: kTextMain,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Gérez votre équipe et leurs assignations aux projets',
                        style: TextStyle(
                            color: kTextSub,
                            fontSize: isMobile ? 12 : 14),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: showAddMembreDialog,
                  icon: const Icon(LucideIcons.userPlus,
                      size: 15, color: Colors.white),
                  label: Text(
                    isMobile ? 'Ajouter' : 'Ajouter un membre',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAccent,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 12 : 18,
                      vertical: isMobile ? 10 : 14,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Search ──────────────────────────────────────────────
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

            // ── Stats ────────────────────────────────────────────────
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Total membres',
                      value: '$total',
                      icon: LucideIcons.users,
                      color: kAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'En activité',
                      value: '${actifs.length}',
                      icon: LucideIcons.activity,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Disponibles',
                      value: '${disponibles.length}',
                      icon: LucideIcons.checkCircle,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Membres disponibles ──────────────────────────────────
            if (disponibles.isNotEmpty) ...[
              Row(
                children: const [
                  Icon(LucideIcons.checkCircle, color: kAccent, size: 18),
                  SizedBox(width: 8),
                  Text('Membres disponibles',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: kTextMain)),
                ],
              ),
              const SizedBox(height: 14),

              // ✅ FIX : Column avec IntrinsicHeight au lieu de GridView
              LayoutBuilder(builder: (context, constraints) {
                final cols = constraints.maxWidth > 900
                    ? 3
                    : constraints.maxWidth > 580
                        ? 2
                        : 1;

                final rows = <Widget>[];
                for (int i = 0; i < disponibles.length; i += cols) {
                  final rowItems =
                      disponibles.skip(i).take(cols).toList();
                  rows.add(
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (int j = 0; j < rowItems.length; j++) ...[
                            if (j > 0) const SizedBox(width: 16),
                            Expanded(
                              child: MembreDisponibleCard(
                                  membre: rowItems[j]),
                            ),
                          ],
                          for (int k = rowItems.length; k < cols; k++) ...[
                            const SizedBox(width: 16),
                            const Expanded(child: SizedBox()),
                          ],
                        ],
                      ),
                    ),
                  );
                  if (i + cols < disponibles.length) {
                    rows.add(const SizedBox(height: 16));
                  }
                }
                return Column(children: rows);
              }),

              const SizedBox(height: 24),
            ],

            // ── Membres en activité ──────────────────────────────────
            if (actifs.isNotEmpty) ...[
              Row(
                children: const [
                  Icon(LucideIcons.briefcase,
                      color: Color(0xFF6B7280), size: 18),
                  SizedBox(width: 8),
                  Text('Membres en activité',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: kTextMain)),
                ],
              ),
              const SizedBox(height: 14),
              ...actifs.map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: MembreActifRow(membre: m),
                  )),
            ],

            if (filtered.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: const [
                      Icon(LucideIcons.users, size: 40, color: kTextSub),
                      SizedBox(height: 12),
                      Text('Aucun membre trouvé',
                          style: TextStyle(
                              color: kTextSub,
                              fontSize: 15,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: kTextSub, fontSize: 12)),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                      color: kTextMain)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Dialog Field ──────────────────────────────────────────────────────────────
class _DialogField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;

  const _DialogField({
    required this.icon,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: kTextSub,
                letterSpacing: 0.5)),
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kAccent, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}