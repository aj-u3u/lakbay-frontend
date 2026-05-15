import { Star, MapPin } from 'lucide-react';
import { Destination } from '../data/destinations';

interface DestinationCardProps {
  destination: Destination;
  onClick: () => void;
  variant?: 'horizontal' | 'full';
}

export function DestinationCard({ destination, onClick, variant = 'horizontal' }: DestinationCardProps) {
  return (
    <div
      onClick={onClick}
      className={`bg-card rounded-2xl overflow-hidden shadow-sm hover:shadow-md transition-shadow cursor-pointer ${
        variant === 'horizontal' ? 'flex-shrink-0 w-[280px] min-w-[280px]' : 'w-full'
      }`}
    >
      <div className="relative h-40">
        <img
          src={destination.image}
          alt={destination.name}
          className="w-full h-full object-cover"
        />
        <div className="absolute top-3 right-3 bg-white/95 backdrop-blur-sm px-2 py-1 rounded-full flex items-center gap-1">
          <Star className="w-4 h-4 text-yellow-500 fill-yellow-500" />
          <span className="text-sm">{destination.rating}</span>
        </div>
      </div>

      <div className="p-4">
        <h3 className="mb-2">{destination.name}</h3>
        <div className="flex items-center gap-1 text-muted-foreground mb-2">
          <MapPin className="w-4 h-4" />
          <span className="text-sm">{destination.district}</span>
        </div>
        <p className="text-sm text-muted-foreground line-clamp-2">
          {destination.description}
        </p>
      </div>
    </div>
  );
}
