export interface GroupMember {
  id: string;
  name: string;
  avatar: string;
  isLeader: boolean;
  contribution: number;
  spent: number;
}

export interface GroupTask {
  id: string;
  title: string;
  assignedTo: string;
  completed: boolean;
}

export interface GroupTrip {
  id: string;
  name: string;
  destination: string;
  image: string;
  startDate: string;
  endDate: string;
  summary: string;
  members: GroupMember[];
  budget: {
    total: number;
    perPerson: number;
    spent: number;
    categories: {
      name: string;
      amount: number;
      color: string;
    }[];
  };
  tasks: GroupTask[];
  itinerary: {
    day: number;
    title: string;
    activities: {
      time: string;
      activity: string;
      location: string;
    }[];
  }[];
  transport: {
    from: string;
    to: string;
    mode: string;
    fare: string;
    duration: string;
  }[];
  notes: string[];
  photos: string[];
}

export const mockGroupTrips: GroupTrip[] = [
  {
    id: '1',
    name: 'Mt. Apo Adventure',
    destination: 'Mt. Apo, Davao City',
    image: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80',
    startDate: '2026-07-10',
    endDate: '2026-07-13',
    summary: 'A 4-day group trekking adventure conquering the highest peak in the Philippines.',
    members: [
      {
        id: '1',
        name: 'Juan Dela Cruz',
        avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Juan',
        isLeader: true,
        contribution: 4000,
        spent: 1200,
      },
      {
        id: '2',
        name: 'Maria Santos',
        avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Maria',
        isLeader: false,
        contribution: 4000,
        spent: 1200,
      },
      {
        id: '3',
        name: 'Pedro Reyes',
        avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Pedro',
        isLeader: false,
        contribution: 4000,
        spent: 1200,
      },
      {
        id: '4',
        name: 'Ana Garcia',
        avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Ana',
        isLeader: false,
        contribution: 4000,
        spent: 1200,
      },
    ],
    budget: {
      total: 16000,
      perPerson: 4000,
      spent: 4800,
      categories: [
        { name: 'Guide Fees', amount: 5000, color: '#60A5FA' },
        { name: 'Food & Supplies', amount: 4000, color: '#34D399' },
        { name: 'Transportation', amount: 3000, color: '#F59E0B' },
        { name: 'Permits & Fees', amount: 2000, color: '#A78BFA' },
        { name: 'Equipment Rental', amount: 2000, color: '#F87171' },
      ],
    },
    tasks: [
      { id: '1', title: 'Book mountain guide', assignedTo: 'Juan Dela Cruz', completed: true },
      { id: '2', title: 'Prepare camping equipment', assignedTo: 'Pedro Reyes', completed: true },
      { id: '3', title: 'Buy food supplies', assignedTo: 'Maria Santos', completed: false },
      { id: '4', title: 'Arrange transportation', assignedTo: 'Ana Garcia', completed: false },
      { id: '5', title: 'Get climbing permits', assignedTo: 'Juan Dela Cruz', completed: false },
    ],
    itinerary: [
      {
        day: 1,
        title: 'Trek to Base Camp',
        activities: [
          { time: '06:00 AM', activity: 'Depart from Davao City', location: 'Davao City' },
          { time: '09:00 AM', activity: 'Arrive at trailhead', location: 'Kapatagan' },
          { time: '10:00 AM', activity: 'Begin trek to base camp', location: 'Mt. Apo Trail' },
          { time: '04:00 PM', activity: 'Arrive at base camp', location: 'Base Camp' },
          { time: '06:00 PM', activity: 'Dinner and rest', location: 'Base Camp' },
        ],
      },
      {
        day: 2,
        title: 'Summit Day',
        activities: [
          { time: '02:00 AM', activity: 'Wake up and prepare', location: 'Base Camp' },
          { time: '03:00 AM', activity: 'Begin summit push', location: 'Summit Trail' },
          { time: '07:00 AM', activity: 'Reach summit', location: 'Mt. Apo Peak' },
          { time: '09:00 AM', activity: 'Descend to base camp', location: 'Summit Trail' },
          { time: '02:00 PM', activity: 'Rest at base camp', location: 'Base Camp' },
        ],
      },
      {
        day: 3,
        title: 'Explore & Descend',
        activities: [
          { time: '08:00 AM', activity: 'Explore nearby waterfalls', location: 'Lake Venado' },
          { time: '12:00 PM', activity: 'Lunch break', location: 'Base Camp' },
          { time: '02:00 PM', activity: 'Begin descent', location: 'Trail' },
          { time: '06:00 PM', activity: 'Arrive at lower camp', location: 'Lower Camp' },
        ],
      },
      {
        day: 4,
        title: 'Return to Davao',
        activities: [
          { time: '07:00 AM', activity: 'Final descent to trailhead', location: 'Trail' },
          { time: '11:00 AM', activity: 'Depart for Davao City', location: 'Kapatagan' },
          { time: '02:00 PM', activity: 'Arrive in Davao City', location: 'Davao City' },
        ],
      },
    ],
    transport: [
      { from: 'Davao City', to: 'Kapatagan', mode: 'Van', fare: '₱500/person', duration: '3 hours' },
      { from: 'Kapatagan', to: 'Trailhead', mode: 'Habal-habal', fare: '₱150/person', duration: '30 min' },
    ],
    notes: [
      'Physical fitness required - practice hiking beforehand',
      'Bring warm clothing and rain gear',
      'Pack light but essential items only',
      'Stay hydrated throughout the climb',
      'Follow guide instructions at all times',
    ],
    photos: [],
  },
];
