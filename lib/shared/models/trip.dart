class Trip {
  final String id;
  final String name;
  final String destination;
  final String image;
  final DateTime startDate;
  final DateTime endDate;
  final String summary;
  final TripBudget budget;
  final List<ItineraryDay> itinerary;
  final List<TransportInfo> transport;
  final List<String> notes;
  final List<String> photos;

  Trip({
    required this.id,
    required this.name,
    required this.destination,
    required this.image,
    required this.startDate,
    required this.endDate,
    required this.summary,
    required this.budget,
    required this.itinerary,
    required this.transport,
    required this.notes,
    required this.photos,
  });
}

class TripBudget {
  final double total;
  final double spent;
  final double daily;
  final List<BudgetCategory> categories;

  TripBudget({
    required this.total,
    required this.spent,
    required this.daily,
    required this.categories,
  });
}

class BudgetCategory {
  final String name;
  final double amount;
  final String color;

  BudgetCategory({
    required this.name,
    required this.amount,
    required this.color,
  });
}

class ItineraryDay {
  final int day;
  final String title;
  final List<TripActivity> activities;

  ItineraryDay({
    required this.day,
    required this.title,
    required this.activities,
  });
}

class TripActivity {
  final String time;
  final String activity;
  final String location;

  TripActivity({
    required this.time,
    required this.activity,
    required this.location,
  });
}

class TransportInfo {
  final String from;
  final String to;
  final String mode;
  final String fare;
  final String duration;

  TransportInfo({
    required this.from,
    required this.to,
    required this.mode,
    required this.fare,
    required this.duration,
  });
}
