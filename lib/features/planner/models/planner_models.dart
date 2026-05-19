class PlannerActivity {
  String time;
  String activity;
  String location;

  PlannerActivity({
    required this.time,
    required this.activity,
    required this.location,
  });
}

class PlannerItineraryDay {
  int day;
  String title;
  List<PlannerActivity> activities;

  PlannerItineraryDay({
    required this.day,
    required this.title,
    required this.activities,
  });
}

class PlannerCostItem {
  String category;
  String amount;
  String overnightFee;
  String entranceFee;
  String transportationFee;
  String foodFee;
  String? operatingHours;

  List<PlannerAccommodationOption>? accommodations;
  List<PlannerActivityPrice>? activityPrices;

  PlannerCostItem({
    required this.category,
    required this.amount,
    required this.overnightFee,
    required this.entranceFee,
    required this.transportationFee,
    required this.foodFee,
    this.operatingHours,
    this.accommodations,
    this.activityPrices,
  });
}

class PlannerItineraryPlan {
  String title;
  String type; // budget, balanced, premium
  String totalCost;
  String duration;
  String? destinationName;
  String? destinationLocation;
  String? destinationDescription;
  List<String> highlights;
  List<PlannerCostItem> costBreakdown;
  List<PlannerItineraryDay> itinerary;

  PlannerItineraryPlan({
    required this.title,
    required this.type,
    required this.totalCost,
    required this.duration,
    this.destinationName,
    this.destinationLocation,
    this.destinationDescription,
    required this.highlights,
    required this.costBreakdown,
    required this.itinerary,
  });
}

class PlannerAccommodationOption {
  final String type;
  final String price;
  final String description;

  PlannerAccommodationOption({
    required this.type,
    required this.price,
    required this.description,
  });
}

class PlannerActivityPrice {
  final String name;
  final String price;

  PlannerActivityPrice({required this.name, required this.price});
}
