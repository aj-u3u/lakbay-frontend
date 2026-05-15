import { useState } from 'react';
import { Search, Filter, Plus, ChevronRight, Calendar, Users } from 'lucide-react';
import { useNavigate } from 'react-router';
import { mockGroupTrips } from '../data/groups';

export function GroupsPage() {
  const navigate = useNavigate();
  const [searchQuery, setSearchQuery] = useState('');

  return (
    <div className="pb-20 bg-background min-h-screen">
      <div className="bg-gradient-to-b from-secondary/10 to-transparent pb-6">
        <div className="p-6">
          <h2 className="mb-6">Group Trips</h2>

          <div className="flex gap-2 mb-4">
            <div className="flex-1 relative">
              <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-muted-foreground" />
              <input
                type="text"
                placeholder="Search group trips..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="w-full pl-12 pr-4 py-3 bg-card rounded-2xl shadow-sm focus:outline-none focus:ring-2 focus:ring-secondary"
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
            onClick={() => navigate('/ai-planner', { state: { isSolo: false } })}
            className="w-full bg-secondary text-secondary-foreground py-4 rounded-2xl shadow-lg hover:shadow-xl transition-all active:scale-[0.98] flex items-center justify-center gap-2"
          >
            <Plus className="w-5 h-5" />
            Create Trip
          </button>
        </div>
      </div>

      <div className="px-6 space-y-4">
        {mockGroupTrips.length === 0 ? (
          <div className="text-center py-12">
            <div className="w-20 h-20 bg-muted rounded-full flex items-center justify-center mx-auto mb-4">
              <Users className="w-10 h-10 text-muted-foreground" />
            </div>
            <h3 className="mb-2">No group trips yet</h3>
            <p className="text-muted-foreground mb-6">
              Create your first group adventure with friends
            </p>
          </div>
        ) : (
          mockGroupTrips.map((group) => (
            <div
              key={group.id}
              onClick={() => navigate(`/group/${group.id}`)}
              className="bg-card rounded-2xl overflow-hidden shadow-sm hover:shadow-md transition-shadow cursor-pointer"
            >
              <div className="relative h-40">
                <img
                  src={group.image}
                  alt={group.name}
                  className="w-full h-full object-cover"
                />
              </div>

              <div className="p-4">
                <h3 className="mb-2">{group.name}</h3>
                <div className="flex items-center gap-2 text-muted-foreground mb-3">
                  <Calendar className="w-4 h-4" />
                  <span className="text-sm">
                    {new Date(group.startDate).toLocaleDateString('en-US', {
                      month: 'short',
                      day: 'numeric',
                    })}{' '}
                    -{' '}
                    {new Date(group.endDate).toLocaleDateString('en-US', {
                      month: 'short',
                      day: 'numeric',
                      year: 'numeric',
                    })}
                  </span>
                </div>
                <div className="flex items-center gap-2 text-muted-foreground mb-3">
                  <Users className="w-4 h-4" />
                  <span className="text-sm">{group.members.length} members</span>
                </div>
                <p className="text-sm text-muted-foreground mb-3 line-clamp-2">
                  {group.summary}
                </p>
                <div className="flex justify-between items-center">
                  <div className="text-sm">
                    <span className="text-muted-foreground">Total: </span>
                    <span className="text-secondary">₱{group.budget.total.toLocaleString()}</span>
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
