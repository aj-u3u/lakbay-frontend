import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lakbay_plus/app/api_service.dart';
import 'package:lakbay_plus/shared/widgets/destination_map_widget.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/destination.dart';

class DestinationPreviewModal extends ConsumerWidget {
  final Destination destination;

  const DestinationPreviewModal({super.key, required this.destination});

  static void show(BuildContext context, Destination destination) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DestinationPreviewModal(destination: destination),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;
    final token = ref.watch(authTokenProvider);
    final isGuest = token == null;

    // Compute accommodation starting price
    String? accommodationTeaser;
    if (destination.accommodations != null &&
        destination.accommodations!.isNotEmpty) {
      accommodationTeaser =
          'Starting from ${destination.accommodations!.first.price}';
    }

    // Compute activity price range
    String? activityTeaser;
    if (destination.activityPrices != null &&
        destination.activityPrices!.isNotEmpty) {
      activityTeaser =
          '${destination.activityPrices!.length} activities available';
    }

    // Travel highlights from categories and best time
    final highlights = <String>[];
    for (final cat in destination.category) {
      highlights.add(cat[0].toUpperCase() + cat.substring(1));
    }
    if (highlights.length > 3) highlights.length = 3;

    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Quick Preview',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      if (isGuest) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.eye, size: 12,
                                  color: Colors.orange),
                              SizedBox(width: 4),
                              Text(
                                'Guest View',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  IconButton(
                    icon: Icon(LucideIcons.x, color: colorScheme.onSurface),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            Divider(
                height: 1,
                color: colorScheme.outline.withValues(alpha: 0.1)),

            // Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero image
                    Stack(
                      children: [
                        Container(
                          height: 220,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              image: NetworkImage(destination.image),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Rating badge
                        Positioned(
                          top: 14,
                          right: 14,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(LucideIcons.star,
                                    size: 14, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(
                                  destination.rating.toString(),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Category chips bottom
                        Positioned(
                          bottom: 14,
                          left: 14,
                          child: Row(
                            children: highlights
                                .map((h) => Container(
                                      margin: const EdgeInsets.only(right: 6),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.black
                                            .withValues(alpha: 0.6),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        h,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Name
                    Text(
                      destination.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Meta info row
                    Row(
                      children: [
                        Icon(LucideIcons.mapPin,
                            size: 16,
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.5)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            destination.location,
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(LucideIcons.clock,
                            size: 16,
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.5)),
                        const SizedBox(width: 6),
                        Text(
                          destination.estimatedTravelTime.length > 20
                              ? destination.estimatedTravelTime
                                  .substring(0, 20)
                              : destination.estimatedTravelTime,
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Description teaser
                    Text(
                      destination.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Travel Highlights strip
                    _SectionLabel(label: '✨ Travel Highlights', primary: primaryColor),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _HighlightChip(
                          icon: LucideIcons.calendar,
                          label: 'Best: ${destination.bestTimeToVisit.length > 30 ? destination.bestTimeToVisit.substring(0, 30) + '…' : destination.bestTimeToVisit}',
                          color: primaryColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: destination.activities.take(4).map((act) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: primaryColor.withValues(alpha: 0.2)),
                          ),
                          child: Text(
                            act,
                            style: TextStyle(
                                fontSize: 12, color: primaryColor),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Accommodation & Pricing snapshot
                    Row(
                      children: [
                        if (accommodationTeaser != null)
                          Expanded(
                            child: _SnapshotCard(
                              icon: LucideIcons.building2,
                              label: 'Accommodation',
                              value: accommodationTeaser,
                              color: const Color(0xFF0EA5E9),
                            ),
                          ),
                        if (accommodationTeaser != null &&
                            activityTeaser != null)
                          const SizedBox(width: 10),
                        if (activityTeaser != null)
                          Expanded(
                            child: _SnapshotCard(
                              icon: LucideIcons.star,
                              label: 'Activities',
                              value: activityTeaser,
                              color: const Color(0xFFF59E0B),
                            ),
                          ),
                        if (accommodationTeaser == null &&
                            activityTeaser == null)
                          Expanded(
                            child: _SnapshotCard(
                              icon: LucideIcons.philippinePeso,
                              label: 'Entrance Fee',
                              value: destination.entranceFee,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Map
                    _SectionLabel(label: '📍 Location Map', primary: primaryColor),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        height: 200,
                        child: DestinationMapWidget(
                          destinationName: destination.name,
                          coordinates: LatLng(
                            destination.coordinates.lat,
                            destination.coordinates.lng,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Guest lock banner
                    if (isGuest) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: colorScheme.onSurface.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color:
                                  colorScheme.outline.withValues(alpha: 0.12)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color:
                                    primaryColor.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(LucideIcons.lock,
                                  size: 18, color: primaryColor),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sign in for the full experience',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Accommodations, budget tools & AI planning',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colorScheme.onSurface
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // View Full Details button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          if (isGuest) {
                            context.push(
                              '/login?redirect=${Uri.encodeComponent('/destination/${destination.id}')}',
                            );
                          } else {
                            context.push('/destination/${destination.id}');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isGuest ? LucideIcons.lock : LucideIcons.mapPin,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              isGuest
                                  ? 'Sign In to View Full Details'
                                  : 'View Full Details',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(LucideIcons.chevronRight, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
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

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color primary;

  const _SectionLabel({required this.label, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

class _HighlightChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _HighlightChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _SnapshotCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SnapshotCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
