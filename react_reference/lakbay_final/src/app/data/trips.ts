export interface Trip {
  id: string;
  name: string;
  destination: string;
  image: string;
  startDate: string;
  endDate: string;
  summary: string;
  budget: {
    total: number;
    spent: number;
    daily: number;
    categories: {
      name: string;
      amount: number;
      color: string;
    }[];
  };
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

export const mockTrips: Trip[] = [
  {
    id: '1',
    name: 'Samal Island Escape',
    destination: 'Davao de Oro',
    image: 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=800&q=80',
    startDate: '2026-06-15',
    endDate: '2026-06-17',
    summary: 'A 3-day solo beach adventure exploring the pristine beaches and diving spots of Samal Island.',
    budget: {
      total: 8500,
      spent: 4200,
      daily: 2833,
      categories: [
        { name: 'Accommodation', amount: 3000, color: '#60A5FA' },
        { name: 'Food', amount: 2500, color: '#34D399' },
        { name: 'Transport', amount: 1500, color: '#F59E0B' },
        { name: 'Activities', amount: 1500, color: '#A78BFA' },
      ],
    },
    itinerary: [
      {
        day: 1,
        title: 'Arrival & Beach Time',
        activities: [
          { time: '08:00 AM', activity: 'Depart from Sasa Wharf', location: 'Davao City' },
          { time: '08:30 AM', activity: 'Arrive at Samal Island', location: 'Samal' },
          { time: '10:00 AM', activity: 'Check-in at beach resort', location: 'Pearl Farm Beach Resort' },
          { time: '02:00 PM', activity: 'Beach swimming and relaxation', location: 'Resort beach' },
          { time: '06:00 PM', activity: 'Sunset viewing', location: 'Beach' },
        ],
      },
      {
        day: 2,
        title: 'Island Adventure',
        activities: [
          { time: '07:00 AM', activity: 'Breakfast at resort', location: 'Resort restaurant' },
          { time: '09:00 AM', activity: 'Scuba diving session', location: 'Coral Garden' },
          { time: '01:00 PM', activity: 'Lunch and rest', location: 'Local restaurant' },
          { time: '03:00 PM', activity: 'Visit Hagimit Falls', location: 'Hagimit Falls' },
          { time: '06:00 PM', activity: 'Dinner by the beach', location: 'Resort' },
        ],
      },
      {
        day: 3,
        title: 'Departure Day',
        activities: [
          { time: '08:00 AM', activity: 'Breakfast and check-out', location: 'Resort' },
          { time: '10:00 AM', activity: 'Last beach swim', location: 'Beach' },
          { time: '12:00 PM', activity: 'Ferry back to Davao', location: 'Samal Wharf' },
        ],
      },
    ],
    transport: [
      { from: 'Davao City', to: 'Sasa Wharf', mode: 'Taxi', fare: '₱150', duration: '20 min' },
      { from: 'Sasa Wharf', to: 'Samal Island', mode: 'Ferry', fare: '₱50', duration: '15 min' },
      { from: 'Samal Wharf', to: 'Resort', mode: 'Tricycle', fare: '₱100', duration: '30 min' },
    ],
    notes: [
      'Bring sunscreen SPF 50+',
      'Underwater camera for diving',
      'Cash for local vendors',
      'Early ferry booking recommended',
    ],
    photos: [],
  },
];
