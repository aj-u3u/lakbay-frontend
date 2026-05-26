import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../shared/data/groups_data.dart';
import '../../shared/models/group_trip.dart';

final groupSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

class GroupPage extends ConsumerWidget {
  const GroupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final secondaryColor = colorScheme.secondary;
    final searchQuery = ref.watch(groupSearchQueryProvider);

    final filteredGroups = mockGroupTrips.where((group) {
      return group.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
             group.destination.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    secondaryColor.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Group Trips',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
                                ],
                              ),
                              child: TextField(
                                onChanged: (val) => ref.read(groupSearchQueryProvider.notifier).state = val,
                                style: TextStyle(color: colorScheme.onSurface),
                                decoration: InputDecoration(
                                  hintText: 'Search group trips...',
                                  hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4)),
                                  prefixIcon: Icon(LucideIcons.search, color: colorScheme.onSurface.withValues(alpha: 0.4)),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
                              ],
                            ),
                            child: IconButton(
                              padding: const EdgeInsets.all(16),
                              icon: Icon(LucideIcons.listFilter, color: colorScheme.onSurface),
                              onPressed: () => context.push('/filter'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => context.push('/ai-planner'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: secondaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(LucideIcons.plus, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Create Trip',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          if (filteredGroups.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: colorScheme.onSurface.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(LucideIcons.users, size: 40, color: colorScheme.onSurface.withValues(alpha: 0.2)),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No group trips yet',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your first group adventure with friends',
                      style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final group = filteredGroups[index];
                    return _GroupCard(group: group);
                  },
                  childCount: filteredGroups.length,
                ),
              ),
            ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final GroupTrip group;

  const _GroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final secondaryColor = colorScheme.secondary;
    final dateFormatter = DateFormat('MMM d');
    final yearFormatter = DateFormat('yyyy');

    return GestureDetector(
      onTap: () => context.push('/group/${group.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                group.image,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(LucideIcons.calendar, size: 16, color: colorScheme.onSurface.withValues(alpha: 0.4)),
                      const SizedBox(width: 8),
                      Text(
                        '${dateFormatter.format(group.startDate)} - ${dateFormatter.format(group.endDate)}, ${yearFormatter.format(group.endDate)}',
                        style: TextStyle(fontSize: 14, color: colorScheme.onSurface.withValues(alpha: 0.4)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(LucideIcons.users, size: 16, color: colorScheme.onSurface.withValues(alpha: 0.4)),
                      const SizedBox(width: 8),
                      Text(
                        '${group.members.length} members',
                        style: TextStyle(fontSize: 14, color: colorScheme.onSurface.withValues(alpha: 0.4)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    group.summary,
                    style: TextStyle(fontSize: 14, color: colorScheme.onSurface.withValues(alpha: 0.7), height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Total: ',
                            style: TextStyle(fontSize: 14, color: colorScheme.onSurface.withValues(alpha: 0.4)),
                          ),
                          Text(
                            '₱${NumberFormat('#,###').format(group.budget.total)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: secondaryColor,
                            ),
                          ),
                        ],
                      ),
                      Icon(LucideIcons.chevronRight, size: 20, color: colorScheme.onSurface.withValues(alpha: 0.3)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
