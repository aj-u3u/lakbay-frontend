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
  final List<String> activities;
  final String mealInclusions;
  final String travelNotes;
  final Coordinates coordinates;

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
    required this.activities,
    required this.mealInclusions,
    required this.travelNotes,
    required this.coordinates,
  });
}

class Coordinates {
  final double lat;
  final double lng;

  Coordinates({required this.lat, required this.lng});
}
