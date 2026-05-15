import { useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router';
import { ArrowLeft, Search } from 'lucide-react';
import { destinations, travelThemes, districts } from '../data/destinations';
import { DestinationCard } from '../components/DestinationCard';
import { DestinationPreviewModal } from '../components/DestinationPreviewModal';
import type { Destination } from '../data/destinations';

export function ShowAllPage() {
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const section = searchParams.get('section') || 'new';

  const [selectedDestination, setSelectedDestination] = useState<Destination | null>(null);
  const [searchQuery, setSearchQuery] = useState('');

  const getTitle = () => {
    if (section === 'new') return 'New & Special';
    if (section === 'popular') return 'Popular Destinations';
    if (section === 'recommended') return 'Recommended for You';
    return 'Destinations';
  };

  const getDestinations = () => {
    if (section === 'new') {
      return destinations.slice(0, 6);
    }
    if (section === 'popular') {
      return destinations.filter(d => d.rating >= 4.7);
    }
    return destinations;
  };

  const filteredDestinations = getDestinations().filter(dest =>
    dest.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    dest.district.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div className="min-h-screen bg-background pb-6">
      <div className="bg-gradient-to-b from-primary/10 to-transparent pb-6">
        <div className="p-6">
          <div className="flex items-center gap-4 mb-6">
            <button
              onClick={() => navigate('/home')}
              className="p-2 hover:bg-accent rounded-full transition-colors"
            >
              <ArrowLeft className="w-6 h-6" />
            </button>
            <h2>{getTitle()}</h2>
          </div>

          <div className="relative">
            <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-muted-foreground" />
            <input
              type="text"
              placeholder="Search destinations..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-12 pr-4 py-3 bg-card rounded-2xl shadow-sm focus:outline-none focus:ring-2 focus:ring-primary"
            />
          </div>
        </div>
      </div>

      <div className="px-6">
        {section === 'popular' && searchQuery === '' ? (
          <div className="space-y-6">
            {travelThemes.map(theme => {
              const themeDests = destinations.filter(d => d.category.includes(theme.id));
              if (themeDests.length === 0) return null;

              return (
                <div key={theme.id}>
                  <h3 className="mb-4 flex items-center gap-2">
                    <span className="text-2xl">{theme.icon}</span>
                    {theme.name}
                  </h3>
                  <div className="grid grid-cols-1 gap-4">
                    {themeDests.map(dest => (
                      <DestinationCard
                        key={dest.id}
                        destination={dest}
                        onClick={() => setSelectedDestination(dest)}
                        variant="full"
                      />
                    ))}
                  </div>
                </div>
              );
            })}
          </div>
        ) : (
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
        )}

        {filteredDestinations.length === 0 && (
          <div className="text-center py-12">
            <p className="text-muted-foreground">No destinations found</p>
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
