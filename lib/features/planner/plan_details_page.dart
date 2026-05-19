import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../shared/data/destinations_data.dart';
import '../../shared/data/trips_data.dart';
import '../../shared/models/destination.dart';
import '../../shared/models/trip.dart';
import 'models/planner_models.dart';

class PlanDetailsPage extends StatelessWidget {
  final PlannerItineraryPlan plan;

  const PlanDetailsPage({
    super.key,
    required this.plan,
  });

  // Helper method to automatically assign categories to activity badges based on keywords
  String _getCategoryBadge(String activityName) {
    final name = activityName.toLowerCase();
    if (name.contains('check-in') || name.contains('arrive') || name.contains('depart')) {
      return 'LOGISTICS';
    } else if (name.contains('lunch') ||
        name.contains('dinner') ||
        name.contains('breakfast') ||
        name.contains('food') ||
        name.contains('eat')) {
      return 'FOOD';
    } else if (name.contains('hike') ||
        name.contains('swim') ||
        name.contains('tour') ||
        name.contains('visit') ||
        name.contains('explore')) {
      return 'ACTIVITY';
    } else if (name.contains('sleep') || name.contains('rest') || name.contains('overnight')) {
      return 'REST';
    }
    return 'ACTIVITY';
  }

  // Helper to retrieve category-specific icons for cost breakdown
  IconData _getCategoryIcon(String categoryName) {
    final cat = categoryName.toLowerCase();
    if (cat.contains('accommodation') || cat.contains('stay') || cat.contains('hotel') || cat.contains('hostel')) {
      return LucideIcons.bedDouble;
    } else if (cat.contains('food') || cat.contains('dining') || cat.contains('meal') || cat.contains('restaurant')) {
      return LucideIcons.utensils;
    } else if (cat.contains('transport') || cat.contains('transportation') || cat.contains('car') || cat.contains('ferry') || cat.contains('taxi')) {
      return LucideIcons.car;
    } else if (cat.contains('activity') || cat.contains('activities') || cat.contains('tour') || cat.contains('experience')) {
      return LucideIcons.activity;
    }
    return LucideIcons.compass;
  }

  // Method to map PlannerItineraryPlan to a Trip, insert it, and navigate to /trip
  void _saveTripToDashboard(BuildContext context) {
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
      summary: plan.destinationDescription ?? 'A personalized AI itinerary for ${plan.destinationName ?? "your trip"}.',
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
            Text('Trip successfully saved to dashboard! 🎉'),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    // 9. Navigate to /trip tab page
    context.go('/trip');
  }

  @override
  Widget build(BuildContext context) {
    final destination = destinations.firstWhere(
      (d) => d.name.toLowerCase().contains(plan.destinationName?.toLowerCase() ?? '') ||
             (plan.destinationName?.toLowerCase() ?? '').contains(d.name.toLowerCase()),
      orElse: () => destinations.first,
    );

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;

    // Resolve matched destination location and office hours if exists
    final resolvedLocation = destination.location;
    final resolvedHours = destination.operatingHours;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // 1. APP BAR
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          plan.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      // 7. BOTTOM FLOATING ACTION BUTTON
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/customize-itinerary', extra: plan),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(LucideIcons.plus),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. DESTINATION HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          plan.destinationName ?? 'Destination',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        plan.totalCost,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(LucideIcons.mapPin, size: 16, color: primaryColor),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          resolvedLocation,
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurface.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 3. OPERATING HOURS CARD
                  Card(
                    color: colorScheme.surface,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            LucideIcons.clock,
                            color: primaryColor,
                            size: 24,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Operating Hours',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  resolvedHours,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colorScheme.onSurface.withOpacity(0.7),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 4. HIGHLIGHTS SECTION
                  Row(
                    children: [
                      Icon(LucideIcons.star, color: primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Highlights',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Render Highlights as a 2-Column Responsive Layout
                  Column(
                    children: [
                      for (int i = 0; i < plan.highlights.length; i += 2)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildHighlightCard(context, plan.highlights[i]),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: i + 1 < plan.highlights.length
                                    ? _buildHighlightCard(context, plan.highlights[i + 1])
                                    : const SizedBox(),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // 5. COST BREAKDOWN SECTION
                  Row(
                    children: [
                      Icon(LucideIcons.coins, color: primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Cost Breakdown',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...plan.costBreakdown.map((item) {
                    return Card(
                      color: colorScheme.surface,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getCategoryIcon(item.category),
                                color: primaryColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                item.category,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Text(
                              item.amount,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  // Grand Total Full-Width Primary Accent Bar
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          plan.totalCost,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 6. DAY-BY-DAY ITINERARY SECTION
                  Row(
                    children: [
                      Icon(LucideIcons.calendar, color: primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Day-by-Day Itinerary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Timeline Layout Column
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: plan.itinerary.map((day) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Day Header Node
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Filled teal circle
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: primaryColor.withOpacity(0.4),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Day Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Day ${day.day}'.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: primaryColor,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        day.title,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Activity List for this Day connected by a vertical line
                          ...day.activities.map((act) {
                            return IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Left side timeline connector line and activity empty circle
                                  SizedBox(
                                    width: 16,
                                    child: Stack(
                                      alignment: Alignment.topCenter,
                                      children: [
                                        // Vertical connector line (primary with opacity)
                                        Container(
                                          width: 2,
                                          color: primaryColor.withOpacity(0.25),
                                        ),
                                        // Empty outlined circle
                                        Positioned(
                                          top: 18,
                                          child: Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              color: colorScheme.surface,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: primaryColor, width: 2),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Right side activity card
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 16.0),
                                      child: Card(
                                        color: colorScheme.surface,
                                        elevation: 0,
                                        margin: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          side: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Top row: Time (muted) & Category Badge
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    act.time,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: colorScheme.onSurface.withOpacity(0.5),
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                  // Category Badge: small, rounded, teal background, bold, uppercase
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: primaryColor,
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: Text(
                                                      _getCategoryBadge(act.activity),
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 10,
                                                        letterSpacing: 0.5,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              // Activity name: bold, large
                                              Text(
                                                act.activity,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              // Location: home/pin icon, muted
                                              Row(
                                                children: [
                                                  Icon(
                                                    LucideIcons.mapPin,
                                                    size: 14,
                                                    color: colorScheme.onSurface.withOpacity(0.4),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      act.location,
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: colorScheme.onSurface.withOpacity(0.5),
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
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
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),

                  // 🚗 How to Get There Section
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
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
                            Icon(LucideIcons.car, color: primaryColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'How to Get There',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          destination.howToGetThere,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.6,
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.clock,
                              size: 16,
                              color: colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: colorScheme.onSurface.withValues(alpha: 0.7),
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

                  // 🌤 Best Time to Visit Section
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
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
                            const Icon(LucideIcons.sun, color: Colors.amber),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Best Time to Visit',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          destination.bestTimeToVisit,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.6,
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 🎒 What to Bring Section
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
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
                            Icon(LucideIcons.briefcase, color: primaryColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'What to Bring',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Column(
                          children: destination.whatToBring.map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '✓',
                                    style: TextStyle(
                                      color: primaryColor,
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
                                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  // 🍜 Meal Information Section
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
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
                            Icon(LucideIcons.soup, color: primaryColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Meal Information',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          destination.mealPlanDetails,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.6,
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ♿ Accessibility & Suitability Section
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
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
                            Icon(LucideIcons.accessibility, color: primaryColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Accessibility & Suitability',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildAccessibilityRow('Kid-Friendly', destination.accessibility.isKidFriendly, Icons.child_care, colorScheme),
                        _buildAccessibilityRow('Wheelchair Accessible', destination.accessibility.isWheelchairAccessible, Icons.accessible, colorScheme),
                        _buildAccessibilityRow('Pet-Friendly', destination.accessibility.isPetFriendly, Icons.pets, colorScheme),
                        _buildAccessibilityRow('Elderly-Friendly', destination.accessibility.isElderlyFriendly, Icons.elderly, colorScheme),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
      // 8. BOTTOM ACTION BUTTONS: STICKY SAVE BUTTON
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: colorScheme.outline.withOpacity(0.08),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => _saveTripToDashboard(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Save This Plan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Highlight Card builder
  Widget _buildHighlightCard(BuildContext context, String text) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.sparkles, color: primaryColor, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurface.withOpacity(0.8),
                height: 1.3,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
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
  return Padding(
    padding: const EdgeInsets.only(bottom: 10.0),
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
