import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../shared/data/destinations_data.dart';
import '../../shared/widgets/destination_card.dart';
import '../../shared/widgets/destination_preview_modal.dart';

final searchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    // final searchQuery = ref.watch(searchQueryProvider);
    
    final newDestinations = destinations.take(3).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    primaryColor.withOpacity(0.1),
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
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Good morning,', style: TextStyle(color: Colors.grey)),
                              Text('Juan! 👋', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey[800] : Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(LucideIcons.bell),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: isDark ? Colors.grey[800] : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                                ],
                              ),
                              child: TextField(
                                onChanged: (val) => ref.read(searchQueryProvider.notifier).state = val,
                                decoration: const InputDecoration(
                                  hintText: 'Search destinations...',
                                  prefixIcon: Icon(LucideIcons.search, color: Colors.grey),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey[800] : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                              ],
                            ),
                            child: IconButton(
                              padding: const EdgeInsets.all(16),
                              icon: const Icon(LucideIcons.listFilter),
                              onPressed: () {},
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
          
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),
                const Text('Trending Now', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: () => DestinationPreviewModal.show(context, destinations[1]),
                        child: _TrendingCard(
                          image: destinations[1].image,
                          title: destinations[1].name,
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
                            onTap: () => DestinationPreviewModal.show(context, destinations[0]),
                            child: _TrendingCard(
                              image: destinations[0].image,
                              title: 'Eden Nature',
                              height: 134,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () => DestinationPreviewModal.show(context, destinations[3]),
                            child: _TrendingCard(
                              image: destinations[3].image,
                              title: 'Eagle Center',
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
                    const Text('New & Special', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () {},
                      child: Row(
                        children: [
                          Text('Show All', style: TextStyle(color: primaryColor)),
                          Icon(LucideIcons.chevronRight, size: 16, color: primaryColor),
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
              height: 270,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                itemCount: newDestinations.length,
                itemBuilder: (context, index) {
                  final dest = newDestinations[index];
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
                const SizedBox(height: 24),
                const Text('Travel Tips', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primaryColor.withOpacity(0.1),
                        Colors.teal.withOpacity(0.1),
                        primaryColor.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(child: Text('💡', style: TextStyle(fontSize: 24))),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Best Time to Visit Davao', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            Text(
                              'November to March offers the best weather for outdoor activities and beach trips. Expect sunny days and cool evenings perfect for exploring!',
                              style: TextStyle(color: Colors.grey, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                const Text('Weekend Getaways', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
              ]),
            ),
          ),
          
          SliverToBoxAdapter(
            child: SizedBox(
              height: 160,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                children: [
                  _WeekendCard(
                    emoji: '🌅',
                    title: 'Beach Sunset',
                    subtitle: 'Perfect for couples',
                    info: '2D/1N • from ₱3,500',
                    gradient: const [Colors.pink, Colors.orange],
                  ),
                  _WeekendCard(
                    emoji: '🏕️',
                    title: 'Mountain Camp',
                    subtitle: 'Adventure seekers',
                    info: '3D/2N • from ₱5,000',
                    gradient: const [Colors.teal, Colors.cyan],
                  ),
                  _WeekendCard(
                    emoji: '🎭',
                    title: 'Culture Tour',
                    subtitle: 'History lovers',
                    info: '1 Day • from ₱1,500',
                    gradient: const [Colors.amber, Colors.orange],
                  ),
                ],
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
                    const Text('Recommended for You', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () {},
                      child: Row(
                        children: [
                          Text('Show All', style: TextStyle(color: primaryColor)),
                          Icon(LucideIcons.chevronRight, size: 16, color: primaryColor),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ]),
            ),
          ),
          
          // Recommended lists grouped by district
          ...districts.map((district) {
            final districtDests = destinations.where((d) => d.district == district).toList();
            if (districtDests.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
            
            return SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Text(district, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(
                    height: 270,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      scrollDirection: Axis.horizontal,
                      itemCount: districtDests.length,
                      itemBuilder: (context, index) {
                        final dest = districtDests[index];
                        return DestinationCard(
                          destination: dest,
                          onClick: () => DestinationPreviewModal.show(context, dest),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          }),
          
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
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
        image: DecorationImage(
          image: NetworkImage(image),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.8), Colors.transparent],
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
                child: Text(tag!, style: const TextStyle(fontSize: 10, color: Colors.white)),
              ),
              const SizedBox(height: 8),
            ],
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            if (subtitle != null) Text(subtitle!, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
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
            color: gradient.first.withOpacity(0.3),
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
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
          const SizedBox(height: 8),
          Text(info, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
        ],
      ),
    );
  }
}
