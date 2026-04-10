import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/colors.dart';
import '../models/notification.dart';

class NotificationsScreen extends StatefulWidget {
  final VoidCallback? onNotifChanged;
  const NotificationsScreen({super.key, this.onNotifChanged});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<AppNotification> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = List.from(sampleNotifications);
  }

  void _markAllRead() {
    setState(() {
      for (final n in _notifications) n.lue = true;
      for (final n in sampleNotifications) n.lue = true;
    });
    widget.onNotifChanged?.call();
  }

  void _markRead(String id) {
    setState(() {
      _notifications.firstWhere((n) => n.id == id).lue = true;
      sampleNotifications.firstWhere((n) => n.id == id).lue = true;
    });
    widget.onNotifChanged?.call();
  }

  void _delete(String id) {
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
      sampleNotifications.removeWhere((n) => n.id == id);
    });
    widget.onNotifChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final pad = isMobile ? 16.0 : 28.0;

    final nonLues = _notifications.where((n) => !n.lue).toList();
    final lues = _notifications.where((n) => n.lue).toList();
    final nbBudget = _notifications
        .where((n) => n.type == NotifType.budget && !n.lue)
        .length;
    final nbRetard = _notifications
        .where((n) => n.type == NotifType.retard && !n.lue)
        .length;

    return Container(
      color: kBg,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(pad, pad, pad, pad + 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Centre de notifications',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: kTextMain,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Restez informé des alertes et activités importantes',
                        style: TextStyle(color: kTextSub, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                // Bouton tout marquer comme lu
                if (nonLues.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: _markAllRead,
                    icon: const Icon(
                      LucideIcons.checkCircle,
                      size: 14,
                      color: kAccent,
                    ),
                    label: Text(
                      isMobile ? 'Tout lu' : 'Tout marquer comme lu',
                      style: const TextStyle(
                        color: kAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 10 : 14,
                        vertical: isMobile ? 8 : 10,
                      ),
                      side: const BorderSide(color: kAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 24),

            // ── KPI Stats ────────────────────────────────────────────────
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Non lues',
                      value: '${nonLues.length}',
                      icon: Icons.warning_amber_rounded,
                      borderColor: kRed,
                      iconColor: kRed,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _StatCard(
                      label: 'Alertes \nbudget',
                      value: '$nbBudget',
                      icon: Icons.attach_money_rounded,
                      borderColor: kAccent,
                      iconColor: kAccent,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _StatCard(
                      label: 'Alertes \nretard',
                      value: '$nbRetard',
                      icon: Icons.access_time_rounded,
                      borderColor: kAccent,
                      iconColor: kAccent,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Notifications non lues ───────────────────────────────────
            if (nonLues.isNotEmpty) ...[
              Row(
                children: const [
                  Icon(Icons.warning_amber_rounded, color: kRed, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Notifications non lues',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: kTextMain,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ...nonLues.map(
                (n) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _NotifCard(
                    notif: n,
                    onMarkRead: () => _markRead(n.id),
                    onDelete: () => _delete(n.id),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ── Notifications lues ───────────────────────────────────────
            if (lues.isNotEmpty) ...[
              Row(
                children: const [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    color: kTextSub,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Notifications lues',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: kTextMain,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ...lues.map(
                (n) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _NotifCard(
                    notif: n,
                    onMarkRead: null,
                    onDelete: () => _delete(n.id),
                  ),
                ),
              ),
            ],

            // ── Vide ─────────────────────────────────────────────────────
            if (_notifications.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: Column(
                    children: const [
                      Icon(LucideIcons.bellOff, size: 48, color: kTextSub),
                      SizedBox(height: 12),
                      Text(
                        'Aucune notification',
                        style: TextStyle(
                          color: kTextSub,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

// ─── Stat Card ────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color borderColor;
  final Color iconColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.borderColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 18),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: borderColor, width: 3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: kTextSub,
                    fontSize: isMobile ? 11 : 13,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, color: iconColor, size: isMobile ? 16 : 20),
            ],
          ),
          SizedBox(height: isMobile ? 8 : 10),
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 22 : 28,
              fontWeight: FontWeight.w800,
              color: kTextMain,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Notification Card ────────────────────────────────────────────────────────
class _NotifCard extends StatelessWidget {
  final AppNotification notif;
  final VoidCallback? onMarkRead;
  final VoidCallback onDelete;

  const _NotifCard({
    required this.notif,
    required this.onMarkRead,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isLue = notif.lue;

    return Container(
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: isLue ? const Color(0xFFE5E7EB) : notif.typeColor,
            width: 3,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isLue ? 0.02 : 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icône type
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: notif.typeColor.withOpacity(isLue ? 0.08 : 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                notif.typeIcon,
                color: isLue
                    ? notif.typeColor.withOpacity(0.5)
                    : notif.typeColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 14),

            // Contenu
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge type
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: notif.typeColor.withOpacity(isLue ? 0.08 : 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      notif.typeLabel,
                      style: TextStyle(
                        color: isLue
                            ? notif.typeColor.withOpacity(0.6)
                            : notif.typeColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Message
                  Text(
                    notif.message,
                    style: TextStyle(
                      color: isLue ? kTextSub : kTextMain,
                      fontSize: 13,
                      fontWeight: isLue ? FontWeight.w400 : FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Projet
                  Text(
                    '— ${notif.projet}',
                    style: TextStyle(
                      color: isLue ? kTextSub : kAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Date · Heure
                  Row(
                    children: [
                      Text(
                        notif.date,
                        style: const TextStyle(color: kTextSub, fontSize: 11),
                      ),
                      if (notif.heure.isNotEmpty) ...[
                        const Text(
                          ' • ',
                          style: TextStyle(color: kTextSub, fontSize: 11),
                        ),
                        Text(
                          notif.heure,
                          style: const TextStyle(color: kTextSub, fontSize: 11),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Actions
            Column(
              children: [
                // Marquer comme lu
                if (onMarkRead != null)
                  GestureDetector(
                    onTap: onMarkRead,
                    child: Tooltip(
                      message: 'Marquer comme lu',
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: kBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 18,
                          color: kTextSub,
                        ),
                      ),
                    ),
                  ),
                if (onMarkRead != null) const SizedBox(height: 6),

                // Supprimer
                GestureDetector(
                  onTap: onDelete,
                  child: Tooltip(
                    message: 'Supprimer',
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: kBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        size: 18,
                        color: kRed,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
