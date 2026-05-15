export interface Destination {
  id: string;
  name: string;
  district: string;
  image: string;
  description: string;
  category: string[];
  rating: number;
  location: string;
  entranceFee: string;
  activities: string[];
  mealInclusions: string;
  travelNotes: string;
  coordinates: { lat: number; lng: number };
}

export const destinations: Destination[] = [
  {
    id: '1',
    name: 'Eden Nature Park',
    district: 'Davao City',
    image: 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800&q=80',
    description: 'A mountain resort and nature park offering stunning views, adventure activities, and fresh mountain air.',
    category: ['nature', 'adventure'],
    rating: 4.8,
    location: 'Toril, Davao City',
    entranceFee: '₱150 per person',
    activities: ['Hiking', 'Ziplining', 'Bird Watching', 'Photography', 'Fishing'],
    mealInclusions: 'Restaurant available with local and international cuisine',
    travelNotes: 'Best visited early morning. Bring sunscreen and comfortable shoes.',
    coordinates: { lat: 7.1907, lng: 125.4553 }
  },
  {
    id: '2',
    name: 'Samal Island Beach',
    district: 'Davao de Oro',
    image: 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=800&q=80',
    description: 'Paradise island with pristine white sand beaches and crystal clear waters.',
    category: ['beach', 'adventure'],
    rating: 4.9,
    location: 'Davao de Oro',
    entranceFee: '₱50 boat ride + resort fees vary',
    activities: ['Swimming', 'Snorkeling', 'Diving', 'Beach Volleyball', 'Island Hopping'],
    mealInclusions: 'Fresh seafood and local dishes available at beach resorts',
    travelNotes: 'Ferry departs from Sasa Wharf. Book accommodation in advance during peak season.',
    coordinates: { lat: 7.0833, lng: 125.7167 }
  },
  {
    id: '3',
    name: 'Mt. Apo',
    district: 'Davao City',
    image: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80',
    description: "The Philippines' highest peak, offering challenging trails and breathtaking summit views.",
    category: ['adventure', 'nature'],
    rating: 4.7,
    location: 'Davao City - Kidapawan boundary',
    entranceFee: '₱2,000-₱5,000 (guide and permit fees)',
    activities: ['Mountain Climbing', 'Camping', 'Bird Watching', 'Photography', 'Nature Trekking'],
    mealInclusions: 'Bring your own food and camping supplies',
    travelNotes: 'Requires physical fitness. 2-3 days climb. Register with local tourism office.',
    coordinates: { lat: 7.0067, lng: 125.2728 }
  },
  {
    id: '4',
    name: 'Philippine Eagle Center',
    district: 'Davao City',
    image: 'https://images.unsplash.com/photo-1552728089-57bdde30beb3?w=800&q=80',
    description: 'Conservation center dedicated to protecting the critically endangered Philippine Eagle.',
    category: ['culture', 'nature'],
    rating: 4.6,
    location: 'Malagos, Calinan, Davao City',
    entranceFee: '₱100 per person',
    activities: ['Bird Watching', 'Educational Tours', 'Photography', 'Nature Walks'],
    mealInclusions: 'Snack bar available',
    travelNotes: 'Open daily 8AM-4PM. Cool weather, bring light jacket.',
    coordinates: { lat: 7.2333, lng: 125.3667 }
  },
  {
    id: '5',
    name: 'Dahican Beach',
    district: 'Davao Oriental',
    image: 'https://images.unsplash.com/photo-1473496169904-658ba7c44d8a?w=800&q=80',
    description: 'A surfer\'s paradise with powerful waves and golden sand stretching for kilometers.',
    category: ['beach', 'adventure'],
    rating: 4.8,
    location: 'Mati, Davao Oriental',
    entranceFee: '₱20 per person',
    activities: ['Surfing', 'Skim Boarding', 'Beach Walking', 'Swimming', 'Sunset Watching'],
    mealInclusions: 'Beachfront cafes and restaurants available',
    travelNotes: 'Best surfing season: October to March. Rent surf boards on-site.',
    coordinates: { lat: 6.9544, lng: 126.2331 }
  },
  {
    id: '6',
    name: 'Monfort Bat Sanctuary',
    district: 'Davao de Oro',
    image: 'https://images.unsplash.com/photo-1585421514738-01798e348b17?w=800&q=80',
    description: 'Guinness World Record holder for the largest colony of Geoffrey\'s Rousette fruit bats.',
    category: ['nature', 'culture'],
    rating: 4.5,
    location: 'Babak District, Samal Island',
    entranceFee: '₱50 per person',
    activities: ['Wildlife Observation', 'Photography', 'Guided Tours', 'Educational Experience'],
    mealInclusions: 'No food available on-site',
    travelNotes: 'Best visited at dusk to see bats flying out. Maintain silence inside the cave.',
    coordinates: { lat: 7.1333, lng: 125.6500 }
  },
  {
    id: '7',
    name: 'Malagos Garden Resort',
    district: 'Davao City',
    image: 'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=800&q=80',
    description: 'Family-friendly resort featuring butterfly sanctuary, bird park, and chocolate museum.',
    category: ['culture', 'nature'],
    rating: 4.7,
    location: 'Calinan, Davao City',
    entranceFee: '₱350-₱550 (packages available)',
    activities: ['Butterfly Watching', 'Bird Feeding', 'Chocolate Making', 'Swimming', 'Horseback Riding'],
    mealInclusions: 'On-site restaurant with buffet options',
    travelNotes: 'Perfect for families. Book chocolate museum tour in advance.',
    coordinates: { lat: 7.2500, lng: 125.3833 }
  },
  {
    id: '8',
    name: 'Hagimit Falls',
    district: 'Davao del Sur',
    image: 'https://images.unsplash.com/photo-1432405972618-c60b0225b8f9?w=800&q=80',
    description: 'Multi-tiered waterfall surrounded by lush forest, perfect for nature lovers.',
    category: ['nature', 'adventure'],
    rating: 4.6,
    location: 'Sta. Cruz, Davao del Sur',
    entranceFee: '₱30 per person',
    activities: ['Swimming', 'Trekking', 'Photography', 'Picnicking', 'Nature Exploration'],
    mealInclusions: 'Bring packed lunch',
    travelNotes: '30-minute trek required. Wear proper footwear. Not accessible during heavy rain.',
    coordinates: { lat: 6.8667, lng: 125.3333 }
  }
];

export const travelThemes = [
  { id: 'beach', name: 'Beach Paradise', icon: '🏖️', color: '#60A5FA' },
  { id: 'nature', name: 'Nature Escape', icon: '🌿', color: '#34D399' },
  { id: 'adventure', name: 'Adventure', icon: '🏔️', color: '#F59E0B' },
  { id: 'culture', name: 'Culture & Heritage', icon: '🏛️', color: '#A78BFA' },
  { id: 'food', name: 'Food / Night Market', icon: '🍜', color: '#EF4444' },
  { id: 'farm', name: 'Farm / Agri-tourism', icon: '🌾', color: '#84CC16' },
  { id: 'wildlife', name: 'Wildlife / Zoo', icon: '🦁', color: '#F97316' },
  { id: 'mall', name: 'Mall / Shopping', icon: '🛍️', color: '#8B5CF6' },
  { id: 'resort', name: 'Resort', icon: '🏨', color: '#06B6D4' },
  { id: 'viewpoint', name: 'Viewpoint', icon: '🌄', color: '#EC4899' }
];

export const districts = [
  'Davao City',
  'Davao de Oro',
  'Davao del Norte',
  'Davao del Sur',
  'Davao Oriental'
];
