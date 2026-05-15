import { X, MapPin, Clock, DollarSign, Star } from 'lucide-react';

interface ItineraryDay {
  day: number;
  title: string;
  activities: {
    time: string;
    activity: string;
    location: string;
  }[];
}

interface ItineraryPlan {
  title: string;
  type: 'budget' | 'balanced' | 'premium';
  totalCost: string;
  duration: string;
  highlights: string[];
  costBreakdown: {
    category: string;
    amount: string;
  }[];
  itinerary: ItineraryDay[];
}

interface ItineraryPreviewModalProps {
  plan: ItineraryPlan;
  onClose: () => void;
  onSelect: () => void;
  isGroupTrip?: boolean;
}

export function ItineraryPreviewModal({ plan, onClose, onSelect, isGroupTrip = false }: ItineraryPreviewModalProps) {
  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center bg-black/50 animate-fadeIn">
      <div className="bg-card w-full max-h-[85vh] rounded-t-3xl overflow-hidden shadow-2xl animate-slideUp">
        {/* Header */}
        <div className={`${isGroupTrip ? 'bg-secondary' : 'bg-primary'} text-white p-6 flex items-center justify-between`}>
          <div className="flex-1">
            <h3 className="text-white mb-1">{plan.title}</h3>
            <p className="text-white/80 text-sm">{plan.duration} • {plan.totalCost}</p>
          </div>
          <button
            onClick={onClose}
            className="p-2 hover:bg-white/20 rounded-full transition-colors"
          >
            <X className="w-6 h-6" />
          </button>
        </div>

        {/* Content */}
        <div className="overflow-y-auto max-h-[calc(85vh-180px)] scrollbar-hide">
          {/* Highlights */}
          <div className="p-6 border-b border-border">
            <div className="flex items-center gap-2 mb-3">
              <Star className="w-5 h-5 text-primary" />
              <h4>Highlights</h4>
            </div>
            <ul className="space-y-2">
              {plan.highlights.map((highlight, idx) => (
                <li key={idx} className="flex items-start gap-2 text-sm">
                  <span className="text-primary mt-1">•</span>
                  <span>{highlight}</span>
                </li>
              ))}
            </ul>
          </div>

          {/* Cost Breakdown */}
          <div className="p-6 border-b border-border">
            <div className="flex items-center gap-2 mb-3">
              <DollarSign className="w-5 h-5 text-primary" />
              <h4>Cost Breakdown</h4>
            </div>
            <div className="space-y-2">
              {plan.costBreakdown.map((item, idx) => (
                <div key={idx} className="flex justify-between items-center">
                  <span className="text-sm text-muted-foreground">{item.category}</span>
                  <span className="text-sm font-medium">{item.amount}</span>
                </div>
              ))}
              <div className="pt-2 border-t border-border flex justify-between items-center">
                <span className="font-medium">Total</span>
                <span className="font-medium text-primary">{plan.totalCost}</span>
              </div>
            </div>
          </div>

          {/* Itinerary */}
          <div className="p-6">
            <div className="flex items-center gap-2 mb-4">
              <MapPin className="w-5 h-5 text-primary" />
              <h4>Day-by-Day Itinerary</h4>
            </div>
            <div className="space-y-6">
              {plan.itinerary.map((day) => (
                <div key={day.day}>
                  <div className="mb-3">
                    <span className="text-xs text-primary font-semibold">DAY {day.day}</span>
                    <h4 className="text-sm mt-1">{day.title}</h4>
                  </div>
                  <div className="space-y-3 ml-4 border-l-2 border-border pl-4">
                    {day.activities.map((activity, idx) => (
                      <div key={idx} className="relative">
                        <div className="absolute -left-[21px] top-1 w-3 h-3 rounded-full bg-primary"></div>
                        <div className="flex items-start gap-2 mb-1">
                          <Clock className="w-4 h-4 text-muted-foreground mt-0.5 flex-shrink-0" />
                          <span className="text-xs text-muted-foreground">{activity.time}</span>
                        </div>
                        <p className="text-sm font-medium mb-1">{activity.activity}</p>
                        <p className="text-xs text-muted-foreground">{activity.location}</p>
                      </div>
                    ))}
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="p-4 border-t border-border bg-card">
          <button
            onClick={onSelect}
            className={`w-full py-4 ${isGroupTrip ? 'bg-secondary text-secondary-foreground' : 'bg-primary text-primary-foreground'} rounded-2xl font-medium hover:shadow-lg transition-all active:scale-[0.98]`}
          >
            Select This Plan
          </button>
        </div>
      </div>

      <style>{`
        @keyframes fadeIn {
          from { opacity: 0; }
          to { opacity: 1; }
        }
        @keyframes slideUp {
          from { transform: translateY(100%); }
          to { transform: translateY(0); }
        }
        .animate-fadeIn {
          animation: fadeIn 0.2s ease-out;
        }
        .animate-slideUp {
          animation: slideUp 0.3s ease-out;
        }
      `}</style>
    </div>
  );
}
