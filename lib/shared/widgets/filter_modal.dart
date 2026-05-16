import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class FilterModal extends StatefulWidget {
  const FilterModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterModal(),
    );
  }

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  String _selectedCategory = 'All';
  RangeValues _priceRange = const RangeValues(0, 10000);
  final List<String> _categories = ['All', 'Beach', 'Mountain', 'Nature', 'Culture', 'City'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters', 
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colorScheme.onSurface)
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(LucideIcons.x, color: colorScheme.onSurface),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Category', 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _categories.map((cat) {
              final isSelected = _selectedCategory == cat;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      color: isSelected ? Colors.white : colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          Text(
            'Price Range (per person)', 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)
          ),
          const SizedBox(height: 8),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 20000,
            divisions: 20,
            activeColor: colorScheme.primary,
            inactiveColor: colorScheme.primary.withValues(alpha: 0.2),
            labels: RangeLabels(
              '₱${_priceRange.start.round()}',
              '₱${_priceRange.end.round()}',
            ),
            onChanged: (values) => setState(() => _priceRange = values),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('₱0', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4))),
              Text('₱20,000+', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4))),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
                  ),
                  child: Text('Reset All', style: TextStyle(color: colorScheme.onSurface)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
