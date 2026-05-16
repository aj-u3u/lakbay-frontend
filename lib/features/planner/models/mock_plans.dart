import '../models/planner_models.dart';

PlannerItineraryPlan getMockItineraryPlan(
  String type,
  bool isGroupTrip,
  String duration,
  String destination,
) {
  if (type == 'budget') {
    return PlannerItineraryPlan(
      title: 'Budget-Friendly Plan',
      type: 'budget',
      totalCost: isGroupTrip ? '₱4,500/person' : '₱4,500',
      duration: duration,
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
      itinerary: [
        PlannerItineraryDay(
          day: 1,
          title: 'Arrival & Exploration',
          activities: [
            PlannerActivity(
              time: '09:00 AM',
              activity: 'Check-in',
              location: 'Budget Hostel',
            ),
            PlannerActivity(
              time: '11:00 AM',
              activity: 'Local Market Tour',
              location: 'Downtown',
            ),
          ],
        ),
      ],
    );
  }

  if (type == 'premium') {
    return PlannerItineraryPlan(
      title: 'Premium Adventure',
      type: 'premium',
      totalCost: isGroupTrip ? '₱15,000/person' : '₱15,000',
      duration: duration,
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
      itinerary: [
        PlannerItineraryDay(
          day: 1,
          title: 'Luxury Arrival',
          activities: [
            PlannerActivity(
              time: '10:00 AM',
              activity: 'VIP Resort Check-in',
              location: '5-Star Resort',
            ),
            PlannerActivity(
              time: '01:00 PM',
              activity: 'Welcome Spa Session',
              location: 'Resort Spa',
            ),
          ],
        ),
      ],
    );
  }

  // Balanced
  return PlannerItineraryPlan(
    title: 'Balanced Experience',
    type: 'balanced',
    totalCost: isGroupTrip ? '₱8,500/person' : '₱8,500',
    duration: duration,
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
    itinerary: [
      PlannerItineraryDay(
        day: 1,
        title: 'Welcome & Beach Time',
        activities: [
          PlannerActivity(
            time: '09:00 AM',
            activity: 'Hotel Check-in',
            location: '3-Star Hotel',
          ),
          PlannerActivity(
            time: '12:00 PM',
            activity: 'Beach Lunch',
            location: 'Seaside Restaurant',
          ),
        ],
      ),
    ],
  );
}
