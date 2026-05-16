import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../shared/data/destinations_data.dart';
import '../../shared/widgets/destination_card.dart';
import '../../shared/widgets/destination_preview_modal.dart';

class NewSpecialPage extends StatelessWidget {
  const NewSpecialPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New & Special', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: destinations.length, // Show all for now as it's a "Show All" page
        itemBuilder: (context, index) {
          final dest = destinations[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: DestinationCard(
              destination: dest,
              onClick: () => DestinationPreviewModal.show(context, dest),
            ),
          );
        },
      ),
    );
  }
}
