import { useState } from 'react';
import { useNavigate } from 'react-router';
import { ArrowLeft, X, ChevronDown } from 'lucide-react';
import { destinations, travelThemes, districts } from '../data/destinations';
import { DestinationCard } from '../components/DestinationCard';
import { DestinationPreviewModal } from '../components/DestinationPreviewModal';
import type { Destination } from '../data/destinations';

export function FilterPage() {
  const navigate = useNavigate();
  const [selectedThemes, setSelectedThemes] = useState<string[]>([]);
  const [selectedDistricts, setSelectedDistricts] = useState<string[]>([]);
  const [selectedDestination, setSelectedDestination] = useState<Destination | null>(null);
  const [showThemeDropdown, setShowThemeDropdown] = useState(false);
  const [showDistrictDropdown, setShowDistrictDropdown] = useState(false);

  const toggleTheme = (themeId: string) => {
    setSelectedThemes(prev =>
      prev.includes(themeId)
        ? prev.filter(t => t !== themeId)
        : [...prev, themeId]
    );
  };

  const toggleDistrict = (district: string) => {
    setSelectedDistricts(prev =>
      prev.includes(district) ? [] : [district]
    );
    setShowDistrictDropdown(false);
  };

  const clearFilters = () => {
    setSelectedThemes([]);
    setSelectedDistricts([]);
  };

  const filteredDestinations = destinations.filter(dest => {
    const themeMatch = selectedThemes.length === 0 ||
      selectedThemes.some(theme => dest.category.includes(theme));
    const districtMatch = selectedDistricts.length === 0 ||
      selectedDistricts.includes(dest.district);
    return themeMatch && districtMatch;
  });

  const hasFilters = selectedThemes.length > 0 || selectedDistricts.length > 0;

  return (
    <div
      className="min-h-screen bg-background pb-6"
      onClick={(e) => {
        const target = e.target as HTMLElement;
        if (showThemeDropdown && !target.closest('.theme-dropdown-container')) {
          setShowThemeDropdown(false);
        }
        if (showDistrictDropdown && !target.closest('.district-dropdown-container')) {
          setShowDistrictDropdown(false);
        }
      }}
    >
      <div className="bg-gradient-to-b from-primary/10 to-transparent pb-6">
        <div className="p-6">
          <div className="flex items-center justify-between mb-6">
            <div className="flex items-center gap-4">
              <button
                onClick={() => navigate('/home')}
                className="p-2 hover:bg-accent rounded-full transition-colors"
              >
                <ArrowLeft className="w-6 h-6" />
              </button>
              <h2>Filter Destinations</h2>
            </div>
            {hasFilters && (
              <button
                onClick={clearFilters}
                className="text-sm text-primary hover:underline"
              >
                Clear All
              </button>
            )}
          </div>

          <div className="space-y-6">
            <div>
              <h4 className="mb-3">Travel Themes</h4>
              <div className="relative theme-dropdown-container">
                <button
                  onClick={() => setShowThemeDropdown(!showThemeDropdown)}
                  className="w-full px-4 py-3 bg-card border border-border rounded-xl flex items-center justify-between hover:border-primary transition-colors"
                >
                  <span className="text-muted-foreground">
                    {selectedThemes.length === 0
                      ? 'Select themes...'
                      : `${selectedThemes.length} theme${selectedThemes.length !== 1 ? 's' : ''} selected`}
                  </span>
                  <ChevronDown className={`w-5 h-5 transition-transform ${showThemeDropdown ? 'rotate-180' : ''}`} />
                </button>

                {showThemeDropdown && (
                  <div className="absolute top-full left-0 right-0 mt-2 bg-card border border-border rounded-xl shadow-lg z-10 max-h-64 overflow-y-auto scrollbar-hide">
                    {travelThemes.map(theme => (
                      <button
                        key={theme.id}
                        onClick={() => {
                          toggleTheme(theme.id);
                        }}
                        className={`w-full px-4 py-3 flex items-center gap-3 hover:bg-accent transition-colors ${
                          selectedThemes.includes(theme.id) ? 'bg-primary/10' : ''
                        }`}
                      >
                        <span className="text-2xl">{theme.icon}</span>
                        <span className="flex-1 text-left">{theme.name}</span>
                        {selectedThemes.includes(theme.id) && (
                          <div className="w-5 h-5 bg-primary rounded-full flex items-center justify-center">
                            <span className="text-primary-foreground text-xs">✓</span>
                          </div>
                        )}
                      </button>
                    ))}
                  </div>
                )}
              </div>

              {selectedThemes.length > 0 && (
                <div className="flex flex-wrap gap-2 mt-3">
                  {selectedThemes.map(themeId => {
                    const theme = travelThemes.find(t => t.id === themeId);
                    return (
                      <span
                        key={themeId}
                        className="px-3 py-1 bg-primary/10 text-primary rounded-full text-sm flex items-center gap-2"
                      >
                        <span>{theme?.icon}</span>
                        <span>{theme?.name}</span>
                        <button onClick={() => toggleTheme(themeId)}>
                          <X className="w-3 h-3" />
                        </button>
                      </span>
                    );
                  })}
                </div>
              )}
            </div>

            <div>
              <h4 className="mb-3">Districts</h4>
              <div className="relative district-dropdown-container">
                <button
                  onClick={() => setShowDistrictDropdown(!showDistrictDropdown)}
                  className="w-full px-4 py-3 bg-card border border-border rounded-xl flex items-center justify-between hover:border-primary transition-colors"
                >
                  <span className={selectedDistricts.length === 0 ? 'text-muted-foreground' : ''}>
                    {selectedDistricts.length === 0
                      ? 'Select district...'
                      : selectedDistricts[0]}
                  </span>
                  <ChevronDown className={`w-5 h-5 transition-transform ${showDistrictDropdown ? 'rotate-180' : ''}`} />
                </button>

                {showDistrictDropdown && (
                  <div className="absolute top-full left-0 right-0 mt-2 bg-card border border-border rounded-xl shadow-lg z-10 max-h-64 overflow-y-auto scrollbar-hide">
                    {districts.map(district => (
                      <button
                        key={district}
                        onClick={() => {
                          toggleDistrict(district);
                        }}
                        className={`w-full px-4 py-3 flex items-center gap-3 hover:bg-accent transition-colors ${
                          selectedDistricts.includes(district) ? 'bg-primary/10' : ''
                        }`}
                      >
                        <span className="flex-1 text-left">{district}</span>
                        {selectedDistricts.includes(district) && (
                          <div className="w-5 h-5 bg-primary rounded-full flex items-center justify-center">
                            <span className="text-primary-foreground text-xs">✓</span>
                          </div>
                        )}
                      </button>
                    ))}
                  </div>
                )}
              </div>

              {selectedDistricts.length > 0 && (
                <div className="flex flex-wrap gap-2 mt-3">
                  <span className="px-3 py-1 bg-primary/10 text-primary rounded-full text-sm flex items-center gap-2">
                    <span>{selectedDistricts[0]}</span>
                    <button onClick={() => setSelectedDistricts([])}>
                      <X className="w-3 h-3" />
                    </button>
                  </span>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>

      <div className="px-6">
        <h3 className="mb-3">Discover Places</h3>
        <div className="mb-4">
          <p className="text-muted-foreground">
            {filteredDestinations.length} destination{filteredDestinations.length !== 1 ? 's' : ''} found
          </p>
        </div>

        <div className="grid grid-cols-1 gap-4">
          {filteredDestinations.slice(0, 5).map(dest => (
            <DestinationCard
              key={dest.id}
              destination={dest}
              onClick={() => setSelectedDestination(dest)}
              variant="full"
            />
          ))}
        </div>

        {filteredDestinations.length > 5 && (
          <div className="mt-6 text-center">
            <button
              onClick={() => {
                navigate('/filtered-results', {
                  state: {
                    selectedThemes,
                    selectedDistricts,
                  },
                });
              }}
              className="px-6 py-3 bg-primary text-primary-foreground rounded-xl hover:bg-primary/90 transition-colors"
            >
              See More ({filteredDestinations.length - 5} more)
            </button>
          </div>
        )}

        {filteredDestinations.length === 0 && (
          <div className="text-center py-12">
            <p className="text-muted-foreground">No destinations match your filters</p>
            <button
              onClick={clearFilters}
              className="mt-4 text-primary hover:underline"
            >
              Clear filters to see all destinations
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
