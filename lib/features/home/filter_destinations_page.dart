import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../shared/providers/filter_provider.dart';
import '../../shared/data/destinations_data.dart';
import '../../shared/widgets/destination_preview_modal.dart';
import '../../shared/models/destination.dart';

class FilterDestinationsPage extends ConsumerWidget {
  const FilterDestinationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTheme = ref.watch(selectedThemeProvider);
    final selectedDistrict = ref.watch(selectedDistrictProvider);
    final filteredPlaces = ref.watch(filteredPlacesProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;

    final themes = ['Nature', 'Adventure', 'Beach', 'Culture', 'City'];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Filter Destinations', 
          style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold)
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(selectedThemeProvider.notifier).update(null);
              ref.read(selectedDistrictProvider.notifier).update(null);
            },
            child: Text('Clear All', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Travel Themes Section
              Text(
                'Travel Themes', 
                style: TextStyle(color: colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: null,
                    hint: Text(
                      selectedTheme != null ? '1 theme selected' : 'Select theme...',
                      style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6)),
                    ),
                    icon: Icon(LucideIcons.chevronDown, color: colorScheme.onSurface.withValues(alpha: 0.6)),
                    isExpanded: true,
                    dropdownColor: colorScheme.surface,
                    items: themes.map((t) {
                      return DropdownMenuItem<String>(
                        value: t,
                        child: Text(t, style: TextStyle(color: colorScheme.onSurface)),
                      );
                    }).toList(),
                    onChanged: (val) => ref.read(selectedThemeProvider.notifier).update(val),
                  ),
                ),
              ),
              if (selectedTheme != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$selectedTheme & Heritage',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => ref.read(selectedThemeProvider.notifier).update(null),
                        child: const Icon(LucideIcons.x, color: Colors.white, size: 14),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Districts Section
              Text(
                'Districts', 
                style: TextStyle(color: colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedDistrict,
                    hint: Text(
                      'Select district...', 
                      style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6))
                    ),
                    icon: Icon(LucideIcons.chevronDown, color: colorScheme.onSurface.withValues(alpha: 0.6)),
                    isExpanded: true,
                    dropdownColor: colorScheme.surface,
                    items: districts.map((d) {
                      return DropdownMenuItem<String>(
                        value: d,
                        child: Text(d, style: TextStyle(color: colorScheme.onSurface)),
                      );
                    }).toList(),
                    onChanged: (val) => ref.read(selectedDistrictProvider.notifier).update(val),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Discover Places Section
              Text(
                'Discover Places', 
                style: TextStyle(color: colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 4),
              Text(
                '${filteredPlaces.length} destinations found',
                style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 14),
              ),
              const SizedBox(height: 24),

              // Destination Cards
              ...filteredPlaces.map((dest) => _FilterDestinationCard(destination: dest)),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterDestinationCard extends StatelessWidget {
  final Destination destination;
  const _FilterDestinationCard({required this.destination});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return GestureDetector(
      onTap: () => DestinationPreviewModal.show(context, destination),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: Stack(
                children: [
                  Image.network(
                    destination.image,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8),
                        ],
                      ),
                      child: const Icon(Icons.star, color: Color(0xFFFFD700), size: 24),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination.name,
                    style: TextStyle(color: colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(LucideIcons.mapPin, size: 14, color: colorScheme.onSurface.withValues(alpha: 0.6)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          destination.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    destination.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 13, height: 1.5),
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
