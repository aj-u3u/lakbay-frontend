import { useParams, useNavigate } from 'react-router';
import { ArrowLeft, Star, MapPin, DollarSign, Info } from 'lucide-react';
import { destinations } from '../data/destinations';
import { useState } from 'react';

export function DestinationDetailsPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [showTravelTypeModal, setShowTravelTypeModal] = useState(false);

  const destination = destinations.find((d) => d.id === id);

  if (!destination) {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center">
        <p>Destination not found</p>
      </div>
    );
  }

  const handleGeneratePlan = () => {
    setShowTravelTypeModal(true);
  };

  const handleTravelTypeSelect = (isSolo: boolean) => {
    navigate('/ai-planner', {
      state: {
        destination: destination,
        isSolo: isSolo,
      },
    });
  };

  return (
    <div className="min-h-screen bg-background pb-20">
      <div className="relative h-64">
        <img
          src={destination.image}
          alt={destination.name}
          className="w-full h-full object-cover"
        />
        <button
          onClick={() => navigate('/home')}
          className="absolute top-6 left-4 p-2 bg-white/95 backdrop-blur-sm rounded-full shadow-lg hover:shadow-xl transition-all"
        >
          <ArrowLeft className="w-6 h-6" />
        </button>
        <div className="absolute top-6 right-4 bg-white/95 backdrop-blur-sm px-4 py-2 rounded-full flex items-center gap-2 shadow-lg">
          <Star className="w-5 h-5 text-yellow-500 fill-yellow-500" />
          <span>{destination.rating}</span>
        </div>
      </div>

      <div className="p-6">
        <h2 className="mb-2">{destination.name}</h2>
        <div className="flex items-center gap-2 text-muted-foreground mb-6">
          <MapPin className="w-5 h-5" />
          <span>{destination.location}</span>
        </div>

        <div className="space-y-6">
          <section className="bg-card rounded-2xl p-5 shadow-sm">
            <h3 className="mb-3 flex items-center gap-2">
              <Info className="w-5 h-5 text-primary" />
              About
            </h3>
            <p className="text-muted-foreground">{destination.description}</p>
          </section>

          <section className="bg-card rounded-2xl p-5 shadow-sm">
            <h3 className="mb-3 flex items-center gap-2">
              <DollarSign className="w-5 h-5 text-primary" />
              Entrance Fee
            </h3>
            <p className="text-muted-foreground">{destination.entranceFee}</p>
          </section>

          <section className="bg-card rounded-2xl p-5 shadow-sm">
            <h3 className="mb-3">Activities</h3>
            <div className="flex flex-wrap gap-2">
              {destination.activities.map((activity, idx) => (
                <span
                  key={idx}
                  className="px-4 py-2 bg-primary/10 text-primary rounded-xl"
                >
                  {activity}
                </span>
              ))}
            </div>
          </section>

          <section className="bg-card rounded-2xl p-5 shadow-sm">
            <h3 className="mb-3">Meal Inclusions</h3>
            <p className="text-muted-foreground">{destination.mealInclusions}</p>
          </section>

          <section className="bg-card rounded-2xl p-5 shadow-sm">
            <h3 className="mb-3">Travel Notes</h3>
            <p className="text-muted-foreground">{destination.travelNotes}</p>
          </section>

          <section className="bg-card rounded-2xl p-5 shadow-sm">
            <h3 className="mb-3">Location Map</h3>
            <div className="aspect-video bg-muted rounded-xl flex items-center justify-center">
              <div className="text-center">
                <MapPin className="w-12 h-12 mx-auto mb-2 text-muted-foreground" />
                <p className="text-muted-foreground text-sm">
                  {destination.coordinates.lat.toFixed(4)}, {destination.coordinates.lng.toFixed(4)}
                </p>
              </div>
            </div>
          </section>
        </div>

        <button
          onClick={handleGeneratePlan}
          className="w-full bg-primary text-primary-foreground py-4 rounded-2xl mt-6 shadow-lg hover:shadow-xl transition-all active:scale-[0.98]"
        >
          Generate This Plan
        </button>
      </div>

      {showTravelTypeModal && (
        <div
          className="fixed inset-0 bg-black/50 z-50 flex items-end sm:items-center justify-center p-0 sm:p-4"
          onClick={() => setShowTravelTypeModal(false)}
        >
          <div
            className="bg-card w-full max-w-md rounded-t-3xl sm:rounded-3xl p-6"
            onClick={(e) => e.stopPropagation()}
          >
            <h3 className="mb-4">How are you traveling?</h3>
            <p className="text-muted-foreground mb-6">
              This helps us create the perfect itinerary for you
            </p>

            <div className="space-y-3">
              <button
                onClick={() => handleTravelTypeSelect(true)}
                className="w-full p-4 bg-accent hover:bg-primary/10 rounded-2xl transition-colors text-left"
              >
                <h4 className="mb-1">Solo Travel</h4>
                <p className="text-sm text-muted-foreground">
                  Planning a trip by yourself
                </p>
              </button>

              <button
                onClick={() => handleTravelTypeSelect(false)}
                className="w-full p-4 bg-accent hover:bg-primary/10 rounded-2xl transition-colors text-left"
              >
                <h4 className="mb-1">Group Travel</h4>
                <p className="text-sm text-muted-foreground">
                  Traveling with friends or family
                </p>
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
