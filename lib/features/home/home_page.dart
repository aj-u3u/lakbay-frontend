import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lakbay_plus/app/api_service.dart';
import 'package:lakbay_plus/shared/models/destination.dart';
import 'package:lakbay_plus/shared/providers/location_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../shared/data/destinations_data.dart';
import '../../shared/widgets/destination_card.dart';
import '../../shared/widgets/destination_preview_modal.dart';
import '../../shared/providers/notification_provider.dart';
import '../../shared/providers/user_provider.dart';
import 'package:go_router/go_router.dart';

final searchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  List<Destination> getNearbyDestinations(Position position) {
    final sorted = [...destinations];

    sorted.sort((a, b) {
      final distA = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        a.coordinates.lat,
        a.coordinates.lng,
      );

      final distB = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        b.coordinates.lat,
        b.coordinates.lng,
      );

      return distA.compareTo(distB);
    });

    return sorted;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;

    final locationAsync = ref.watch(currentLocationProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final userProfile = ref.watch(userProfileProvider);

    final filteredDestinations = destinations.where((d) => 
      d.name.toLowerCase().contains(searchQuery.toLowerCase()) || 
      d.location.toLowerCase().contains(searchQuery.toLowerCase()) ||
      d.category.any((c) => c.toLowerCase().contains(searchQuery.toLowerCase()))
    ).toList();

    final recommended = locationAsync.maybeWhen(
      data: (position) =>
          position != null ? getNearbyDestinations(position) : destinations,
      orElse: () => destinations,
    );

    final newDestinations = recommended.take(3).toList();

    final greetingText = locationAsync.when(
      data: (position) {
        if (position == null) {
          return 'Good morning,';
        }
        return 'Exploring near you 📍';
      },
      loading: () => 'Getting your location...',
      error: (_, _) => 'Good morning,',
    );

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
                    primaryColor.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                greetingText,
                                style: TextStyle(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                              Text(
                                '${userProfile.name.split(' ').first}! 👋',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: colorScheme.surface,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    LucideIcons.bell,
                                    color: colorScheme.onSurface,
                                  ),
                                  onPressed: () =>
                                      context.push('/home/notifications'),
                                ),
                              ),
                              Consumer(
                                builder: (context, ref, child) {
                                  final count = ref.watch(
                                    unreadNotificationsCountProvider,
                                  );
                                  if (count == 0) {
                                    return const SizedBox.shrink();
                                  }

                                  return Positioned(
                                    top: -2,
                                    right: -2,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: colorScheme.error,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: colorScheme.surface,
                                          width: 2,
                                        ),
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 20,
                                        minHeight: 20,
                                      ),
                                      child: Center(
                                        child: Text(
                                          count > 9 ? '9+' : '$count',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
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
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: TextField(
                                onChanged: (val) =>
                                    ref
                                            .read(searchQueryProvider.notifier)
                                            .state =
                                        val,
                                style: TextStyle(color: colorScheme.onSurface),
                                decoration: InputDecoration(
                                  hintText: 'Search destinations...',
                                  hintStyle: TextStyle(
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),
                                  prefixIcon: Icon(
                                    LucideIcons.search,
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
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
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: IconButton(
                              padding: const EdgeInsets.all(16),
                              icon: Icon(
                                LucideIcons.listFilter,
                                color: colorScheme.onSurface,
                              ),
                              onPressed: () => context.push('/filter'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),


          if (searchQuery.isEmpty) ...[
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),
                  Text(
                    'Trending Now',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () => DestinationPreviewModal.show(
                            context,
                            recommended[1],
                          ),
                          child: _TrendingCard(
                            image: recommended[1].image,
                            title: recommended[1].name,
                            subtitle: 'Paradise awaits 🌴',
                            tag: '⭐ Top Pick',
                            height: 280,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () => DestinationPreviewModal.show(
                                context,
                                recommended[0],
                              ),
                              child: _TrendingCard(
                                image: recommended[0].image,
                                title: recommended[0].name,
                                height: 134,
                              ),
                            ),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () => DestinationPreviewModal.show(
                                context,
                                recommended[2],
                              ),
                              child: _TrendingCard(
                                image: recommended[2].image,
                                title: recommended[2].name,
                                height: 134,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'New & Special',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/new-special'),
                        child: Row(
                          children: [
                            Text(
                              'Show All',
                              style: TextStyle(color: primaryColor),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              LucideIcons.chevronRight,
                              size: 16,
                              color: primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ]),
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(
                height: 285,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  scrollDirection: Axis.horizontal,
                  itemCount: recommended.length,
                  itemBuilder: (context, index) {
                    final dest = recommended[index];
                    return DestinationCard(
                      destination: dest,
                      onClick: () => DestinationPreviewModal.show(context, dest),
                    );
                  },
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Weekend Getaways',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 180,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _WeekendCard(
                          emoji: '🏖️',
                          title: 'Beach Escape',
                          subtitle: 'Dahican Beach',
                          info: '3h from city',
                          gradient: [
                            const Color(0xFF0EA5E9),
                            const Color(0xFF2DD4BF),
                          ],
                        ),
                        _WeekendCard(
                          emoji: '⛰️',
                          title: 'Mountain Trek',
                          subtitle: 'Mt. Apo',
                          info: 'High Difficulty',
                          gradient: [
                            const Color(0xFF8B5CF6),
                            const Color(0xFFD946EF),
                          ],
                        ),
                        _WeekendCard(
                          emoji: '🦅',
                          title: 'Wildlife Tour',
                          subtitle: 'Eagle Center',
                          info: 'Family Friendly',
                          gradient: [
                            const Color(0xFFF59E0B),
                            const Color(0xFFEF4444),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recommended for You',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/recommended'),
                        child: Row(
                          children: [
                            Text(
                              'Show All',
                              style: TextStyle(color: primaryColor),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              LucideIcons.chevronRight,
                              size: 16,
                              color: primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ]),
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(
                height: 285,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  scrollDirection: Axis.horizontal,
                  itemCount: recommended.length,
                  itemBuilder: (context, index) {
                    final dest = recommended[index];
                    return DestinationCard(
                      destination: dest,
                      onClick: () => DestinationPreviewModal.show(context, dest),
                    );
                  },
                ),
              ),
            ),
          ] else ...[
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Search Results',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        '${filteredDestinations.length} found',
                        style: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.4),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (filteredDestinations.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          Icon(
                            LucideIcons.searchX,
                            size: 64,
                            color: colorScheme.onSurface.withValues(alpha: 0.1),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No destinations found for "$searchQuery"',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colorScheme.onSurface.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                ]),
              ),
            ),
            if (filteredDestinations.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    mainAxisExtent: 320,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final dest = filteredDestinations[index];
                      return DestinationCard(
                        destination: dest,
                        onClick: () => DestinationPreviewModal.show(context, dest),
                      );
                    },
                    childCount: filteredDestinations.length,
                  ),
                ),
              ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 60)),
        ],
      ),
    );
  }
}

class _TrendingCard extends StatelessWidget {
  final String image;
  final String title;
  final String? subtitle;
  final String? tag;
  final double height;

  const _TrendingCard({
    required this.image,
    required this.title,
    this.subtitle,
    this.tag,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(image: NetworkImage(image), fit: BoxFit.cover),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tag != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tag!,
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _WeekendCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final String info;
  final List<Color> gradient;

  const _WeekendCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.info,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const Spacer(),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            info,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
