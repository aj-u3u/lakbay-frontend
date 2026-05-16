import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../shared/data/groups_data.dart';
import '../../shared/models/group_trip.dart';

class GroupDetailsPage extends ConsumerStatefulWidget {
  final String id;

  const GroupDetailsPage({super.key, required this.id});

  @override
  ConsumerState<GroupDetailsPage> createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends ConsumerState<GroupDetailsPage> {
  String _activeTab = 'itinerary';
  int? _expandedDay = 1;

  @override
  Widget build(BuildContext context) {
    final group = mockGroupTrips.firstWhere(
      (g) => g.id == widget.id,
      orElse: () => throw Exception('Group trip not found'),
    );

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final secondaryColor = colorScheme.secondary;
    final leader = group.members.firstWhere((m) => m.isLeader);
    final teamMembers = group.members.where((m) => !m.isLeader).toList();
    final completedTasks = group.tasks.where((t) => t.completed).length;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Header Image
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            automaticallyImplyLeading: false,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: colorScheme.surface.withValues(alpha: 0.9),
                child: IconButton(
                  icon: Icon(LucideIcons.arrowLeft, color: colorScheme.onSurface, size: 20),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                group.image,
                fit: BoxFit.cover,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(LucideIcons.mapPin, size: 18, color: colorScheme.onSurface.withValues(alpha: 0.6)),
                      const SizedBox(width: 8),
                      Text(
                        group.destination,
                        style: TextStyle(fontSize: 16, color: colorScheme.onSurface.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(LucideIcons.calendar, size: 18, color: colorScheme.onSurface.withValues(alpha: 0.6)),
                      const SizedBox(width: 8),
                      Text(
                        '${DateFormat('MMM d').format(group.startDate)} - ${DateFormat('MMM d, yyyy').format(group.endDate)}',
                        style: TextStyle(fontSize: 16, color: colorScheme.onSurface.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Summary
                  _CardContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trip Summary', 
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)
                        ),
                        const SizedBox(height: 8),
                        Text(
                          group.summary, 
                          style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7), height: 1.5)
                        ),
                      ],
                    ),
                  ),

                  // Members Section
                  _CardContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(LucideIcons.users, size: 20, color: secondaryColor),
                                const SizedBox(width: 10),
                                Text(
                                  'Members (${group.members.length})',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                _SmallIconButton(icon: LucideIcons.userPlus, onTap: () {}),
                                const SizedBox(width: 8),
                                _SmallIconButton(icon: LucideIcons.wallet, onTap: () => _showBudgetModal(context, group)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Leader', 
                          style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 12)
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            CircleAvatar(radius: 20, backgroundImage: NetworkImage(leader.avatar)),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  leader.name, 
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colorScheme.onSurface)
                                ),
                                Text(
                                  'Trip organizer', 
                                  style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12)
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Team', 
                          style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 12)
                        ),
                        const SizedBox(height: 12),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: teamMembers.length,
                          itemBuilder: (context, index) {
                            final m = teamMembers[index];
                            return Row(
                              children: [
                                CircleAvatar(radius: 14, backgroundImage: NetworkImage(m.avatar)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    m.name, 
                                    style: TextStyle(fontSize: 13, color: colorScheme.onSurface), 
                                    overflow: TextOverflow.ellipsis
                                  )
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // Tasks Section
                  _CardContainer(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(LucideIcons.squareCheck, size: 20, color: secondaryColor),
                                const SizedBox(width: 10),
                                Text(
                                  'Tasks ($completedTasks/${group.tasks.length})',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                                ),
                              ],
                            ),
                            _SmallIconButton(icon: LucideIcons.plus, onTap: () {}),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...group.tasks.map((task) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.onSurface.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                task.completed ? LucideIcons.circleCheck : LucideIcons.circle,
                                color: task.completed ? secondaryColor : colorScheme.onSurface.withValues(alpha: 0.3),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task.title,
                                      style: TextStyle(
                                        fontSize: 14,
                                        decoration: task.completed ? TextDecoration.lineThrough : null,
                                        color: task.completed ? colorScheme.onSurface.withValues(alpha: 0.4) : colorScheme.onSurface,
                                      ),
                                    ),
                                    Text(
                                      task.assignedTo, 
                                      style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withValues(alpha: 0.5))
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),

                  // Tabs
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _TabButton(
                          label: 'Itinerary',
                          isActive: _activeTab == 'itinerary',
                          color: secondaryColor,
                          onTap: () => setState(() => _activeTab = 'itinerary'),
                        ),
                        _TabButton(
                          label: 'Route',
                          isActive: _activeTab == 'route',
                          color: secondaryColor,
                          onTap: () => setState(() => _activeTab = 'route'),
                        ),
                        _TabButton(
                          label: 'Transport',
                          isActive: _activeTab == 'transport',
                          color: secondaryColor,
                          onTap: () => setState(() => _activeTab = 'transport'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tab Content
                  if (_activeTab == 'itinerary')
                    ...group.itinerary.map((day) => _GroupItineraryDayCard(
                      day: day,
                      isExpanded: _expandedDay == day.day,
                      onTap: () => setState(() => _expandedDay = _expandedDay == day.day ? null : day.day),
                    )),
                  
                  if (_activeTab == 'route')
                    _CardContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(LucideIcons.navigation, size: 20, color: secondaryColor),
                              const SizedBox(width: 10),
                              Text(
                                'Route Optimization', 
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: colorScheme.onSurface.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(LucideIcons.mapPin, size: 40, color: colorScheme.onSurface.withValues(alpha: 0.2)),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Interactive Map of Mt. Apo', 
                                    style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4))
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (_activeTab == 'transport')
                    ...group.transport.map((t) => _GroupTransportCard(transport: t)),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBudgetModal(BuildContext context, GroupTrip group) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _GroupBudgetModal(group: group),
    );
  }
}

class _SmallIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _SmallIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(
        backgroundColor: secondaryColor.withValues(alpha: 0.1),
        foregroundColor: secondaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _GroupBudgetModal extends StatelessWidget {
  final GroupTrip group;
  const _GroupBudgetModal({required this.group});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final secondaryColor = colorScheme.secondary;
    final progress = group.budget.spent / group.budget.total;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Shared Budget', 
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onSurface)
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context), 
                  icon: Icon(LucideIcons.x, color: colorScheme.onSurface)
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Budget', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5))),
                    Text(
                      '₱${NumberFormat('#,###').format(group.budget.total)}', 
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colorScheme.onSurface)
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Per Person', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5))),
                    Text(
                      '₱${NumberFormat('#,###').format(group.budget.perPerson)}', 
                      style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Spent', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5))),
                    Text(
                      '₱${NumberFormat('#,###').format(group.budget.spent)}', 
                      style: TextStyle(color: secondaryColor, fontWeight: FontWeight.bold)
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 12,
                    backgroundColor: colorScheme.onSurface.withValues(alpha: 0.05),
                    valueColor: AlwaysStoppedAnimation<Color>(secondaryColor),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Member Contributions', 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)
                ),
                const SizedBox(height: 16),
                ...group.members.map((m) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(radius: 20, backgroundImage: NetworkImage(m.avatar)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  m.name, 
                                  style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)
                                ),
                                if (m.isLeader)
                                  Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: secondaryColor.withValues(alpha: 0.1), 
                                      borderRadius: BorderRadius.circular(10)
                                    ),
                                    child: Text(
                                      'Leader', 
                                      style: TextStyle(color: secondaryColor, fontSize: 10, fontWeight: FontWeight.bold)
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Pledged: ₱${NumberFormat('#,###').format(m.contribution)}  •  Spent: ₱${NumberFormat('#,###').format(m.spent)}',
                              style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 32),
                Text(
                  'Expense Breakdown', 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)
                ),
                const SizedBox(height: 16),
                ...group.budget.categories.map((cat) => Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(cat.name, style: TextStyle(fontSize: 14, color: colorScheme.onSurface)),
                          Text(
                            '₱${NumberFormat('#,###').format(cat.amount)}', 
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colorScheme.onSurface)
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: cat.amount / group.budget.total,
                          minHeight: 8,
                          backgroundColor: colorScheme.onSurface.withValues(alpha: 0.05),
                          valueColor: AlwaysStoppedAnimation<Color>(Color(int.parse(cat.color.replaceFirst('#', '0xFF')))),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupItineraryDayCard extends StatelessWidget {
  final GroupItineraryDay day;
  final bool isExpanded;
  final VoidCallback onTap;

  const _GroupItineraryDayCard({required this.day, required this.isExpanded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final secondaryColor = colorScheme.secondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Day ${day.day}', 
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)
                      ),
                      Text(
                        day.title, 
                        style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 14)
                      ),
                    ],
                  ),
                  Icon(
                    isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown, 
                    color: colorScheme.onSurface.withValues(alpha: 0.4)
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: day.activities.map((act) => Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 70,
                        child: Text(act.time, style: TextStyle(color: secondaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(act.activity, style: TextStyle(fontSize: 14, color: colorScheme.onSurface)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(LucideIcons.mapPin, size: 12, color: colorScheme.onSurface.withValues(alpha: 0.4)),
                                const SizedBox(width: 4),
                                Text(
                                  act.location, 
                                  style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 12)
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _GroupTransportCard extends StatelessWidget {
  final GroupTransportInfo transport;
  const _GroupTransportCard({required this.transport});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final secondaryColor = colorScheme.secondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: secondaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(LucideIcons.bus, color: secondaryColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(transport.mode, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                    Text(
                      '${transport.from} → ${transport.to}', 
                      style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12)
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Fare', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 12)),
                    Text(transport.fare, style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Duration', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 12)),
                    Text(transport.duration, style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardContainer extends StatelessWidget {
  final Widget child;
  const _CardContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  const _TabButton({required this.label, required this.isActive, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? color : colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (!isActive) BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : colorScheme.onSurface.withValues(alpha: 0.6),
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
