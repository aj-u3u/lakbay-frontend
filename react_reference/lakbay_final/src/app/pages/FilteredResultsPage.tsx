import { useState } from 'react';
import { useNavigate, useLocation } from 'react-router';
import { ArrowLeft } from 'lucide-react';
import { destinations } from '../data/destinations';
import { DestinationCard } from '../components/DestinationCard';
import { DestinationPreviewModal } from '../components/DestinationPreviewModal';
import type { Destination } from '../data/destinations';

export function FilteredResultsPage() {
  const navigate = useNavigate();
  const location = useLocation();
  const [selectedDestination, setSelectedDestination] = useState<Destination | null>(null);

  const { selectedThemes = [], selectedDistricts = [] } = location.state || {};

  const filteredDestinations = destinations.filter(dest => {
    const themeMatch = selectedThemes.length === 0 ||
      selectedThemes.some((theme: string) => dest.category.includes(theme));
    const districtMatch = selectedDistricts.length === 0 ||
      selectedDistricts.includes(dest.district);
    return themeMatch && districtMatch;
  });

  return (
    <div className="min-h-screen bg-background pb-6">
      <div className="bg-gradient-to-b from-primary/10 to-transparent pb-6">
        <div className="p-6">
          <div className="flex items-center gap-4 mb-6">
            <button
              onClick={() => navigate('/filter')}
              className="p-2 hover:bg-accent rounded-full transition-colors"
            >
              <ArrowLeft className="w-6 h-6" />
            </button>
            <h2>Filtered Results</h2>
          </div>

          <div className="mb-4">
            <p className="text-muted-foreground">
              {filteredDestinations.length} destination{filteredDestinations.length !== 1 ? 's' : ''} found
            </p>
          </div>
        </div>
      </div>

      <div className="px-6">
        <div className="grid grid-cols-1 gap-4">
          {filteredDestinations.map(dest => (
            <DestinationCard
              key={dest.id}
              destination={dest}
              onClick={() => setSelectedDestination(dest)}
              variant="full"
            />
          ))}
        </div>

        {filteredDestinations.length === 0 && (
          <div className="text-center py-12">
            <p className="text-muted-foreground">No destinations match your filters</p>
            <button
              onClick={() => navigate('/filter')}
              className="mt-4 text-primary hover:underline"
            >
              Go back to filters
            </button>
          </div>
        )}
      </div>

      {selectedDestination && (
        <DestinationPreviewModal
          destination={selectedDestination}
          onClose={() => setSelectedDestination(null)}
          onViewDetails={() => {
            navigate(`/destination/${selectedDestination.id}`);
          }}
        />
      )}
    </div>
  );
}
