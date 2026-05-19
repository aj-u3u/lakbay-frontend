import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lakbay_plus/shared/widgets/destination_map_widget.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../shared/data/destinations_data.dart';
import '../../shared/models/destination.dart';

class DestinationDetailsPage extends StatelessWidget {
  final String id;

  const DestinationDetailsPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final destination = destinations.firstWhere(
      (d) => d.id == id,
      orElse: () => throw Exception('Destination not found'),
    );

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Header Image with Back button
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: colorScheme.surface,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: colorScheme.surface.withValues(alpha: 0.9),
                child: IconButton(
                  icon: Icon(
                    LucideIcons.arrowLeft,
                    color: colorScheme.onSurface,
                    size: 20,
                  ),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(destination.image, fit: BoxFit.cover),
                  Positioned(
                    top: 50,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            LucideIcons.star,
                            size: 18,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            destination.rating.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 1. Destination Name (not in a card)
                Text(
                  destination.name,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),

                // 2. Location (not in a card)
                Row(
                  children: [
                    Icon(
                      LucideIcons.mapPin,
                      size: 18,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        destination.location,
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 3. Operating Hours (in a card)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(LucideIcons.clock, color: primaryColor, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildOperatingHoursContent(
                          destination.operatingHours,
                          colorScheme,
                          TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                            fontSize: 15,
                          ),
                          TextStyle(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 4. About / Description (in a card)
                _buildCard(
                  context: context,
                  icon: LucideIcons.info,
                  title: 'About',
                  child: Text(
                    destination.description,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),

                // 5. Budget Breakdown (in a card)
                _buildCard(
                  context: context,
                  icon: LucideIcons.wallet,
                  title: 'Budget Breakdown',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ENTRANCE FEE',
                        style: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        destination.entranceFee,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Divider(color: colorScheme.outline.withValues(alpha: 0.15)),
                      const SizedBox(height: 12),
                      Text(
                        'OVERNIGHT FEE',
                        style: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        destination.overnightFee ?? 'Not required / N/A',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),

                // 6. Accommodation Options (in a card)
                _buildCard(
                  context: context,
                  icon: Icons.hotel,
                  title: 'Accommodation Options',
                  child: destination.accommodations != null &&
                          destination.accommodations!.isNotEmpty
                      ? Column(
                          children: destination.accommodations!.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final acc = entry.value;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  acc.type,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  acc.price,
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  acc.description,
                                  style: TextStyle(
                                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                                    fontSize: 13,
                                  ),
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                ),
                                if (idx < destination.accommodations!.length - 1) ...[
                                  const SizedBox(height: 12),
                                  Divider(color: colorScheme.outline.withValues(alpha: 0.15)),
                                  const SizedBox(height: 12),
                                ],
                              ],
                            );
                          }).toList(),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'No accommodation available',
                            style: TextStyle(
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                              fontSize: 14,
                            ),
                          ),
                        ),
                ),

                // 7. Meal Inclusions (in a card) - Moved here below Accommodation Options
                _buildCard(
                  context: context,
                  icon: LucideIcons.utensils,
                  title: 'Meal Inclusions',
                  child: Text(
                    destination.mealInclusions,
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                  ),
                ),

                // 8. Activity Prices (in a card)
                _buildCard(
                  context: context,
                  icon: LucideIcons.star,
                  title: 'Activity Prices',
                  child: destination.activityPrices != null &&
                          destination.activityPrices!.isNotEmpty
                      ? Column(
                          children: destination.activityPrices!.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final ap = entry.value;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ap.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${ap.price} ${ap.isPerPerson ? '/ person' : '/ group'}',
                                  style: TextStyle(
                                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                                    fontSize: 14,
                                  ),
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                ),
                                if (idx < destination.activityPrices!.length - 1) ...[
                                  const SizedBox(height: 12),
                                  Divider(color: colorScheme.outline.withValues(alpha: 0.15)),
                                  const SizedBox(height: 12),
                                ],
                              ],
                            );
                          }).toList(),
                        )
                      : Text(
                          'Free / Included',
                          style: TextStyle(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                            fontSize: 14,
                          ),
                        ),
                ),

                // 9. Best Time to Visit (in a card)
                _buildCard(
                  context: context,
                  icon: LucideIcons.sun,
                  title: 'Best Time to Visit',
                  child: Text(
                    destination.bestTimeToVisit,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),

                // 10. How to Get There (in a card)
                _buildCard(
                  context: context,
                  icon: LucideIcons.car,
                  title: 'How to Get There',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        destination.howToGetThere,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.6,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            LucideIcons.clock,
                            size: 16,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                                children: [
                                  const TextSpan(
                                    text: 'Estimated Travel Time: ',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(text: destination.estimatedTravelTime),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 11. What to Bring (in a card)
                _buildCard(
                  context: context,
                  icon: LucideIcons.briefcase,
                  title: 'What to Bring',
                  child: Column(
                    children: destination.whatToBring.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '✓',
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item,
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.6,
                                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // 12. Meal Information (in a card)
                _buildCard(
                  context: context,
                  icon: LucideIcons.soup,
                  title: 'Meal Information',
                  child: Text(
                    destination.mealPlanDetails,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),

                // 13. Accessibility & Suitability (in a card)
                _buildCard(
                  context: context,
                  icon: LucideIcons.accessibility,
                  title: 'Accessibility & Suitability',
                  child: Column(
                    children: [
                      _buildAccessibilityRow('Kid-Friendly', destination.accessibility.isKidFriendly, Icons.child_care, colorScheme),
                      Divider(color: colorScheme.outline.withValues(alpha: 0.15), height: 1),
                      _buildAccessibilityRow('Wheelchair Accessible', destination.accessibility.isWheelchairAccessible, Icons.accessible, colorScheme),
                      Divider(color: colorScheme.outline.withValues(alpha: 0.15), height: 1),
                      _buildAccessibilityRow('Pet-Friendly', destination.accessibility.isPetFriendly, Icons.pets, colorScheme),
                      Divider(color: colorScheme.outline.withValues(alpha: 0.15), height: 1),
                      _buildAccessibilityRow('Elderly-Friendly', destination.accessibility.isElderlyFriendly, Icons.elderly, colorScheme),
                    ],
                  ),
                ),

                // 14. Travel Notes (in a card)
                _buildCard(
                  context: context,
                  icon: LucideIcons.stickyNote,
                  title: 'Travel Notes',
                  child: Text(
                    destination.travelNotes,
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ),

                // 15. Location Map (in a card)
                _buildCard(
                  context: context,
                  icon: LucideIcons.map,
                  title: 'Location Map',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: DestinationMapWidget(
                        destinationName: destination.name,
                        coordinates: LatLng(
                          destination.coordinates.lat,
                          destination.coordinates.lng,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () => _showTravelTypeModal(context, destination),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'Generate This Plan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showTravelTypeModal(BuildContext context, Destination destination) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _TravelTypeModal(destination: destination),
    );
  }
}


class _TravelTypeModal extends StatelessWidget {
  final Destination destination;

  const _TravelTypeModal({required this.destination});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'How are you traveling?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose your travel mode to customize your itinerary',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            _TravelTypeButton(
              title: 'Solo Adventure',
              subtitle: 'Personalized pace and activities',
              icon: LucideIcons.user,
              onTap: () {
                Navigator.pop(context);
                context.push(
                  '/ai-planner',
                  extra: {'destination': destination, 'isSolo': true},
                );
              },
            ),
            const SizedBox(height: 16),
            _TravelTypeButton(
              title: 'Group Trip',
              subtitle: 'Collaborative planning for groups',
              icon: LucideIcons.users,
              onTap: () {
                Navigator.pop(context);
                context.push(
                  '/ai-planner',
                  extra: {'destination': destination, 'isSolo': false},
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _TravelTypeButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _TravelTypeButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: primaryColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}


Widget _buildAccessibilityRow(
  String label,
  bool isAvailable,
  IconData icon,
  ColorScheme colorScheme,
) {
  return SizedBox(
    height: 44,
    child: Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isAvailable ? Colors.green : colorScheme.onSurface.withValues(alpha: 0.4),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        Text(
          isAvailable ? 'Yes' : 'No',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isAvailable ? Colors.green : colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
      ],
    ),
  );
}

Widget _buildOperatingHoursContent(
  String operatingHours,
  ColorScheme colorScheme,
  TextStyle boldStyle,
  TextStyle mutedStyle,
) {
  if (operatingHours.contains('Mondays - Saturdays') || operatingHours.contains('Mon - Sat')) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mon - Sat', style: boldStyle),
        Text('8:00 AM - 5:00 PM', style: mutedStyle),
        const SizedBox(height: 8),
        Text('Sunday', style: boldStyle),
        Text('8:00 AM - 12:00 NN', style: mutedStyle),
      ],
    );
  } else if (operatingHours.toLowerCase().contains('24 hours')) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('All Days', style: boldStyle),
        Text('Open 24 Hours', style: mutedStyle),
      ],
    );
  } else {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Daily Hours', style: boldStyle),
        Text(operatingHours, style: mutedStyle),
      ],
    );
  }
}

Widget _buildCard({
  required BuildContext context,
  required IconData icon,
  required String title,
  required Widget child,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: colorScheme.primary, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}
