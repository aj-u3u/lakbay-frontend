import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/planner_models.dart';

class ItineraryPreviewModal extends StatelessWidget {
  final PlannerItineraryPlan plan;
  final VoidCallback onSelect;
  final bool isGroupTrip;

  const ItineraryPreviewModal({
    super.key,
    required this.plan,
    required this.onSelect,
    this.isGroupTrip = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accentColor = isGroupTrip ? colorScheme.secondary : colorScheme.primary;
    final onAccentColor = isGroupTrip ? colorScheme.onSecondary : colorScheme.onPrimary;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.title,
                        style: TextStyle(color: onAccentColor, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${plan.duration} • ${plan.totalCost}',
                        style: TextStyle(color: onAccentColor.withValues(alpha: 0.8), fontSize: 14),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(LucideIcons.x, color: onAccentColor),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // Highlights
                _SectionHeader(icon: LucideIcons.star, title: 'Highlights', color: accentColor),
                const SizedBox(height: 12),
                ...plan.highlights.map((h) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('•', style: TextStyle(color: accentColor, fontSize: 18)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          h, 
                          style: TextStyle(fontSize: 14, color: colorScheme.onSurface)
                        )
                      ),
                    ],
                  ),
                )),

                const SizedBox(height: 32),

                // Cost Breakdown
                _SectionHeader(icon: LucideIcons.dollarSign, title: 'Cost Breakdown', color: accentColor),
                const SizedBox(height: 16),
                ...plan.costBreakdown.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.category, 
                        style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 14)
                      ),
                      Text(
                        item.amount, 
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: colorScheme.onSurface)
                      ),
                    ],
                  ),
                )),
                Divider(height: 32, color: colorScheme.outline.withValues(alpha: 0.1)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total', 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.onSurface)
                    ),
                    Text(
                      plan.totalCost, 
                      style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 16)
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Itinerary
                _SectionHeader(icon: LucideIcons.mapPin, title: 'Day-by-Day Itinerary', color: accentColor),
                const SizedBox(height: 20),
                ...plan.itinerary.map((day) => Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DAY ${day.day}',
                        style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        day.title, 
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface)
                      ),
                      const SizedBox(height: 16),
                      ...day.activities.map((act) => _ActivityItem(activity: act, color: accentColor)),
                    ],
                  ),
                )),
              ],
            ),
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.all(24),
            child: ElevatedButton(
              onPressed: onSelect,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: onAccentColor,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Select This Plan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _SectionHeader({required this.icon, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 10),
        Text(
          title, 
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)
        ),
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final PlannerActivity activity;
  final Color color;

  const _ActivityItem({required this.activity, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.only(left: 20, bottom: 20),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1), width: 2)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -27,
            top: 2,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.clock, size: 14, color: colorScheme.onSurface.withValues(alpha: 0.4)),
                  const SizedBox(width: 6),
                  Text(
                    activity.time, 
                    style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 12)
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                activity.activity, 
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colorScheme.onSurface)
              ),
              Text(
                activity.location, 
                style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 12)
              ),
            ],
          ),
        ],
      ),
    );
  }
}
