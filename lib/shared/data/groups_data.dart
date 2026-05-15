import '../models/group_trip.dart';

final List<GroupTrip> mockGroupTrips = [
  GroupTrip(
    id: '1',
    name: 'Mt. Apo Adventure',
    destination: 'Mt. Apo, Davao City',
    image: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80',
    startDate: DateTime(2026, 7, 10),
    endDate: DateTime(2026, 7, 13),
    summary: 'A 4-day group trekking adventure conquering the highest peak in the Philippines.',
    members: [
      GroupMember(
        id: '1',
        name: 'Juan Dela Cruz',
        avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Juan',
        isLeader: true,
        contribution: 4000,
        spent: 1200,
      ),
      GroupMember(
        id: '2',
        name: 'Maria Santos',
        avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Maria',
        isLeader: false,
        contribution: 4000,
        spent: 1200,
      ),
      GroupMember(
        id: '3',
        name: 'Pedro Reyes',
        avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Pedro',
        isLeader: false,
        contribution: 4000,
        spent: 1200,
      ),
      GroupMember(
        id: '4',
        name: 'Ana Garcia',
        avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Ana',
        isLeader: false,
        contribution: 4000,
        spent: 1200,
      ),
    ],
    budget: GroupBudget(
      total: 16000,
      perPerson: 4000,
      spent: 4800,
      categories: [
        GroupBudgetCategory(name: 'Guide Fees', amount: 5000, color: '#60A5FA'),
        GroupBudgetCategory(name: 'Food & Supplies', amount: 4000, color: '#34D399'),
        GroupBudgetCategory(name: 'Transportation', amount: 3000, color: '#F59E0B'),
        GroupBudgetCategory(name: 'Permits & Fees', amount: 2000, color: '#A78BFA'),
        GroupBudgetCategory(name: 'Equipment Rental', amount: 2000, color: '#F87171'),
      ],
    ),
    tasks: [
      GroupTask(id: '1', title: 'Book mountain guide', assignedTo: 'Juan Dela Cruz', completed: true),
      GroupTask(id: '2', title: 'Prepare camping equipment', assignedTo: 'Pedro Reyes', completed: true),
      GroupTask(id: '3', title: 'Buy food supplies', assignedTo: 'Maria Santos', completed: false),
      GroupTask(id: '4', title: 'Arrange transportation', assignedTo: 'Ana Garcia', completed: false),
      GroupTask(id: '5', title: 'Get climbing permits', assignedTo: 'Juan Dela Cruz', completed: false),
    ],
    itinerary: [
      GroupItineraryDay(
        day: 1,
        title: 'Trek to Base Camp',
        activities: [
          GroupTripActivity(time: '06:00 AM', activity: 'Depart from Davao City', location: 'Davao City'),
          GroupTripActivity(time: '09:00 AM', activity: 'Arrive at trailhead', location: 'Kapatagan'),
          GroupTripActivity(time: '10:00 AM', activity: 'Begin trek to base camp', location: 'Mt. Apo Trail'),
          GroupTripActivity(time: '04:00 PM', activity: 'Arrive at base camp', location: 'Base Camp'),
          GroupTripActivity(time: '06:00 PM', activity: 'Dinner and rest', location: 'Base Camp'),
        ],
      ),
      GroupItineraryDay(
        day: 2,
        title: 'Summit Day',
        activities: [
          GroupTripActivity(time: '02:00 AM', activity: 'Wake up and prepare', location: 'Base Camp'),
          GroupTripActivity(time: '03:00 AM', activity: 'Begin summit push', location: 'Summit Trail'),
          GroupTripActivity(time: '07:00 AM', activity: 'Reach summit', location: 'Mt. Apo Peak'),
          GroupTripActivity(time: '09:00 AM', activity: 'Descend to base camp', location: 'Summit Trail'),
          GroupTripActivity(time: '02:00 PM', activity: 'Rest at base camp', location: 'Base Camp'),
        ],
      ),
      GroupItineraryDay(
        day: 3,
        title: 'Explore & Descend',
        activities: [
          GroupTripActivity(time: '08:00 AM', activity: 'Explore nearby waterfalls', location: 'Lake Venado'),
          GroupTripActivity(time: '12:00 PM', activity: 'Lunch break', location: 'Base Camp'),
          GroupTripActivity(time: '02:00 PM', activity: 'Begin descent', location: 'Trail'),
          GroupTripActivity(time: '06:00 PM', activity: 'Arrive at lower camp', location: 'Lower Camp'),
        ],
      ),
      GroupItineraryDay(
        day: 4,
        title: 'Return to Davao',
        activities: [
          GroupTripActivity(time: '07:00 AM', activity: 'Final descent to trailhead', location: 'Trail'),
          GroupTripActivity(time: '11:00 AM', activity: 'Depart for Davao City', location: 'Kapatagan'),
          GroupTripActivity(time: '02:00 PM', activity: 'Arrive in Davao City', location: 'Davao City'),
        ],
      ),
    ],
    transport: [
      GroupTransportInfo(from: 'Davao City', to: 'Kapatagan', mode: 'Van', fare: '₱500/person', duration: '3 hours'),
      GroupTransportInfo(from: 'Kapatagan', to: 'Trailhead', mode: 'Habal-habal', fare: '₱150/person', duration: '30 min'),
    ],
    notes: [
      'Physical fitness required - practice hiking beforehand',
      'Bring warm clothing and rain gear',
      'Pack light but essential items only',
      'Stay hydrated throughout the climb',
      'Follow guide instructions at all times',
    ],
    photos: [],
  ),
];
