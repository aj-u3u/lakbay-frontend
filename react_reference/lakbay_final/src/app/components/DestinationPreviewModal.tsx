import { X, MapPin, Star, DollarSign, ChevronRight } from 'lucide-react';
import { Destination } from '../data/destinations';

interface DestinationPreviewModalProps {
  destination: Destination;
  onClose: () => void;
  onViewDetails: () => void;
}

export function DestinationPreviewModal({
  destination,
  onClose,
  onViewDetails,
}: DestinationPreviewModalProps) {
  return (
    <div
      className="fixed inset-0 bg-black/50 z-50 flex items-end sm:items-center justify-center p-0 sm:p-4"
      onClick={onClose}
    >
      <div
        className="bg-card w-full max-w-lg rounded-t-3xl sm:rounded-3xl max-h-[90vh] overflow-y-auto"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="sticky top-0 bg-card z-10 flex justify-between items-center p-4 border-b border-border">
          <h3>Quick Preview</h3>
          <button
            onClick={onClose}
            className="p-2 hover:bg-accent rounded-full transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        <div className="p-4">
          <div className="relative h-48 rounded-xl overflow-hidden mb-4">
            <img
              src={destination.image}
              alt={destination.name}
              className="w-full h-full object-cover"
            />
            <div className="absolute top-3 right-3 bg-white/95 backdrop-blur-sm px-3 py-1 rounded-full flex items-center gap-1">
              <Star className="w-4 h-4 text-yellow-500 fill-yellow-500" />
              <span>{destination.rating}</span>
            </div>
          </div>

          <h2 className="mb-2">{destination.name}</h2>

          <div className="space-y-3 mb-4">
            <div className="flex items-center gap-2 text-muted-foreground">
              <MapPin className="w-5 h-5" />
              <span>{destination.location}</span>
            </div>
            <div className="flex items-center gap-2 text-muted-foreground">
              <DollarSign className="w-5 h-5" />
              <span>{destination.entranceFee}</span>
            </div>
          </div>

          <p className="text-muted-foreground mb-4">{destination.description}</p>

          <div className="mb-4">
            <h4 className="mb-2">Top Activities</h4>
            <div className="flex flex-wrap gap-2">
              {destination.activities.slice(0, 4).map((activity, idx) => (
                <span
                  key={idx}
                  className="px-3 py-1 bg-accent rounded-full text-sm"
                >
                  {activity}
                </span>
              ))}
            </div>
          </div>

          <div className="bg-muted/30 rounded-xl p-3 mb-4">
            <div className="aspect-video bg-accent rounded-lg flex items-center justify-center text-muted-foreground">
              <MapPin className="w-8 h-8" />
              <span className="ml-2">Map View</span>
            </div>
          </div>

          <button
            onClick={onViewDetails}
            className="w-full bg-primary text-primary-foreground py-4 rounded-xl flex items-center justify-center gap-2 hover:shadow-lg transition-all active:scale-[0.98]"
          >
            View Full Details
            <ChevronRight className="w-5 h-5" />
          </button>
        </div>
      </div>
    </div>
  );
}
