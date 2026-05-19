class Destination {
  final String id;
  final String name;
  final String district;
  final String image;
  final String description;
  final List<String> category;
  final double rating;
  final String location;
  final String entranceFee;
  final String? overnightFee;
  final String operatingHours;
  final List<String> activities;
  final List<ActivityPrice>? activityPrices;
  final List<Accommodation>? accommodations;
  final String mealInclusions;
  final String travelNotes;
  final Coordinates coordinates;
  final String bestTimeToVisit;
  final String howToGetThere;
  final String estimatedTravelTime;
  final List<String> whatToBring;
  final String mealPlanDetails;
  final AccessibilityInfo accessibility;

  Destination({
    required this.id,
    required this.name,
    required this.district,
    required this.image,
    required this.description,
    required this.category,
    required this.rating,
    required this.location,
    required this.entranceFee,
    this.overnightFee,
    required this.operatingHours,
    required this.activities,
    this.activityPrices,
    this.accommodations,
    required this.mealInclusions,
    required this.travelNotes,
    required this.coordinates,
    required this.bestTimeToVisit,
    required this.howToGetThere,
    required this.estimatedTravelTime,
    required this.whatToBring,
    required this.mealPlanDetails,
    required this.accessibility,
  });
}

class ActivityPrice {
  final String name;
  final String price;
  final bool isPerPerson;

  ActivityPrice({
    required this.name,
    required this.price,
    this.isPerPerson = true,
  });
}

class Accommodation {
  final String type;
  final String price;
  final String description;

  Accommodation({
    required this.type,
    required this.price,
    required this.description,
  });
}

class Coordinates {
  final double lat;
  final double lng;

  Coordinates({required this.lat, required this.lng});
}

class AccessibilityInfo {
  final bool isKidFriendly;
  final bool isWheelchairAccessible;
  final bool isPetFriendly;
  final bool isElderlyFriendly;

  AccessibilityInfo({
    required this.isKidFriendly,
    required this.isWheelchairAccessible,
    required this.isPetFriendly,
    required this.isElderlyFriendly,
  });
}
