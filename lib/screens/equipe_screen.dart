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
      debugPrint("Erreur membres: $e");
    }
  }

  // 🔥 POPUP AJOUT MEMBRE
 void showAddMembreDialog() {
  final nomCtrl        = TextEditingController();
  final roleCtrl       = TextEditingController();
  final specialiteCtrl = TextEditingController();
  final emailCtrl      = TextEditingController();
  final telCtrl        = TextEditingController();

  bool disponible = true;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // ── HEADER ─────────────────────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF4FF),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(LucideIcons.users,
                            color: Colors.blue, size: 16),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ajouter un membre',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15, color: kTextMain)),
                          Text('Remplissez les informations du membre',
                              style: TextStyle(color: kTextSub, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── CHAMPS ─────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _DialogField(
                            icon: LucideIcons.user,
                            label: 'NOM COMPLET',
                            hint: 'Ahmed Ben Ali',
                            controller: nomCtrl,
                          )),
                          const SizedBox(width: 12),
                          Expanded(child: _DialogField(
                            icon: LucideIcons.briefcase,
                            label: 'RÔLE',
                            hint: 'Architecte',
                            controller: roleCtrl,
                          )),
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
                        hint: 'email@mail.com',
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 14),

                      _DialogField(
                        icon: LucideIcons.phone,
                        label: 'TÉLÉPHONE',
                        hint: '00000000',
                        controller: telCtrl,
                        keyboardType: TextInputType.phone,
                      ),

                      const SizedBox(height: 14),

                      // STATUS
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Disponible',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                          color: kTextMain)),
                                  Text('Disponible par défaut',
                                      style: TextStyle(
                                          color: kTextSub, fontSize: 11)),
                                ],
                              ),
                            ),
                            Switch(
                              value: disponible,
                              onChanged: (v) =>
                                  setState(() => disponible = v),
                              activeColor: kAccent,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── ACTIONS ─────────────────────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Annuler'),
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
                              content: const Text('Membre ajouté avec succès'),
                              backgroundColor: kAccent,
                            ),
                          );
                        },
                        icon: const Icon(LucideIcons.userPlus,
                            size: 14, color: Colors.white),
                        label: const Text('Ajouter le membre',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kAccent,
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
    final pad = isMobile ? 14.0 : 28.0;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filtered = membres.where((m) {
      return m.nom.toLowerCase().contains(searchQuery.toLowerCase());
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
            // HEADER
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
                  onPressed: showAddMembreDialog,
                  icon: const Icon(LucideIcons.userPlus, color: Colors.white),
                  label: Text(
                    isMobile ? 'Ajouter' : 'Ajouter un membre',
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAccent,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // SEARCH
            TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() => searchQuery = value);
              },
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Rechercher un membre...",
              ),
            ),

            const SizedBox(height: 20),

            Text("Total: $total"),
            Text("Disponibles: ${disponibles.length}"),
            Text("Actifs: ${actifs.length}"),

            const SizedBox(height: 20),

            // DISPONIBLES
            const Text("Disponibles"),
            ...disponibles.map((m) => MembreDisponibleCard(membre: m)),

            const SizedBox(height: 20),

            // ACTIFS
            const Text("En activité"),
            ...actifs.map((m) => MembreActifRow(membre: m)),
          ],
        ),
      ),
    );
  }
}

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
        // LABEL
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: kTextSub,
            letterSpacing: 0.5,
          ),
        ),

        const SizedBox(height: 6),

        // INPUT
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontSize: 13,
            color: kTextMain,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: kTextSub),

            prefixIcon: Icon(icon, size: 14, color: kTextSub),

            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 11,
            ),

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