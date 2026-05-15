import { useState } from 'react';
import { Search, Filter, Plus, ChevronRight, Calendar, MapPin } from 'lucide-react';
import { useNavigate } from 'react-router';
import { mockTrips } from '../data/trips';

export function TripsPage() {
  const navigate = useNavigate();
  const [searchQuery, setSearchQuery] = useState('');

  return (
    <div className="pb-20 bg-background min-h-screen">
      <div className="bg-gradient-to-b from-primary/10 to-transparent pb-6">
        <div className="p-6">
          <h2 className="mb-6">My Trips</h2>

          <div className="flex gap-2 mb-4">
            <div className="flex-1 relative">
              <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-muted-foreground" />
              <input
                type="text"
                placeholder="Search trips..."
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

          <button
            onClick={() => navigate('/ai-planner', { state: { isSolo: true } })}
            className="w-full bg-primary text-primary-foreground py-4 rounded-2xl shadow-lg hover:shadow-xl transition-all active:scale-[0.98] flex items-center justify-center gap-2"
          >
            <Plus className="w-5 h-5" />
            Create Trip
          </button>
        </div>
      </div>

      <div className="px-6 space-y-4">
        {mockTrips.length === 0 ? (
          <div className="text-center py-12">
            <div className="w-20 h-20 bg-muted rounded-full flex items-center justify-center mx-auto mb-4">
              <MapPin className="w-10 h-10 text-muted-foreground" />
            </div>
            <h3 className="mb-2">No trips yet</h3>
            <p className="text-muted-foreground mb-6">
              Start planning your first solo adventure
            </p>
          </div>
        ) : (
          mockTrips.map((trip) => (
            <div
              key={trip.id}
              onClick={() => navigate(`/trip/${trip.id}`)}
              className="bg-card rounded-2xl overflow-hidden shadow-sm hover:shadow-md transition-shadow cursor-pointer"
            >
              <div className="relative h-40">
                <img
                  src={trip.image}
                  alt={trip.name}
                  className="w-full h-full object-cover"
                />
              </div>

              <div className="p-4">
                <h3 className="mb-2">{trip.name}</h3>
                <div className="flex items-center gap-2 text-muted-foreground mb-3">
                  <Calendar className="w-4 h-4" />
                  <span className="text-sm">
                    {new Date(trip.startDate).toLocaleDateString('en-US', {
                      month: 'short',
                      day: 'numeric',
                    })}{' '}
                    -{' '}
                    {new Date(trip.endDate).toLocaleDateString('en-US', {
                      month: 'short',
                      day: 'numeric',
                      year: 'numeric',
                    })}
                  </span>
                </div>
                <p className="text-sm text-muted-foreground mb-3 line-clamp-2">
                  {trip.summary}
                </p>
                <div className="flex justify-between items-center">
                  <div className="text-sm">
                    <span className="text-muted-foreground">Budget: </span>
                    <span className="text-primary">₱{trip.budget.total.toLocaleString()}</span>
                  </div>
                  <ChevronRight className="w-5 h-5 text-muted-foreground" />
                </div>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
}
