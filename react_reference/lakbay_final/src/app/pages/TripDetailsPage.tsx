import { useState } from 'react';
import { useParams, useNavigate } from 'react-router';
import {
  ArrowLeft,
  MapPin,
  Calendar,
  Navigation,
  Bus,
  StickyNote,
  Camera,
  Wallet,
  ChevronDown,
  ChevronUp,
  Edit2,
  Check,
  X,
  Plus,
  Trash2,
} from 'lucide-react';
import { mockTrips } from '../data/trips';

export function TripDetailsPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState<
    'itinerary' | 'route' | 'transport' | 'budget'
  >('itinerary');
  const [expandedDay, setExpandedDay] = useState<number | null>(1);

  // Notes CRUD
  const [isAddingNote, setIsAddingNote] = useState(false);
  const [newNote, setNewNote] = useState('');
  const [editingNoteIndex, setEditingNoteIndex] = useState<number | null>(null);
  const [editedNote, setEditedNote] = useState('');

  // Photos CRUD
  const [isAddingPhoto, setIsAddingPhoto] = useState(false);
  const [newPhotoUrl, setNewPhotoUrl] = useState('');

  const trip = mockTrips.find((t) => t.id === id);

  if (!trip) {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center">
        <p>Trip not found</p>
      </div>
    );
  }

  const budgetProgress = (trip.budget.spent / trip.budget.total) * 100;

  // Notes handlers
  const handleAddNote = () => {
    if (newNote.trim()) {
      console.log('Adding note:', newNote);
      setNewNote('');
      setIsAddingNote(false);
    }
  };

  const handleEditNote = (index: number) => {
    if (editedNote.trim()) {
      console.log('Editing note at index:', index, editedNote);
      setEditingNoteIndex(null);
      setEditedNote('');
    }
  };

  const handleDeleteNote = (index: number) => {
    console.log('Deleting note at index:', index);
  };

  // Photos handlers
  const handleAddPhoto = () => {
    if (newPhotoUrl.trim()) {
      console.log('Adding photo:', newPhotoUrl);
      setNewPhotoUrl('');
      setIsAddingPhoto(false);
    }
  };

  const handleDeletePhoto = (index: number) => {
    console.log('Deleting photo at index:', index);
  };

  return (
    <div className="min-h-screen bg-background pb-20">
      <div className="relative h-56">
        <img src={trip.image} alt={trip.name} className="w-full h-full object-cover" />
        <button
          onClick={() => navigate('/trips')}
          className="absolute top-6 left-4 p-2 bg-white/95 backdrop-blur-sm rounded-full shadow-lg"
        >
          <ArrowLeft className="w-6 h-6" />
        </button>
      </div>

      <div className="p-6">
        <h2 className="mb-2">{trip.name}</h2>
        <div className="flex items-center gap-2 text-muted-foreground mb-4">
          <MapPin className="w-4 h-4" />
          <span className="text-sm">{trip.destination}</span>
        </div>
        <div className="flex items-center gap-2 text-muted-foreground mb-6">
          <Calendar className="w-4 h-4" />
          <span className="text-sm">
            {new Date(trip.startDate).toLocaleDateString()} -{' '}
            {new Date(trip.endDate).toLocaleDateString()}
          </span>
        </div>

        <div className="bg-card rounded-2xl p-5 shadow-sm mb-6">
          <h4 className="mb-2">Trip Summary</h4>
          <p className="text-muted-foreground text-sm">{trip.summary}</p>
        </div>

        <div className="bg-card rounded-2xl p-5 shadow-sm mb-6">
          <div className="flex justify-between items-center mb-4">
            <h4 className="flex items-center gap-2">
              <StickyNote className="w-5 h-5 text-primary" />
              Travel Notes
            </h4>
            <button
              onClick={() => setIsAddingNote(true)}
              className="p-2 bg-primary/10 text-primary rounded-lg hover:bg-primary/20 transition-colors"
            >
              <Plus className="w-4 h-4" />
            </button>
          </div>

          {isAddingNote && (
            <div className="mb-4 p-3 bg-accent/30 rounded-xl">
              <textarea
                value={newNote}
                onChange={(e) => setNewNote(e.target.value)}
                placeholder="Enter your travel note..."
                rows={2}
                className="w-full px-3 py-2 bg-input-background rounded-lg focus:outline-none focus:ring-2 focus:ring-primary resize-none mb-2"
              />
              <div className="flex gap-2 justify-end">
                <button
                  onClick={() => {
                    setIsAddingNote(false);
                    setNewNote('');
                  }}
                  className="px-3 py-1 bg-muted text-muted-foreground rounded-lg hover:bg-accent transition-colors text-sm"
                >
                  Cancel
                </button>
                <button
                  onClick={handleAddNote}
                  className="px-3 py-1 bg-primary text-primary-foreground rounded-lg hover:shadow-lg transition-all text-sm"
                >
                  Add Note
                </button>
              </div>
            </div>
          )}

          <ul className="space-y-2">
            {trip.notes.map((note, idx) => (
              <li key={idx}>
                {editingNoteIndex === idx ? (
                  <div className="p-3 bg-accent/30 rounded-xl">
                    <textarea
                      value={editedNote}
                      onChange={(e) => setEditedNote(e.target.value)}
                      rows={2}
                      className="w-full px-3 py-2 bg-input-background rounded-lg focus:outline-none focus:ring-2 focus:ring-primary resize-none mb-2"
                    />
                    <div className="flex gap-2 justify-end">
                      <button
                        onClick={() => {
                          setEditingNoteIndex(null);
                          setEditedNote('');
                        }}
                        className="p-1 bg-muted text-muted-foreground rounded-lg hover:bg-accent transition-colors"
                      >
                        <X className="w-4 h-4" />
                      </button>
                      <button
                        onClick={() => handleEditNote(idx)}
                        className="p-1 bg-primary/10 text-primary rounded-lg hover:bg-primary/20 transition-colors"
                      >
                        <Check className="w-4 h-4" />
                      </button>
                    </div>
                  </div>
                ) : (
                  <div className="flex gap-3 p-3 bg-accent/30 rounded-xl group hover:bg-accent/50 transition-colors">
                    <span className="text-primary">•</span>
                    <span className="text-sm flex-1">{note}</span>
                    <div className="flex gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                      <button
                        onClick={() => {
                          setEditingNoteIndex(idx);
                          setEditedNote(note);
                        }}
                        className="p-1 bg-primary/10 text-primary rounded-lg hover:bg-primary/20 transition-colors"
                      >
                        <Edit2 className="w-4 h-4" />
                      </button>
                      <button
                        onClick={() => handleDeleteNote(idx)}
                        className="p-1 bg-destructive/10 text-destructive rounded-lg hover:bg-destructive/20 transition-colors"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>
                  </div>
                )}
              </li>
            ))}
          </ul>

          {trip.notes.length === 0 && !isAddingNote && (
            <div className="text-center py-8">
              <StickyNote className="w-12 h-12 mx-auto mb-3 text-muted-foreground" />
              <p className="text-muted-foreground text-sm">No travel notes yet</p>
            </div>
          )}
        </div>

        <div className="bg-card rounded-2xl p-5 shadow-sm mb-6">
          <div className="flex justify-between items-center mb-4">
            <h4 className="flex items-center gap-2">
              <Camera className="w-5 h-5 text-primary" />
              Photo Memories
            </h4>
            <button
              onClick={() => setIsAddingPhoto(true)}
              className="p-2 bg-primary/10 text-primary rounded-lg hover:bg-primary/20 transition-colors"
            >
              <Plus className="w-4 h-4" />
            </button>
          </div>

          {isAddingPhoto && (
            <div className="mb-4 p-3 bg-accent/30 rounded-xl">
              <input
                type="text"
                value={newPhotoUrl}
                onChange={(e) => setNewPhotoUrl(e.target.value)}
                placeholder="Enter photo URL (e.g., https://images.unsplash.com/...)"
                className="w-full px-3 py-2 bg-input-background rounded-lg focus:outline-none focus:ring-2 focus:ring-primary mb-2"
              />
              <div className="flex gap-2 justify-end">
                <button
                  onClick={() => {
                    setIsAddingPhoto(false);
                    setNewPhotoUrl('');
                  }}
                  className="px-3 py-1 bg-muted text-muted-foreground rounded-lg hover:bg-accent transition-colors text-sm"
                >
                  Cancel
                </button>
                <button
                  onClick={handleAddPhoto}
                  className="px-3 py-1 bg-primary text-primary-foreground rounded-lg hover:shadow-lg transition-all text-sm"
                >
                  Add Photo
                </button>
              </div>
            </div>
          )}

          {trip.photos.length === 0 && !isAddingPhoto ? (
            <div className="text-center py-8">
              <Camera className="w-12 h-12 mx-auto mb-3 text-muted-foreground" />
              <p className="text-muted-foreground text-sm">
                No photos yet. Capture your memories!
              </p>
            </div>
          ) : (
            <div className="grid grid-cols-2 gap-3">
              {trip.photos.map((photo, idx) => (
                <div key={idx} className="aspect-square bg-muted rounded-xl overflow-hidden relative group">
                  <img src={photo} alt={`Memory ${idx + 1}`} className="w-full h-full object-cover" />
                  <button
                    onClick={() => handleDeletePhoto(idx)}
                    className="absolute top-2 right-2 p-2 bg-destructive/90 text-destructive-foreground rounded-lg opacity-0 group-hover:opacity-100 transition-opacity hover:bg-destructive"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              ))}
            </div>
          )}
        </div>

        <div className="flex gap-2 overflow-x-auto pb-2 mb-6 scrollbar-hide">
          <button
            onClick={() => setActiveTab('itinerary')}
            className={`px-4 py-2 rounded-xl whitespace-nowrap transition-colors ${
              activeTab === 'itinerary'
                ? 'bg-primary text-primary-foreground'
                : 'bg-card text-muted-foreground'
            }`}
          >
            Itinerary
          </button>
          <button
            onClick={() => setActiveTab('route')}
            className={`px-4 py-2 rounded-xl whitespace-nowrap transition-colors ${
              activeTab === 'route'
                ? 'bg-primary text-primary-foreground'
                : 'bg-card text-muted-foreground'
            }`}
          >
            Route
          </button>
          <button
            onClick={() => setActiveTab('transport')}
            className={`px-4 py-2 rounded-xl whitespace-nowrap transition-colors ${
              activeTab === 'transport'
                ? 'bg-primary text-primary-foreground'
                : 'bg-card text-muted-foreground'
            }`}
          >
            Transport
          </button>
          <button
            onClick={() => setActiveTab('budget')}
            className={`px-4 py-2 rounded-xl whitespace-nowrap transition-colors ${
              activeTab === 'budget'
                ? 'bg-primary text-primary-foreground'
                : 'bg-card text-muted-foreground'
            }`}
          >
            Budget
          </button>
        </div>

        {activeTab === 'itinerary' && (
          <div className="space-y-4">
            {trip.itinerary.map((day) => (
              <div key={day.day} className="bg-card rounded-2xl shadow-sm overflow-hidden">
                <button
                  onClick={() => setExpandedDay(expandedDay === day.day ? null : day.day)}
                  className="w-full p-5 flex justify-between items-center hover:bg-accent/50 transition-colors"
                >
                  <div className="text-left">
                    <h4>Day {day.day}</h4>
                    <p className="text-sm text-muted-foreground">{day.title}</p>
                  </div>
                  {expandedDay === day.day ? (
                    <ChevronUp className="w-5 h-5 text-muted-foreground" />
                  ) : (
                    <ChevronDown className="w-5 h-5 text-muted-foreground" />
                  )}
                </button>

                {expandedDay === day.day && (
                  <div className="px-5 pb-5 space-y-4">
                    {day.activities.map((activity, idx) => (
                      <div key={idx} className="flex gap-3">
                        <div className="text-sm text-primary whitespace-nowrap pt-1">
                          {activity.time}
                        </div>
                        <div className="flex-1">
                          <p className="text-sm mb-1">{activity.activity}</p>
                          <div className="flex items-center gap-1 text-muted-foreground">
                            <MapPin className="w-3 h-3" />
                            <span className="text-xs">{activity.location}</span>
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            ))}
          </div>
        )}

        {activeTab === 'route' && (
          <div className="bg-card rounded-2xl p-5 shadow-sm">
            <h4 className="mb-4 flex items-center gap-2">
              <Navigation className="w-5 h-5 text-primary" />
              Route Optimization
            </h4>
            <div className="aspect-video bg-muted rounded-xl flex items-center justify-center mb-4">
              <div className="text-center">
                <MapPin className="w-12 h-12 mx-auto mb-2 text-muted-foreground" />
                <p className="text-muted-foreground text-sm">Interactive Map of Davao Region</p>
                <p className="text-xs text-muted-foreground mt-1">
                  Optimized route for all destinations
                </p>
              </div>
            </div>
            <div className="space-y-2">
              <div className="flex justify-between text-sm">
                <span className="text-muted-foreground">Total Distance</span>
                <span>~45 km</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-muted-foreground">Estimated Travel Time</span>
                <span>2.5 hours</span>
              </div>
            </div>
          </div>
        )}

        {activeTab === 'transport' && (
          <div className="space-y-3">
            <h4 className="mb-4 flex items-center gap-2">
              <Bus className="w-5 h-5 text-primary" />
              Transport Options
            </h4>
            {trip.transport.map((item, idx) => (
              <div key={idx} className="bg-card rounded-2xl p-5 shadow-sm">
                <div className="flex items-center gap-3 mb-3">
                  <div className="w-10 h-10 bg-primary/10 rounded-full flex items-center justify-center">
                    <Bus className="w-5 h-5 text-primary" />
                  </div>
                  <div className="flex-1">
                    <h4 className="text-sm">{item.mode}</h4>
                    <p className="text-xs text-muted-foreground">
                      {item.from} → {item.to}
                    </p>
                  </div>
                </div>
                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <p className="text-xs text-muted-foreground">Fare</p>
                    <p className="text-sm">{item.fare}</p>
                  </div>
                  <div>
                    <p className="text-xs text-muted-foreground">Duration</p>
                    <p className="text-sm">{item.duration}</p>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}

        {activeTab === 'budget' && (
          <div className="space-y-4">
            <div className="bg-card rounded-2xl p-5 shadow-sm">
              <h4 className="mb-4 flex items-center gap-2">
                <Wallet className="w-5 h-5 text-primary" />
                Personal Budget
              </h4>
              <div className="space-y-4">
                <div>
                  <div className="flex justify-between mb-2">
                    <span className="text-sm text-muted-foreground">Total Budget</span>
                    <span>₱{trip.budget.total.toLocaleString()}</span>
                  </div>
                  <div className="flex justify-between mb-2">
                    <span className="text-sm text-muted-foreground">Spent</span>
                    <span className="text-primary">₱{trip.budget.spent.toLocaleString()}</span>
                  </div>
                  <div className="flex justify-between mb-3">
                    <span className="text-sm text-muted-foreground">Remaining</span>
                    <span>₱{(trip.budget.total - trip.budget.spent).toLocaleString()}</span>
                  </div>
                  <div className="w-full bg-muted rounded-full h-3">
                    <div
                      className="bg-primary rounded-full h-3 transition-all"
                      style={{ width: `${budgetProgress}%` }}
                    />
                  </div>
                  <p className="text-xs text-muted-foreground mt-2 text-center">
                    {budgetProgress.toFixed(0)}% of budget used
                  </p>
                </div>

                <div>
                  <h4 className="mb-3">Expense Breakdown</h4>
                  <div className="space-y-3">
                    {trip.budget.categories.map((category, idx) => (
                      <div key={idx}>
                        <div className="flex justify-between mb-2">
                          <span className="text-sm">{category.name}</span>
                          <span className="text-sm">₱{category.amount.toLocaleString()}</span>
                        </div>
                        <div className="w-full bg-muted rounded-full h-2">
                          <div
                            className="rounded-full h-2 transition-all"
                            style={{
                              width: `${(category.amount / trip.budget.total) * 100}%`,
                              backgroundColor: category.color,
                            }}
                          />
                        </div>
                      </div>
                    ))}
                  </div>
                </div>

                <div className="bg-muted/30 rounded-xl p-4">
                  <p className="text-sm text-muted-foreground">Daily Spending Limit</p>
                  <p className="text-xl">₱{trip.budget.daily.toLocaleString()}</p>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>

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
