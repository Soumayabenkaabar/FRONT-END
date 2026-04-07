import 'package:archi_manager/models/project.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:archi_manager/constants/colors.dart';

import 'package:archi_manager/models/document.dart';
import 'package:archi_manager/models/facture.dart' hide Commentaire;
import 'package:archi_manager/models/commentaire.dart';
import 'package:archi_manager/Service/portal_service.dart';
import 'client_login_screen.dart';

class ClientPortalScreen extends StatefulWidget {
  const ClientPortalScreen({super.key});

  @override
  State<ClientPortalScreen> createState() => _ClientPortalScreenState();
}

class _ClientPortalScreenState extends State<ClientPortalScreen> {
  List<Project> _projets   = [];
  bool _loading           = true;
  int _selectedProjetIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProjets();
  }

  Future<void> _loadProjets() async {
    try {
      final data = await PortalService.getProjets();
      setState(() {
        _projets = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    await PortalService.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ClientLoginScreen()),
      );
    }
  }

  Project? get _currentProjet =>
      _projets.isNotEmpty ? _projets[_selectedProjetIndex] : null;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: _buildAppBar(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _projets.isEmpty
              ? _buildEmpty()
              : isMobile
                  ? _buildMobileLayout()
                  : _buildDesktopLayout(),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 20,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: kAccent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(LucideIcons.building2,
                color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          const Text('Mon Espace',
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: Color(0xFF111827))),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Row(
            children: [
              // Email connecté
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: kAccent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.user,
                        size: 12, color: kAccent),
                    const SizedBox(width: 6),
                    Text(
                      PortalService.currentEmail,
                      style: TextStyle(
                          fontSize: 12,
                          color: kAccent,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Déconnexion
              IconButton(
                icon: const Icon(LucideIcons.logOut,
                    size: 18, color: Color(0xFF6B7280)),
                tooltip: 'Déconnexion',
                onPressed: _logout,
              ),
            ],
          ),
        ),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: Color(0xFFE5E7EB)),
      ),
    );
  }

  // ── Layout Desktop ────────────────────────────────────────────────────────
  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sidebar projets
        Container(
          width: 240,
          color: Colors.white,
          child: _buildProjetSidebar(),
        ),
        const VerticalDivider(width: 1, color: Color(0xFFE5E7EB)),
        // Contenu
        Expanded(child: _buildProjetDetail(_currentProjet!)),
      ],
    );
  }

  // ── Layout Mobile ─────────────────────────────────────────────────────────
  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Sélecteur projet horizontal
        Container(
          color: Colors.white,
          height: 56,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: _projets.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final selected = i == _selectedProjetIndex;
              return GestureDetector(
                onTap: () => setState(() => _selectedProjetIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected ? kAccent : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _projets[i].titre,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : const Color(0xFF374151),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE5E7EB)),
        Expanded(child: _buildProjetDetail(_currentProjet!)),
      ],
    );
  }

  // ── Sidebar projets ───────────────────────────────────────────────────────
  Widget _buildProjetSidebar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text('MES PROJETS',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF9CA3AF),
                  letterSpacing: 1)),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _projets.length,
            itemBuilder: (context, i) {
              final p = _projets[i];
              final selected = i == _selectedProjetIndex;
              return GestureDetector(
                onTap: () => setState(() => _selectedProjetIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected
                        ? kAccent.withOpacity(0.08)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _statutColor(p.statut),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.titre,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: selected
                                        ? kAccent
                                        : const Color(0xFF111827)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            Text('${p.avancement}%',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF9CA3AF))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Détail projet ─────────────────────────────────────────────────────────
  Widget _buildProjetDetail(Project projet) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          // Header projet
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(projet.titre,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF111827))),
                          if (projet.description.isNotEmpty)
                            Text(projet.description,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF6B7280))),
                        ],
                      ),
                    ),
                    _StatutBadge(statut: projet.statut),
                  ],
                ),
                const SizedBox(height: 12),
                // Barre avancement
                _AvancementBar(avancement: projet.avancement),
                const SizedBox(height: 14),
                // Tabs
                TabBar(
                  labelColor: kAccent,
                  unselectedLabelColor: const Color(0xFF9CA3AF),
                  indicatorColor: kAccent,
                  indicatorWeight: 2,
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                  tabs: const [
                    Tab(text: 'Suivi'),
                    Tab(text: 'Documents'),
                    Tab(text: 'Factures'),
                    Tab(text: 'Commentaires'),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          // Tab content
          Expanded(
            child: TabBarView(
              children: [
                _SuiviTab(projet: projet),
                _DocumentsTab(projetId: projet.id),
                _FacturesTab(projetId: projet.id),
                _CommentairesTab(
                  projetId: projet.id,
                  clientEmail: PortalService.currentEmail,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.folderOpen,
              size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('Aucun projet pour le moment',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280))),
          const SizedBox(height: 6),
          const Text('Votre architecte n\'a pas encore créé de projets.',
              style:
                  TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
        ],
      ),
    );
  }

  Color _statutColor(String statut) {
    switch (statut) {
      case 'en_cours':   return kAccent;
      case 'termine':    return kGreen;
      case 'en_attente': return kWarning;
      case 'annule':     return kRed;
      default:           return Colors.grey;
    }
  }
}

// ── Tab : Suivi ───────────────────────────────────────────────────────────────
class _SuiviTab extends StatelessWidget {
  final Project projet;
  const _SuiviTab({required this.projet});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Étapes visuelles basées sur l'avancement
          const Text('Étapes du projet',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Color(0xFF111827))),
          const SizedBox(height: 16),
          _EtapeItem(
              label: 'Dossier initial',
              done: projet.avancement >= 10,
              active: projet.avancement < 10),
          _EtapeItem(
              label: 'Avant-projet (APS/APD)',
              done: projet.avancement >= 30,
              active: projet.avancement >= 10 && projet.avancement < 30),
          _EtapeItem(
              label: 'Dépôt permis de construire',
              done: projet.avancement >= 50,
              active: projet.avancement >= 30 && projet.avancement < 50),
          _EtapeItem(
              label: 'Travaux en cours',
              done: projet.avancement >= 80,
              active: projet.avancement >= 50 && projet.avancement < 80),
          _EtapeItem(
              label: 'Réception des travaux',
              done: projet.avancement >= 100,
              active: projet.avancement >= 80 && projet.avancement < 100,
              isLast: true),

          const SizedBox(height: 24),

          // Dates
          if (projet.dateDebut != null || projet.dateFin != null)
            Row(
              children: [
                if (projet.dateDebut != null)
                  Expanded(
                    child: _InfoCard(
                      icon: LucideIcons.calendarCheck,
                      label: 'Début',
                      value: projet.dateDebut!,
                    ),
                  ),
                if (projet.dateDebut != null && projet.dateFin != null)
                  const SizedBox(width: 12),
                if (projet.dateFin != null)
                  Expanded(
                    child: _InfoCard(
                      icon: LucideIcons.calendarClock,
                      label: 'Fin prévue',
                      value: projet.dateFin!,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

// ── Tab : Documents ───────────────────────────────────────────────────────────
class _DocumentsTab extends StatefulWidget {
  final String projetId;
  const _DocumentsTab({required this.projetId});

  @override
  State<_DocumentsTab> createState() => _DocumentsTabState();
}

class _DocumentsTabState extends State<_DocumentsTab> {
  List<Document> _docs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await PortalService.getDocuments(widget.projetId);
    setState(() { _docs = data; _loading = false; });
  }

  IconData _docIcon(String type) {
    switch (type) {
      case 'pdf':  return LucideIcons.fileText;
      case 'dwg':  return LucideIcons.ruler;
      case 'img':  return LucideIcons.image;
      default:     return LucideIcons.file;
    }
  }

  Color _docColor(String type) {
    switch (type) {
      case 'pdf':  return kRed;
      case 'dwg':  return kAccent;
      case 'img':  return kGreen;
      default:     return kWarning;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_docs.isEmpty) return _emptyState('Aucun document disponible');

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _docs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final d = _docs[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _docColor(d.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_docIcon(d.type),
                    size: 18, color: _docColor(d.type)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.nom,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Color(0xFF111827))),
                    if (d.tailleKb != null)
                      Text('${d.tailleKb} KB',
                          style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF9CA3AF))),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(LucideIcons.download,
                    size: 18, color: kAccent),
                tooltip: 'Télécharger',
                onPressed: () async {
                  final uri = Uri.parse(d.url);
                  if (await canLaunchUrl(uri)) launchUrl(uri);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Tab : Factures ────────────────────────────────────────────────────────────
class _FacturesTab extends StatefulWidget {
  final String projetId;
  const _FacturesTab({required this.projetId});

  @override
  State<_FacturesTab> createState() => _FacturesTabState();
}

class _FacturesTabState extends State<_FacturesTab> {
  List<Facture> _factures = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await PortalService.getFactures(widget.projetId);
    setState(() { _factures = data; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_factures.isEmpty) return _emptyState('Aucune facture disponible');

    // Total
    final total = _factures.fold<double>(0, (s, f) => s + f.montant);
    final payees = _factures.where((f) => f.statut == 'payee')
        .fold<double>(0, (s, f) => s + f.montant);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Résumé
          Row(
            children: [
              Expanded(
                child: _InfoCard(
                  icon: LucideIcons.receipt,
                  label: 'Total',
                  value: '${total.toStringAsFixed(0)} DT',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoCard(
                  icon: LucideIcons.checkCircle,
                  label: 'Payé',
                  value: '${payees.toStringAsFixed(0)} DT',
                  valueColor: kGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Liste
          ...(_factures.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(f.numero,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: Color(0xFF111827))),
                        if (f.dateEcheance != null)
                          Text('Échéance : ${f.dateEcheance}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF9CA3AF))),
                      ],
                    ),
                  ),
                  Text(
                    '${f.montant.toStringAsFixed(0)} DT',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF111827)),
                  ),
                  const SizedBox(width: 10),
                  _FactureBadge(statut: f.statut),
                ],
              ),
            ),
          ))),
        ],
      ),
    );
  }
}

// ── Tab : Commentaires ────────────────────────────────────────────────────────
class _CommentairesTab extends StatefulWidget {
  final String projetId;
  final String clientEmail;
  const _CommentairesTab(
      {required this.projetId, required this.clientEmail});

  @override
  State<_CommentairesTab> createState() => _CommentairesTabState();
}

class _CommentairesTabState extends State<_CommentairesTab> {
  List<Commentaire> _comments = [];
  bool _loading  = true;
  bool _sending  = false;
  final _ctrl    = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await PortalService.getCommentaires(widget.projetId);
    setState(() { _comments = data; _loading = false; });
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    await PortalService.addCommentaire(Commentaire(
      id: '',
      projetId: widget.projetId,
      auteur: widget.clientEmail,
      role: 'client',
      contenu: text,
      createdAt: '',
    ));
    _ctrl.clear();
    await _load();
    setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        Expanded(
          child: _comments.isEmpty
              ? _emptyState('Aucun commentaire. Soyez le premier !')
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _comments.length,
                  itemBuilder: (_, i) {
                    final c = _comments[i];
                    final isClient = c.role == 'client';
                    return Align(
                      alignment: isClient
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isClient
                              ? kAccent.withOpacity(0.1)
                              : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(14),
                            topRight: const Radius.circular(14),
                            bottomLeft: Radius.circular(isClient ? 14 : 4),
                            bottomRight: Radius.circular(isClient ? 4 : 14),
                          ),
                          border: Border.all(
                            color: isClient
                                ? kAccent.withOpacity(0.2)
                                : const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.auteur,
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isClient
                                        ? kAccent
                                        : const Color(0xFF374151))),
                            const SizedBox(height: 4),
                            Text(c.contenu,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF111827))),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        // Champ envoi
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  minLines: 1,
                  maxLines: 4,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Écrire un commentaire...',
                    hintStyle:
                        const TextStyle(color: Color(0xFFD1D5DB)),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: kAccent, width: 2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _sending ? null : _send,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: kAccent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _sending
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(LucideIcons.send,
                          size: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Widgets communs ───────────────────────────────────────────────────────────

class _AvancementBar extends StatelessWidget {
  final int avancement;
  const _AvancementBar({required this.avancement});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Avancement',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280))),
            Text('$avancement%',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: kAccent)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: avancement / 100,
            backgroundColor: const Color(0xFFE5E7EB),
            valueColor: AlwaysStoppedAnimation<Color>(kAccent),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

class _StatutBadge extends StatelessWidget {
  final String statut;
  const _StatutBadge({required this.statut});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (statut) {
      case 'en_cours':   color = kAccent;   label = 'En cours';   break;
      case 'termine':    color = kGreen;    label = 'Terminé';    break;
      case 'en_attente': color = kWarning;  label = 'En attente'; break;
      case 'annule':     color = kRed;      label = 'Annulé';     break;
      default:           color = Colors.grey; label = statut;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color)),
    );
  }
}

class _FactureBadge extends StatelessWidget {
  final String statut;
  const _FactureBadge({required this.statut});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (statut) {
      case 'payee':       color = kGreen;   label = 'Payée';      break;
      case 'en_retard':   color = kRed;     label = 'En retard';  break;
      default:            color = kWarning; label = 'En attente';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color)),
    );
  }
}

class _EtapeItem extends StatelessWidget {
  final String label;
  final bool done;
  final bool active;
  final bool isLast;

  const _EtapeItem({
    required this.label,
    required this.done,
    this.active = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indicateur + ligne
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: done
                        ? kGreen
                        : active
                            ? kAccent
                            : const Color(0xFFE5E7EB),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    done ? LucideIcons.check : LucideIcons.circle,
                    size: 10,
                    color: done || active ? Colors.white : const Color(0xFFD1D5DB),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: done
                          ? kGreen.withOpacity(0.3)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16, top: 1),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      active ? FontWeight.w700 : FontWeight.w500,
                  color: done
                      ? kGreen
                      : active
                          ? kAccent
                          : const Color(0xFF9CA3AF),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF9CA3AF)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF9CA3AF))),
              Text(value,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: valueColor ?? const Color(0xFF111827))),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _emptyState(String msg) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(LucideIcons.inbox, size: 36, color: Colors.grey.shade300),
        const SizedBox(height: 10),
        Text(msg,
            style: const TextStyle(
                fontSize: 13, color: Color(0xFF9CA3AF))),
      ],
    ),
  );
}