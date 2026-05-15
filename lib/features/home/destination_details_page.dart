import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header Image with Back button
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            automaticallyImplyLeading: false,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.9),
                child: IconButton(
                  icon: const Icon(LucideIcons.arrowLeft, color: Colors.black, size: 20),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    destination.image,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 50,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.star, size: 18, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            destination.rating.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
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
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  destination.name,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(LucideIcons.mapPin, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        destination.location,
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                _InfoSection(
                  icon: LucideIcons.info,
                  title: 'About',
                  content: Text(
                    destination.description,
                    style: const TextStyle(color: Colors.grey, height: 1.5),
                  ),
                ),
                
                _InfoSection(
                  icon: LucideIcons.dollarSign,
                  title: 'Entrance Fee',
                  content: Text(
                    destination.entranceFee,
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
                
                _InfoSection(
                  icon: LucideIcons.layers,
                  title: 'Activities',
                  content: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: destination.activities.map((activity) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          activity,
                          style: TextStyle(color: primaryColor, fontWeight: FontWeight.w500),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                
                _InfoSection(
                  icon: LucideIcons.utensils,
                  title: 'Meal Inclusions',
                  content: Text(
                    destination.mealInclusions,
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
                
                _InfoSection(
                  icon: LucideIcons.stickyNote,
                  title: 'Travel Notes',
                  content: Text(
                    destination.travelNotes,
                    style: const TextStyle(color: Colors.grey, height: 1.5),
                  ),
                ),
                
                _InfoSection(
                  icon: LucideIcons.map,
                  title: 'Location Map',
                  content: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.mapPin, size: 40, color: Colors.grey),
                          const SizedBox(height: 8),
                          Text(
                            '${destination.coordinates.lat.toStringAsFixed(4)}, ${destination.coordinates.lng.toStringAsFixed(4)}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

class _InfoSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget content;

  const _InfoSection({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: primaryColor),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }
}

class _TravelTypeModal extends StatelessWidget {
  final Destination destination;

  const _TravelTypeModal({required this.destination});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How are you traveling?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'This helps us create the perfect itinerary for you',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 32),
          _TravelTypeButton(
            title: 'Solo Travel',
            subtitle: 'Planning a trip by yourself',
            icon: LucideIcons.user,
            onTap: () {
              Navigator.pop(context);
              // AI Planner navigation to be implemented
            },
          ),
          const SizedBox(height: 16),
          _TravelTypeButton(
            title: 'Group Travel',
            subtitle: 'Traveling with friends or family',
            icon: LucideIcons.users,
            onTap: () {
              Navigator.pop(context);
              // AI Group Planner navigation to be implemented
            },
          ),
          const SizedBox(height: 24),
        ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
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
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
