import { useState } from 'react';
import { Search, Filter, Bell, ChevronRight } from 'lucide-react';
import { useNavigate } from 'react-router';
import { destinations, districts } from '../data/destinations';
import { DestinationCard } from '../components/DestinationCard';
import { DestinationPreviewModal } from '../components/DestinationPreviewModal';
import type { Destination } from '../data/destinations';

export function HomePage() {
  const navigate = useNavigate();
  const [selectedDestination, setSelectedDestination] = useState<Destination | null>(null);
  const [searchQuery, setSearchQuery] = useState('');

  const newDestinations = destinations.slice(0, 3);

  return (
    <div className="pb-20 bg-background min-h-screen">
      <div className="bg-gradient-to-b from-primary/10 to-transparent pb-6">
        <div className="p-6">
          <div className="flex justify-between items-center mb-6">
            <div>
              <p className="text-muted-foreground">Good morning,</p>
              <h2>Juan! 👋</h2>
            </div>
            <button
              onClick={() => navigate('/notifications')}
              className="p-3 bg-card rounded-full shadow-sm hover:shadow-md transition-shadow relative"
            >
              <Bell className="w-5 h-5" />
              <span className="absolute top-2 right-2 w-2 h-2 bg-secondary rounded-full"></span>
            </button>
          </div>

          <div className="flex gap-2">
            <div className="flex-1 relative">
              <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-muted-foreground" />
              <input
                type="text"
                placeholder="Search destinations..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="w-full pl-12 pr-4 py-3 bg-card rounded-2xl shadow-sm focus:outline-none focus:ring-2 focus:ring-primary"
              />
            </div>
            <button
              onClick={() => navigate('/filter')}
              className="p-3 bg-card rounded-2xl shadow-sm hover:shadow-md transition-shadow"
            >
              <Filter className="w-5 h-5" />
            </button>
          </div>
        </div>
      </div>

      <div className="px-6 space-y-8">
        <section>
          <h3 className="mb-4">Trending Now</h3>
          <div className="grid grid-cols-2 gap-3">
            <div
              onClick={() => setSelectedDestination(destinations[1])}
              className="col-span-2 h-40 bg-card rounded-2xl overflow-hidden shadow-sm hover:shadow-md transition-shadow cursor-pointer relative"
            >
              <img
                src="https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=800&q=80"
                alt="Featured"
                className="w-full h-full object-cover"
              />
              <div className="absolute inset-0 bg-gradient-to-t from-black/70 to-transparent"></div>
              <div className="absolute bottom-0 left-0 right-0 p-4 text-white">
                <div className="flex items-center gap-2 mb-1">
                  <span className="px-2 py-1 bg-secondary rounded-full text-xs">⭐ Top Pick</span>
                </div>
                <h4 className="text-white mb-1">Samal Island Beach</h4>
                <p className="text-xs text-white/80">Paradise awaits 🌴</p>
              </div>
            </div>

            <div
              onClick={() => setSelectedDestination(destinations[0])}
              className="h-32 bg-card rounded-2xl overflow-hidden shadow-sm hover:shadow-md transition-shadow cursor-pointer relative"
            >
              <img
                src="https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800&q=80"
                alt="Eden Park"
                className="w-full h-full object-cover"
              />
              <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent"></div>
              <div className="absolute bottom-0 left-0 right-0 p-3 text-white">
                <p className="text-xs text-white/90">Eden Nature</p>
              </div>
            </div>

            <div
              onClick={() => setSelectedDestination(destinations[3])}
              className="h-32 bg-card rounded-2xl overflow-hidden shadow-sm hover:shadow-md transition-shadow cursor-pointer relative"
            >
              <img
                src="https://images.unsplash.com/photo-1552728089-57bdde30beb3?w=800&q=80"
                alt="Eagle Center"
                className="w-full h-full object-cover"
              />
              <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent"></div>
              <div className="absolute bottom-0 left-0 right-0 p-3 text-white">
                <p className="text-xs text-white/90">Eagle Center</p>
              </div>
            </div>
          </div>
        </section>

        <section>
          <div className="flex justify-between items-center mb-4">
            <h3>New & Special</h3>
            <button
              onClick={() => navigate('/show-all?section=new')}
              className="text-primary text-sm flex items-center gap-1 hover:underline"
            >
              Show All
              <ChevronRight className="w-4 h-4" />
            </button>
          </div>
          <div className="flex gap-4 overflow-x-auto pb-2 scrollbar-hide">
            {newDestinations.map((dest) => (
              <DestinationCard
                key={dest.id}
                destination={dest}
                onClick={() => setSelectedDestination(dest)}
              />
            ))}
          </div>
        </section>

        <section>
          <h3 className="mb-4">Travel Tips</h3>
          <div className="bg-gradient-to-r from-primary/10 via-secondary/10 to-primary/10 rounded-2xl p-5">
            <div className="flex items-start gap-4">
              <div className="w-12 h-12 bg-primary rounded-full flex items-center justify-center flex-shrink-0">
                <span className="text-2xl">💡</span>
              </div>
              <div className="flex-1">
                <h4 className="mb-2">Best Time to Visit Davao</h4>
                <p className="text-sm text-muted-foreground">
                  November to March offers the best weather for outdoor activities and beach trips. Expect sunny days and cool evenings perfect for exploring!
                </p>
              </div>
            </div>
          </div>
        </section>

        <section>
          <h3 className="mb-4">Weekend Getaways</h3>
          <div className="overflow-x-auto pb-2 scrollbar-hide">
            <div className="flex gap-3">
              <div className="bg-gradient-to-br from-pink-500 to-rose-500 rounded-2xl p-5 text-white min-w-[200px] shadow-lg">
                <span className="text-3xl mb-2 block">🌅</span>
                <h4 className="text-white mb-1">Beach Sunset</h4>
                <p className="text-xs text-white/80 mb-3">Perfect for couples</p>
                <p className="text-xs text-white/70">2D/1N • from ₱3,500</p>
              </div>

              <div className="bg-gradient-to-br from-teal-500 to-cyan-500 rounded-2xl p-5 text-white min-w-[200px] shadow-lg">
                <span className="text-3xl mb-2 block">🏕️</span>
                <h4 className="text-white mb-1">Mountain Camp</h4>
                <p className="text-xs text-white/80 mb-3">Adventure seekers</p>
                <p className="text-xs text-white/70">3D/2N • from ₱5,000</p>
              </div>

              <div className="bg-gradient-to-br from-amber-500 to-orange-500 rounded-2xl p-5 text-white min-w-[200px] shadow-lg">
                <span className="text-3xl mb-2 block">🎭</span>
                <h4 className="text-white mb-1">Culture Tour</h4>
                <p className="text-xs text-white/80 mb-3">History lovers</p>
                <p className="text-xs text-white/70">1 Day • from ₱1,500</p>
              </div>
            </div>
          </div>
        </section>

        <section>
          <div className="flex justify-between items-center mb-4">
            <h3>Recommended for You</h3>
            <button
              onClick={() => navigate('/show-all?section=recommended')}
              className="text-primary text-sm flex items-center gap-1 hover:underline"
            >
              Show All
              <ChevronRight className="w-4 h-4" />
            </button>
          </div>

          {districts.map((district) => {
            const districtDests = destinations.filter((d) => d.district === district);
            if (districtDests.length === 0) return null;

            return (
              <div key={district} className="mb-6">
                <h4 className="mb-3 text-muted-foreground">{district}</h4>
                <div className="flex gap-4 overflow-x-auto pb-2 scrollbar-hide">
                  {districtDests.map((dest) => (
                    <DestinationCard
                      key={dest.id}
                      destination={dest}
                      onClick={() => setSelectedDestination(dest)}
                    />
                  ))}
                </div>
              </div>
            );
          })}
        </section>
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

      <style>{`
        .scrollbar-hide::-webkit-scrollbar {
          display: none;
        }
        .scrollbar-hide {
          -ms-overflow-style: none;
          scrollbar-width: none;
        }
      `}</style>
    </div>
  );
}
