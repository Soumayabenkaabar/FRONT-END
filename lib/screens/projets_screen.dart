import 'package:archi_manager/screens/projet_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/colors.dart';
import '../models/project.dart';
import '../widgets/project_full_card.dart';

class ProjetsScreen extends StatefulWidget {
  const ProjetsScreen({super.key});

  @override
  State<ProjetsScreen> createState() => _ProjetsScreenState();
}

class _ProjetsScreenState extends State<ProjetsScreen> {
  String selectedFilter = "Tous";

  // 🔍 FILTRE
  List<Project> _filteredProjects() {
    if (selectedFilter == "Tous") {
      return sampleProjects;
    }

    return sampleProjects.where((p) {
      return p.status == selectedFilter;
    }).toList();
  }

  // 🎨 COULEUR STATUS (OPTION PRO)
  Color _getStatusColor(String status) {
    switch (status) {
      case "En cours":
        return Colors.blue;
      case "Planification":
        return Colors.orange;
      case "Terminé":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final pad = isMobile ? 16.0 : 28.0;

    final projects = _filteredProjects();

    return Container(
      color: kBg,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(pad, pad, pad, pad + 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER ─────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mes Projets',
                        style: TextStyle(
                          fontSize: isMobile ? 26 : 28,
                          fontWeight: FontWeight.w800,
                          color: kTextMain,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Gérez tous vos projets de construction',
                        style: TextStyle(color: kTextSub, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                 ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.plus,
                      size: 15, color: Colors.white),
                  label: Text(
                    isMobile ? 'Nouveau' : 'Nouveau projet',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAccent,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 12 : 18,
                      vertical: isMobile ? 10 : 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),

        
              ],
            ),

            const SizedBox(height: 24),

            // ── FILTRES ─────────────────────────────
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilter("Tous"),
                  _buildFilter("En cours"),
                  _buildFilter("Planification"),
                  _buildFilter("Terminé"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── LISTE PROJETS ─────────────────────
            LayoutBuilder(builder: (context, constraints) {
              if (constraints.maxWidth > 900) {
                return _DesktopGrid(projects: projects, columns: 3);
              }
              if (constraints.maxWidth > 580) {
                return _DesktopGrid(projects: projects, columns: 2);
              }

              // 📱 MOBILE
              return Column(
                children: projects
                    .map((p) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                         child: GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProjetDetailScreen(
          project: p,
          projectIndex: 0, // 👈 temporaire
        ),
      ),
    );
  },
  child: ProjectFullCard(project: p),
),
                        ))
                    .toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── FILTER BUTTON ─────────────────────────────
  Widget _buildFilter(String label) {
    final isSelected = selectedFilter == label;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedFilter = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? _getStatusColor(label) : kCardBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : kTextSub,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

// ── GRID DESKTOP ─────────────────────────────────────
class _DesktopGrid extends StatelessWidget {
  final List<Project> projects;
  final int columns;

  const _DesktopGrid({
    required this.projects,
    required this.columns,
  });

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];

    for (int i = 0; i < projects.length; i += columns) {
      final rowItems = projects.skip(i).take(columns).toList();

      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int j = 0; j < rowItems.length; j++) ...[
                if (j > 0) const SizedBox(width: 20),
Expanded(
  child: GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProjetDetailScreen(
            project: rowItems[j],
            projectIndex: 0, // simple comme tu veux 👍
          ),
        ),
      );
    },
    child: ProjectFullCard(project: rowItems[j]),
  ),
),              ],
              for (int k = rowItems.length; k < columns; k++) ...[
                const SizedBox(width: 20),
                const Expanded(child: SizedBox()),
              ],
            ],
          ),
        ),
      );

      if (i + columns < projects.length) {
        rows.add(const SizedBox(height: 20));
      }
    }

    return Column(children: rows);
  }
}