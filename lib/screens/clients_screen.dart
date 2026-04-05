import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/colors.dart';
import '../models/client.dart';
import '../widgets/client_card.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final pad = isMobile ? 16.0 : 28.0;

    // 🔍 FILTRE
    final filteredClients = sampleClients.where((c) {
      final name = c.nom.toLowerCase();
      final email = c.email.toLowerCase();
      return name.contains(searchQuery.toLowerCase()) ||
          email.contains(searchQuery.toLowerCase());
    }).toList();

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
                    'Clients',
                    style: TextStyle(
                      fontSize: isMobile ? 24 : 28,
                      fontWeight: FontWeight.w800,
                      color: kTextMain,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.userPlus,
                      size: 15, color: Colors.white),
                  label: Text(
                    isMobile ? 'Nouveau' : 'Nouveau client',
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

            const SizedBox(height: 4),

            Text(
              'Gérez votre base de clients et leurs accès',
              style: TextStyle(
                color: kTextSub,
                fontSize: isMobile ? 12 : 14,
              ),
            ),

            const SizedBox(height: 20),

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
                  hintText: "Rechercher un client...",
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── LISTE CLIENTS ─────────────────────
            LayoutBuilder(builder: (context, constraints) {
              // 📱 MOBILE
              if (constraints.maxWidth < 580) {
                return Column(
                  children: filteredClients
                      .map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: ClientCard(client: c),
                          ))
                      .toList(),
                );
              }

              // 💻 DESKTOP
              final rows = <Widget>[];
              for (int i = 0; i < filteredClients.length; i += 2) {
                final rowItems = filteredClients.skip(i).take(2).toList();

                rows.add(
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(child: ClientCard(client: rowItems[0])),
                        const SizedBox(width: 20),
                        if (rowItems.length > 1)
                          Expanded(child: ClientCard(client: rowItems[1]))
                        else
                          const Expanded(child: SizedBox()),
                      ],
                    ),
                  ),
                );

                if (i + 2 < filteredClients.length) {
                  rows.add(const SizedBox(height: 20));
                }
              }

              return Column(children: rows);
            }),
          ],
        ),
      ),
    );
  }
}