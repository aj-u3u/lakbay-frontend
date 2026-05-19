import '../models/planner_models.dart';
import '../../../shared/data/destinations_data.dart';
import '../../../shared/models/destination.dart';

PlannerItineraryPlan getMockItineraryPlan(
  String type,
  bool isGroupTrip,
  String duration,
  String destination,
  String location,
  String operatingHours,
  String description,
) {
  // Parse duration in days reliably
  int numDays = 3;
  final daysMatch = RegExp(r'(\d+)').firstMatch(duration);
  if (daysMatch != null) {
    numDays = int.parse(daysMatch.group(1)!);
  }

  Destination? matchedDest;
  try {
    matchedDest = destinations.firstWhere(
      (d) => d.name.toLowerCase().contains(destination.toLowerCase()) ||
             destination.toLowerCase().contains(d.name.toLowerCase())
    );
  } catch (_) {
    for (var d in destinations) {
      if (d.name.toLowerCase().contains(destination.toLowerCase()) ||
          destination.toLowerCase().contains(d.name.toLowerCase())) {
        matchedDest = d;
        break;
      }
    }
  }

  if (matchedDest != null) {
    // 1. Calculate realistic base cost based on selected budget type and fees
    double baseCost = 2500.0;
    if (type == 'balanced') baseCost = 6500.0;
    if (type == 'premium') baseCost = 14500.0;

    if (matchedDest.entranceFee.contains('350') || matchedDest.entranceFee.contains('550')) {
      baseCost += 1000.0;
    } else if (matchedDest.entranceFee.contains('2,000') || matchedDest.entranceFee.contains('5,000')) {
      baseCost += 4000.0;
    }

    final costDisplay = isGroupTrip ? '₱${baseCost.toStringAsFixed(0)}/person' : '₱${baseCost.toStringAsFixed(0)}';

    // 2. Extract highlights based on actual activities
    final List<String> highlights = [];
    for (var act in matchedDest.activities) {
      highlights.add('Enjoy exciting $act sessions');
    }
    if (highlights.length > 4) {
      highlights.removeRange(4, highlights.length);
    }
    if (highlights.isEmpty) {
      highlights.addAll([
        'Beautiful scenic views',
        'Relaxing atmosphere',
        'Local food trip',
        'Guided adventure activities',
      ]);
    }

    // 3. Accommodation / Stay Cost from destination's actual list
    final accommodations = matchedDest.accommodations ?? [];
    String stayCost = '₱1,500';
    if (type == 'budget') {
      stayCost = accommodations.isNotEmpty ? accommodations.first.price : '₱1,500';
    } else if (type == 'premium') {
      stayCost = accommodations.isNotEmpty ? accommodations.last.price : '₱6,500';
    } else {
      int midIdx = accommodations.length ~/ 2;
      stayCost = accommodations.isNotEmpty ? accommodations[midIdx].price : '₱3,000';
    }

    final List<PlannerAccommodationOption> accomOpts = accommodations.map((a) {
      return PlannerAccommodationOption(
        type: a.type,
        price: a.price,
        description: a.description,
      );
    }).toList();

    final activityPrices = matchedDest.activityPrices ?? [];
    final List<PlannerActivityPrice> actPrices = activityPrices.map((ap) {
      return PlannerActivityPrice(
        name: ap.name,
        price: ap.price,
      );
    }).toList();

    final List<PlannerCostItem> costBreakdown = [
      PlannerCostItem(
        category: type == 'budget' ? 'Budget Stay' : (type == 'premium' ? 'Luxury Experience' : 'Comfort Package'),
        amount: stayCost,
        overnightFee: (matchedDest.overnightFee != null && matchedDest.overnightFee!.isNotEmpty) ? matchedDest.overnightFee! : '₱0',
        entranceFee: matchedDest.entranceFee,
        transportationFee: type == 'budget' ? '₱250' : (type == 'premium' ? '₱1,200' : '₱500'),
        foodFee: type == 'budget' ? '₱300' : (type == 'premium' ? '₱1,000' : '₱600'),
        operatingHours: matchedDest.operatingHours,
        accommodations: accomOpts,
        activityPrices: actPrices,
      ),
    ];

    final List<PlannerItineraryDay> itinerary = [];
    final List<String> destActivities = matchedDest.activities;
    
    for (int d = 1; d <= numDays; d++) {
      String dayTitle = 'Arrival & First Steps';
      final List<PlannerActivity> dayActivities = [];

      if (d == 1) {
        dayTitle = 'Arrival & Initial Experience';
        dayActivities.addAll([
          PlannerActivity(
            time: '08:30 AM',
            activity: 'Depart from Davao City Proper',
            location: 'Davao City',
          ),
          PlannerActivity(
            time: '10:00 AM',
            activity: 'Arrive at destination',
            location: matchedDest.name,
          ),
          PlannerActivity(
            time: '11:00 AM',
            activity: 'Check-in and settle down',
            location: matchedDest.name,
          ),
          PlannerActivity(
            time: '02:00 PM',
            activity: destActivities.isNotEmpty ? 'Start ${destActivities[0]}' : 'Sightseeing around the area',
            location: matchedDest.name,
          ),
          PlannerActivity(
            time: '06:00 PM',
            activity: 'Welcome Dinner & Relaxation',
            location: matchedDest.name,
          ),
        ]);
      } else if (d == numDays) {
        dayTitle = 'Last Day & Farewell';
        dayActivities.addAll([
          PlannerActivity(
            time: '08:00 AM',
            activity: 'Healthy Breakfast',
            location: matchedDest.name,
          ),
          PlannerActivity(
            time: '09:30 AM',
            activity: destActivities.length > 2 
                ? 'Try out ${destActivities.last}' 
                : (destActivities.isNotEmpty ? 'Final ${destActivities[0]} session' : 'Morning Nature Walk'),
            location: matchedDest.name,
          ),
          PlannerActivity(
            time: '11:30 AM',
            activity: 'Check-out & pack up bags',
            location: matchedDest.name,
          ),
          PlannerActivity(
            time: '01:00 PM',
            activity: 'Late Lunch & Souvenir shopping',
            location: matchedDest.name,
          ),
          PlannerActivity(
            time: '03:00 PM',
            activity: 'Depart back to Davao City',
            location: 'Davao City',
          ),
        ]);
      } else {
        dayTitle = 'Full Day Immersive Adventure';
        dayActivities.addAll([
          PlannerActivity(
            time: '07:30 AM',
            activity: 'Morning Breakfast & Prep',
            location: matchedDest.name,
          ),
          PlannerActivity(
            time: '09:00 AM',
            activity: destActivities.length > 1 ? 'Enjoy ${destActivities[1]}' : 'Scenic Trekking & Exploration',
            location: matchedDest.name,
          ),
          PlannerActivity(
            time: '12:00 PM',
            activity: 'Lunch and Rest',
            location: matchedDest.name,
          ),
          PlannerActivity(
            time: '02:30 PM',
            activity: destActivities.length > 2 ? 'Do ${destActivities[2]}' : 'Afternoon relaxation and photo taking',
            location: matchedDest.name,
          ),
          PlannerActivity(
            time: '06:30 PM',
            activity: 'Sunset Bonfire / Dinner Gathering',
            location: matchedDest.name,
          ),
        ]);
      }

      itinerary.add(
        PlannerItineraryDay(
          day: d,
          title: dayTitle,
          activities: dayActivities,
        ),
      );
    }

    return PlannerItineraryPlan(
      title: '${type[0].toUpperCase()}${type.substring(1)} Experience',
      type: type,
      totalCost: costDisplay,
      duration: duration,
      destinationName: matchedDest.name,
      destinationLocation: matchedDest.location,
      destinationDescription: matchedDest.description,
      highlights: highlights,
      costBreakdown: costBreakdown,
      itinerary: itinerary,
    );
  }

  // Graceful Fallback if destination matches nothing pre-defined
  if (type == 'budget') {
    final List<PlannerItineraryDay> budgetItinerary = [];
    for (int d = 1; d <= numDays; d++) {
      if (d == 1) {
        budgetItinerary.add(
          PlannerItineraryDay(
            day: 1,
            title: 'Arrival & Budget Exploration',
            activities: [
              PlannerActivity(
                time: '09:00 AM',
                activity: 'Check-in at hostel',
                location: 'Budget Hostel',
              ),
              PlannerActivity(
                time: '11:00 AM',
                activity: 'Local Market Walking Tour',
                location: 'City Center',
              ),
              PlannerActivity(
                time: '02:00 PM',
                activity: 'Public Beach Access & Swimming',
                location: 'Public Shoreline',
              ),
            ],
          ),
        );
      } else if (d == numDays) {
        budgetItinerary.add(
          PlannerItineraryDay(
            day: d,
            title: 'Departure & Street Food Tour',
            activities: [
              PlannerActivity(
                time: '09:00 AM',
                activity: 'Local Breakfast & Coffee',
                location: 'Street Side Cafe',
              ),
              PlannerActivity(
                time: '11:00 AM',
                activity: 'Souvenir shopping',
                location: 'Local Crafts Market',
              ),
              PlannerActivity(
                time: '01:00 PM',
                activity: 'Checkout and Departure',
                location: 'Transit Station',
              ),
            ],
          ),
        );
      } else {
        budgetItinerary.add(
          PlannerItineraryDay(
            day: d,
            title: 'Eco-Trekking & Sightseeing',
            activities: [
              PlannerActivity(
                time: '08:00 AM',
                activity: 'Morning Jog & Breakfast',
                location: 'Park Area',
              ),
              PlannerActivity(
                time: '10:00 AM',
                activity: 'Self-guided nature hike',
                location: 'Forest Trail',
              ),
              PlannerActivity(
                time: '03:00 PM',
                activity: 'Sunset viewing deck',
                location: 'Mountain Top Viewpoint',
              ),
            ],
          ),
        );
      }
    }

    return PlannerItineraryPlan(
      title: 'Budget-Friendly Plan',
      type: 'budget',
      totalCost: isGroupTrip ? '₱4,500/person' : '₱4,500',
      duration: duration,
      destinationName: destination,
      destinationLocation: location,
      destinationDescription: description,
      highlights: [
        'Affordable accommodations',
        'Local transportation',
        'Street food experience',
        'Low-cost attractions',
      ],
      costBreakdown: [
        PlannerCostItem(
          category: 'Budget Stay',
          amount: '₱1,500',
          overnightFee: '₱800',
          entranceFee: '₱150',
          transportationFee: '₱250',
          foodFee: '₱300',
          operatingHours: operatingHours,
          accommodations: [
            PlannerAccommodationOption(
              type: 'Backpacker Hostel',
              price: '₱600/night',
              description: 'Shared room with basic amenities',
            ),
            PlannerAccommodationOption(
              type: 'Budget Inn',
              price: '₱900/night',
              description: 'Private room with fan',
            ),
          ],
          activityPrices: [
            PlannerActivityPrice(name: 'Beach Access', price: '₱100'),
            PlannerActivityPrice(name: 'Sunset Viewing Deck', price: '₱50'),
          ],
        ),
      ],
      itinerary: budgetItinerary,
    );
  }

  if (type == 'premium') {
    final List<PlannerItineraryDay> premiumItinerary = [];
    for (int d = 1; d <= numDays; d++) {
      if (d == 1) {
        premiumItinerary.add(
          PlannerItineraryDay(
            day: 1,
            title: 'Luxury Welcome & VIP Check-in',
            activities: [
              PlannerActivity(
                time: '10:00 AM',
                activity: 'VIP Resort Check-in',
                location: '5-Star Beach Resort',
              ),
              PlannerActivity(
                time: '01:00 PM',
                activity: 'Welcome Spa & Massage Session',
                location: 'Resort Luxury Spa',
              ),
              PlannerActivity(
                time: '06:00 PM',
                activity: 'Fine Dining Seafood Dinner',
                location: 'Seaside Grill Room',
              ),
            ],
          ),
        );
      } else if (d == numDays) {
        premiumItinerary.add(
          PlannerItineraryDay(
            day: d,
            title: 'Exclusive Morning & Departure',
            activities: [
              PlannerActivity(
                time: '09:00 AM',
                activity: 'Champagne Breakfast Buffet',
                location: 'Resort Club Lounge',
              ),
              PlannerActivity(
                time: '11:00 AM',
                activity: 'Private helicopter transfer to airport',
                location: 'Helipad Lounge',
              ),
            ],
          ),
        );
      } else {
        premiumItinerary.add(
          PlannerItineraryDay(
            day: d,
            title: 'Private Yacht Tour & Dining',
            activities: [
              PlannerActivity(
                time: '09:00 AM',
                activity: 'Board Private Yacht Tour',
                location: 'Private Marina',
              ),
              PlannerActivity(
                time: '02:00 PM',
                activity: 'Helicopter Sightseeing Flight',
                location: 'Sky Port',
              ),
              PlannerActivity(
                time: '07:00 PM',
                activity: 'Exotic Beachside Wine Pairing Dinner',
                location: 'Resort Beach Cove',
              ),
            ],
          ),
        );
      }
    }

    return PlannerItineraryPlan(
      title: 'Premium Adventure',
      type: 'premium',
      totalCost: isGroupTrip ? '₱15,000/person' : '₱15,000',
      duration: duration,
      destinationName: destination,
      destinationLocation: location,
      destinationDescription: description,
      highlights: [
        'Luxury accommodations',
        'Private transfers',
        'Fine dining',
        'Exclusive activities',
      ],
      costBreakdown: [
        PlannerCostItem(
          category: 'Luxury Experience',
          amount: '₱6,500',
          overnightFee: '₱3,500',
          entranceFee: '₱800',
          transportationFee: '₱1,200',
          foodFee: '₱1,000',
          operatingHours: operatingHours,
          accommodations: [
            PlannerAccommodationOption(
              type: 'Ocean View Suite',
              price: '₱4,500/night',
              description: 'Private balcony with breakfast buffet',
            ),
            PlannerAccommodationOption(
              type: 'Luxury Villa',
              price: '₱7,500/night',
              description: 'Private pool and butler service',
            ),
          ],
          activityPrices: [
            PlannerActivityPrice(name: 'Private Yacht Tour', price: '₱2,500'),
            PlannerActivityPrice(
              name: 'Helicopter Sightseeing',
              price: '₱5,000',
            ),
          ],
        ),
      ],
      itinerary: premiumItinerary,
    );
  }

  // Balanced Fallback
  final List<PlannerItineraryDay> balancedItinerary = [];
  for (int d = 1; d <= numDays; d++) {
    if (d == 1) {
      balancedItinerary.add(
        PlannerItineraryDay(
          day: 1,
          title: 'Comfort Arrival & Check-in',
          activities: [
            PlannerActivity(
              time: '09:00 AM',
              activity: 'Standard Hotel Check-in',
              location: '3-Star Premium Hotel',
            ),
            PlannerActivity(
              time: '12:00 PM',
              activity: 'Beachside Local Lunch',
              location: 'Seaside Restaurant',
            ),
            PlannerActivity(
              time: '03:00 PM',
              activity: 'Guided Island Orientation Tour',
              location: 'Town Center',
            ),
          ],
        ),
      );
    } else if (d == numDays) {
      balancedItinerary.add(
        PlannerItineraryDay(
          day: d,
          title: 'Final Day & Farewell Walk',
          activities: [
            PlannerActivity(
              time: '08:30 AM',
              activity: 'Morning Buffet Breakfast',
              location: 'Hotel Dining Area',
            ),
            PlannerActivity(
              time: '11:00 AM',
              activity: 'Checkout and airport transfer',
              location: 'Hotel Lobby',
            ),
          ],
        ),
      );
    } else {
      balancedItinerary.add(
        PlannerItineraryDay(
          day: d,
          title: 'Island Hopping & Seafood Dinner',
          activities: [
            PlannerActivity(
              time: '08:30 AM',
              activity: 'Shared Island Hopping Tour',
              location: 'Main Boat Pier',
            ),
            PlannerActivity(
              time: '02:00 PM',
              activity: 'Sea Kayaking & Snorkeling',
              location: 'Coral Garden Beach',
            ),
            PlannerActivity(
              time: '06:30 PM',
              activity: 'Fresh Seafood Dinner buffet',
              location: 'Pier Seafood Resto',
            ),
          ],
        ),
      );
    }
  }

  return PlannerItineraryPlan(
    title: 'Balanced Experience',
    type: 'balanced',
    totalCost: isGroupTrip ? '₱8,500/person' : '₱8,500',
    duration: duration,
    destinationName: destination,
    destinationLocation: location,
    destinationDescription: description,
    highlights: [
      'Comfortable hotel stay',
      'Mixed transport options',
      'Good dining choices',
      'Popular attractions',
    ],
    costBreakdown: [
      PlannerCostItem(
        category: 'Comfort Package',
        amount: '₱3,000',
        overnightFee: '₱1,500',
        entranceFee: '₱400',
        transportationFee: '₱500',
        foodFee: '₱600',
        operatingHours: operatingHours,
        accommodations: [
          PlannerAccommodationOption(
            type: 'Standard Hotel',
            price: '₱1,800/night',
            description: 'Air-conditioned room with breakfast',
          ),
          PlannerAccommodationOption(
            type: 'Deluxe Room',
            price: '₱2,500/night',
            description: 'Spacious room with city view',
          ),
        ],
        activityPrices: [
          PlannerActivityPrice(name: 'Island Hopping', price: '₱800'),
          PlannerActivityPrice(name: 'Kayaking', price: '₱350'),
        ],
      ),
    ],
    itinerary: balancedItinerary,
  );
}
