import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../shared/providers/notification_provider.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        title: Text('Notifications', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: () => ref.read(notificationsProvider.notifier).markAllAsRead(),
              child: Text('Mark all as read', style: TextStyle(color: colorScheme.primary)),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.bellOff, size: 64, color: colorScheme.onSurface.withValues(alpha: 0.1)),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final n = notifications[index];
                return InkWell(
                  onTap: () => ref.read(notificationsProvider.notifier).markAsRead(n.id),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: n.isRead 
                        ? colorScheme.surface.withValues(alpha: 0.5)
                        : colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: n.isRead ? Colors.transparent : colorScheme.primary.withValues(alpha: 0.2),
                      ),
                      boxShadow: [
                        if (!n.isRead)
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: n.isRead 
                              ? colorScheme.onSurface.withValues(alpha: 0.05)
                              : colorScheme.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            n.isRead ? LucideIcons.bell : LucideIcons.bellDot,
                            color: n.isRead ? colorScheme.onSurface.withValues(alpha: 0.3) : colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    n.title,
                                    style: TextStyle(
                                      fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold,
                                      fontSize: 16,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    DateFormat.jm().format(n.timestamp),
                                    style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                n.message,
                                style: TextStyle(
                                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                DateFormat('MMM d, yyyy').format(n.timestamp),
                                style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.3), fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
