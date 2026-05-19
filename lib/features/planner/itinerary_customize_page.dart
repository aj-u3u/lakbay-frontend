import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'providers/itinerary_provider.dart';
import 'models/planner_models.dart';
import '../../shared/data/destinations_data.dart';
import '../../shared/data/trips_data.dart';
import '../../shared/models/trip.dart';

class ItineraryCustomizePage extends ConsumerStatefulWidget {
  final PlannerItineraryPlan initialPlan;

  const ItineraryCustomizePage({
    super.key,
    required this.initialPlan,
  });

  @override
  ConsumerState<ItineraryCustomizePage> createState() => _ItineraryCustomizePageState();
}

class _ItineraryCustomizePageState extends ConsumerState<ItineraryCustomizePage> {
  String? editingActivityId; // Format: "dayIndex-activityIndex"
  int? editingDayTitleIndex;

  late TextEditingController _dayTitleController;
  late TextEditingController _timeController;
  late TextEditingController _activityController;
  late TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    _dayTitleController = TextEditingController();
    _timeController = TextEditingController();
    _activityController = TextEditingController();
    _locationController = TextEditingController();
  }

  @override
  void dispose() {
    _dayTitleController.dispose();
    _timeController.dispose();
    _activityController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _startEditingActivity(int dayIndex, int activityIndex, PlannerActivity activity) {
    setState(() {
      editingActivityId = "$dayIndex-$activityIndex";
      editingDayTitleIndex = null;
      _timeController.text = activity.time;
      _activityController.text = activity.activity;
      _locationController.text = activity.location;
    });
  }

  void _startEditingDayTitle(int dayIndex, String title) {
    setState(() {
      editingDayTitleIndex = dayIndex;
      editingActivityId = null;
      _dayTitleController.text = title;
    });
  }

  void _cancelEditing() {
    setState(() {
      editingActivityId = null;
      editingDayTitleIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final plan = ref.watch(itineraryCustomizeProvider(widget.initialPlan));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = const Color(0xFF008080); // Teal

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.chevronLeft, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Customize Itinerary',
          style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: plan.itinerary.length,
              itemBuilder: (context, dayIndex) {
                final day = plan.itinerary[dayIndex];
                return _buildDaySection(day, dayIndex, primaryColor, colorScheme);
              },
            ),
          ),
          _buildBottomButtons(context, plan, primaryColor),
        ],
      ),
    );
  }

  Widget _buildDaySection(PlannerItineraryDay day, int dayIndex, Color primaryColor, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DAY ${day.day}'.toUpperCase(),
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (editingDayTitleIndex == dayIndex)
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _dayTitleController,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(LucideIcons.check, color: primaryColor),
                          onPressed: () {
                            ref.read(itineraryCustomizeProvider(widget.initialPlan).notifier)
                                .updateDayTitle(dayIndex, _dayTitleController.text);
                            _cancelEditing();
                          },
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            day.title,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: Icon(LucideIcons.pencil, size: 18, color: colorScheme.onSurface.withValues(alpha: 0.4)),
                          onPressed: () => _startEditingDayTitle(dayIndex, day.title),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...day.activities.asMap().entries.map((entry) {
          final activityIndex = entry.key;
          final activity = entry.value;
          return _buildActivityItem(dayIndex, activityIndex, activity, primaryColor, colorScheme);
        }).toList(),
        _buildAddActivityButton(dayIndex, primaryColor),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildActivityItem(int dayIndex, int activityIndex, PlannerActivity activity, Color primaryColor, ColorScheme colorScheme) {
    final isEditing = editingActivityId == "$dayIndex-$activityIndex";

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: primaryColor.withOpacity(0.2),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isEditing)
                  _buildActivityEditForm(dayIndex, activityIndex, primaryColor, colorScheme)
                else
                  _buildActivityDisplay(dayIndex, activityIndex, activity, primaryColor, colorScheme),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityDisplay(int dayIndex, int activityIndex, PlannerActivity activity, Color primaryColor, ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity.time,
                style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface.withValues(alpha: 0.5)),
              ),
              const SizedBox(height: 4),
              Text(
                activity.activity,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                activity.location,
                style: TextStyle(fontSize: 14, color: colorScheme.onSurface.withValues(alpha: 0.5)),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(LucideIcons.pencil, size: 18, color: colorScheme.onSurface.withValues(alpha: 0.4)),
          onPressed: () => _startEditingActivity(dayIndex, activityIndex, activity),
        ),
      ],
    );
  }

  Widget _buildActivityEditForm(int dayIndex, int activityIndex, Color primaryColor, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _timeController,
            decoration: const InputDecoration(labelText: 'Time', isDense: true),
          ),
          TextField(
            controller: _activityController,
            decoration: const InputDecoration(labelText: 'Activity Name', isDense: true),
          ),
          TextField(
            controller: _locationController,
            decoration: const InputDecoration(labelText: 'Location', isDense: true),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  ref.read(itineraryCustomizeProvider(widget.initialPlan).notifier).updateActivity(
                    dayIndex,
                    activityIndex,
                    PlannerActivity(
                      time: _timeController.text,
                      activity: _activityController.text,
                      location: _locationController.text,
                    ),
                  );
                  _cancelEditing();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Icon(LucideIcons.check, size: 18),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  ref.read(itineraryCustomizeProvider(widget.initialPlan).notifier).deleteActivity(dayIndex, activityIndex);
                  _cancelEditing();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.errorContainer.withValues(alpha: 0.2),
                  foregroundColor: colorScheme.error,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Icon(LucideIcons.trash2, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddActivityButton(int dayIndex, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 28),
      child: TextButton.icon(
        onPressed: () {
          ref.read(itineraryCustomizeProvider(widget.initialPlan).notifier).addActivity(dayIndex);
          final plan = ref.read(itineraryCustomizeProvider(widget.initialPlan));
          final newActivityIndex = plan.itinerary[dayIndex].activities.length - 1;
          _startEditingActivity(dayIndex, newActivityIndex, plan.itinerary[dayIndex].activities.last);
        },
        icon: const Icon(LucideIcons.plus, size: 18),
        label: const Text('Add Activity'),
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }

  void _saveTripToDashboard(BuildContext context, PlannerItineraryPlan plan, Color primaryColor) {
    // 1. Attempt to find matched destination from destinations_data.dart
    String matchedImage = 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=800&q=80'; // Default fallback
    if (plan.destinationName != null) {
      try {
        final match = destinations.firstWhere(
          (d) => d.name.toLowerCase() == plan.destinationName!.toLowerCase() ||
                 plan.destinationName!.toLowerCase().contains(d.name.toLowerCase())
        );
        matchedImage = match.image;
      } catch (_) {}
    }

    // 2. Parse total cost to double
    double totalCostVal = 4500.0;
    final costStr = plan.totalCost.replaceAll(RegExp(r'[^0-9]'), '');
    if (costStr.isNotEmpty) {
      totalCostVal = double.tryParse(costStr) ?? 4500.0;
    }

    // 3. Parse duration to integer days
    int durationDays = 3;
    final durStr = plan.duration.replaceAll(RegExp(r'[^0-9]'), '');
    if (durStr.isNotEmpty) {
      durationDays = int.tryParse(durStr) ?? 3;
    }

    // 4. Map cost breakdown to budget categories
    final List<BudgetCategory> budgetCategories = [];
    final categoryColors = {
      'accommodation': '#60A5FA',
      'stay': '#60A5FA',
      'food': '#34D399',
      'dining': '#34D399',
      'transport': '#F59E0B',
      'transportation': '#F59E0B',
      'activity': '#A78BFA',
      'activities': '#A78BFA',
    };

    for (final item in plan.costBreakdown) {
      double itemAmount = 0.0;
      final itemAmtStr = item.amount.replaceAll(RegExp(r'[^0-9]'), '');
      if (itemAmtStr.isNotEmpty) {
        itemAmount = double.tryParse(itemAmtStr) ?? 0.0;
      }

      final catLower = item.category.toLowerCase();
      String hexColor = '#9CA3AF'; // Fallback gray
      for (final entry in categoryColors.entries) {
        if (catLower.contains(entry.key)) {
          hexColor = entry.value;
          break;
        }
      }

      budgetCategories.add(
        BudgetCategory(
          name: item.category,
          amount: itemAmount,
          color: hexColor,
        ),
      );
    }

    // 5. Map itinerary days & activities
    final List<ItineraryDay> tripItinerary = plan.itinerary.map((day) {
      return ItineraryDay(
        day: day.day,
        title: day.title,
        activities: day.activities.map((act) {
          return TripActivity(
            time: act.time,
            activity: act.activity,
            location: act.location,
          );
        }).toList(),
      );
    }).toList();

    // 6. Assemble the Trip entity
    final newTrip = Trip(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '${plan.destinationName ?? "Davao"} Adventure',
      destination: plan.destinationLocation ?? 'Davao Region',
      image: matchedImage,
      startDate: DateTime.now().add(const Duration(days: 30)),
      endDate: DateTime.now().add(Duration(days: 30 + durationDays - 1)),
      summary: plan.destinationDescription ?? 'A customized AI itinerary for ${plan.destinationName ?? "your trip"}.',
      budget: TripBudget(
        total: totalCostVal,
        spent: 0.0,
        daily: totalCostVal / durationDays,
        categories: budgetCategories,
      ),
      itinerary: tripItinerary,
      transport: [
        TransportInfo(
          from: 'Davao City',
          to: plan.destinationName ?? 'Destination',
          mode: 'Private Transfer',
          fare: plan.totalCost,
          duration: plan.duration,
        ),
      ],
      notes: plan.highlights,
      photos: [],
    );

    // 7. Mutate final list to insert at the top
    mockTrips.insert(0, newTrip);

    // 8. Confirm with Success Toast
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Customized trip saved successfully! 🎉'),
          ],
        ),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    // 9. Navigate to /trip tab page
    context.go('/trip');
  }

  Widget _buildBottomButtons(BuildContext context, PlannerItineraryPlan plan, Color primaryColor) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => context.pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _saveTripToDashboard(context, plan, primaryColor),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save Itinerary', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
