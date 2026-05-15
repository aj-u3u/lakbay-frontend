import '../models/trip.dart';

final List<Trip> mockTrips = [
  Trip(
    id: '1',
    name: 'Samal Island Escape',
    destination: 'Davao de Oro',
    image: 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=800&q=80',
    startDate: DateTime(2026, 6, 15),
    endDate: DateTime(2026, 6, 17),
    summary: 'A 3-day solo beach adventure exploring the pristine beaches and diving spots of Samal Island.',
    budget: TripBudget(
      total: 8500,
      spent: 4200,
      daily: 2833,
      categories: [
        BudgetCategory(name: 'Accommodation', amount: 3000, color: '#60A5FA'),
        BudgetCategory(name: 'Food', amount: 2500, color: '#34D399'),
        BudgetCategory(name: 'Transport', amount: 1500, color: '#F59E0B'),
        BudgetCategory(name: 'Activities', amount: 1500, color: '#A78BFA'),
      ],
    ),
    itinerary: [
      ItineraryDay(
        day: 1,
        title: 'Arrival & Beach Time',
        activities: [
          TripActivity(time: '08:00 AM', activity: 'Depart from Sasa Wharf', location: 'Davao City'),
          TripActivity(time: '08:30 AM', activity: 'Arrive at Samal Island', location: 'Samal'),
          TripActivity(time: '10:00 AM', activity: 'Check-in at beach resort', location: 'Pearl Farm Beach Resort'),
          TripActivity(time: '02:00 PM', activity: 'Beach swimming and relaxation', location: 'Resort beach'),
          TripActivity(time: '06:00 PM', activity: 'Sunset viewing', location: 'Beach'),
        ],
      ),
      ItineraryDay(
        day: 2,
        title: 'Island Adventure',
        activities: [
          TripActivity(time: '07:00 AM', activity: 'Breakfast at resort', location: 'Resort restaurant'),
          TripActivity(time: '09:00 AM', activity: 'Scuba diving session', location: 'Coral Garden'),
          TripActivity(time: '01:00 PM', activity: 'Lunch and rest', location: 'Local restaurant'),
          TripActivity(time: '03:00 PM', activity: 'Visit Hagimit Falls', location: 'Hagimit Falls'),
          TripActivity(time: '06:00 PM', activity: 'Dinner by the beach', location: 'Resort'),
        ],
      ),
      ItineraryDay(
        day: 3,
        title: 'Departure Day',
        activities: [
          TripActivity(time: '08:00 AM', activity: 'Breakfast and check-out', location: 'Resort'),
          TripActivity(time: '10:00 AM', activity: 'Last beach swim', location: 'Beach'),
          TripActivity(time: '12:00 PM', activity: 'Ferry back to Davao', location: 'Samal Wharf'),
        ],
      ),
    ],
    transport: [
      TransportInfo(from: 'Davao City', to: 'Sasa Wharf', mode: 'Taxi', fare: '₱150', duration: '20 min'),
      TransportInfo(from: 'Sasa Wharf', to: 'Samal Island', mode: 'Ferry', fare: '₱50', duration: '15 min'),
      TransportInfo(from: 'Samal Wharf', to: 'Resort', mode: 'Tricycle', fare: '₱100', duration: '30 min'),
    ],
    notes: [
      'Bring sunscreen SPF 50+',
      'Underwater camera for diving',
      'Cash for local vendors',
      'Early ferry booking recommended',
    ],
    photos: [],
  ),
];
