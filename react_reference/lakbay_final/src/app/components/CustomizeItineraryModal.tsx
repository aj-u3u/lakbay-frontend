import { useState } from 'react';
import { X, Plus, Trash2, Edit2, Check, ChevronLeft } from 'lucide-react';

interface Activity {
  time: string;
  activity: string;
  location: string;
}

interface ItineraryDay {
  day: number;
  title: string;
  activities: Activity[];
}

interface CostItem {
  category: string;
  amount: string;
}

interface ItineraryPlan {
  title: string;
  type: 'budget' | 'balanced' | 'premium';
  totalCost: string;
  duration: string;
  itinerary: ItineraryDay[];
  costBreakdown: CostItem[];
}

interface CustomizeItineraryModalProps {
  plan: ItineraryPlan;
  onClose: () => void;
  onSave: (customizedPlan: ItineraryPlan, personalNotes: string) => void;
  isGroupTrip?: boolean;
}

export function CustomizeItineraryModal({ plan, onClose, onSave, isGroupTrip = false }: CustomizeItineraryModalProps) {
  const [itinerary, setItinerary] = useState<ItineraryDay[]>(plan.itinerary);
  const [costBreakdown, setCostBreakdown] = useState<CostItem[]>(plan.costBreakdown);
  const [editingDay, setEditingDay] = useState<number | null>(null);
  const [editingActivity, setEditingActivity] = useState<{ dayIndex: number; activityIndex: number } | null>(null);
  const [editingCost, setEditingCost] = useState<number | null>(null);
  const [personalNotes, setPersonalNotes] = useState('');

  const handleAddActivity = (dayIndex: number) => {
    const newActivity: Activity = {
      time: '12:00 PM',
      activity: 'New activity',
      location: 'Location',
    };

    const updatedItinerary = [...itinerary];
    updatedItinerary[dayIndex].activities.push(newActivity);
    setItinerary(updatedItinerary);
  };

  const handleRemoveActivity = (dayIndex: number, activityIndex: number) => {
    const updatedItinerary = [...itinerary];
    updatedItinerary[dayIndex].activities.splice(activityIndex, 1);
    setItinerary(updatedItinerary);
  };

  const handleUpdateActivity = (dayIndex: number, activityIndex: number, field: keyof Activity, value: string) => {
    const updatedItinerary = [...itinerary];
    updatedItinerary[dayIndex].activities[activityIndex][field] = value;
    setItinerary(updatedItinerary);
  };

  const handleUpdateDayTitle = (dayIndex: number, title: string) => {
    const updatedItinerary = [...itinerary];
    updatedItinerary[dayIndex].title = title;
    setItinerary(updatedItinerary);
  };

  const handleUpdateCost = (index: number, field: 'category' | 'amount', value: string) => {
    const updatedCosts = [...costBreakdown];
    updatedCosts[index][field] = value;
    setCostBreakdown(updatedCosts);
  };

  const handleSave = () => {
    const customizedPlan: ItineraryPlan = {
      ...plan,
      itinerary,
      costBreakdown,
    };
    onSave(customizedPlan, personalNotes);
  };

  return (
    <div className="fixed inset-0 z-50 bg-black/50 animate-fadeIn">
      <div className="h-full w-full bg-background animate-slideInRight overflow-hidden flex flex-col">
        {/* Header */}
        <div className={`${isGroupTrip ? 'bg-secondary' : 'bg-primary'} text-white p-6 flex items-center gap-4 shadow-lg flex-shrink-0`}>
          <button
            onClick={onClose}
            className="p-2 hover:bg-white/20 rounded-full transition-colors"
          >
            <ChevronLeft className="w-6 h-6" />
          </button>
          <div className="flex-1">
            <h2 className="text-white">Customize Your Trip</h2>
            <p className="text-white/80 text-sm">{plan.title}</p>
          </div>
        </div>

        {/* Content */}
        <div className="flex-1 overflow-y-auto p-6 space-y-6 scrollbar-hide">
          {/* Budget Summary */}
          <div className="bg-card rounded-2xl p-5 shadow-sm border border-border">
            <h3 className="mb-4">Budget Breakdown</h3>
            <div className="space-y-3">
              {costBreakdown.map((item, idx) => (
                <div key={idx} className="flex items-center gap-3">
                  {editingCost === idx ? (
                    <>
                      <input
                        type="text"
                        value={item.category}
                        onChange={(e) => handleUpdateCost(idx, 'category', e.target.value)}
                        className="flex-1 px-3 py-2 bg-input-background rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary"
                      />
                      <input
                        type="text"
                        value={item.amount}
                        onChange={(e) => handleUpdateCost(idx, 'amount', e.target.value)}
                        className="w-24 px-3 py-2 bg-input-background rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary"
                      />
                      <button
                        onClick={() => setEditingCost(null)}
                        className="p-2 bg-primary text-primary-foreground rounded-lg"
                      >
                        <Check className="w-4 h-4" />
                      </button>
                    </>
                  ) : (
                    <>
                      <span className="flex-1 text-sm text-muted-foreground">{item.category}</span>
                      <span className="text-sm font-medium">{item.amount}</span>
                      <button
                        onClick={() => setEditingCost(idx)}
                        className="p-2 hover:bg-accent rounded-lg transition-colors"
                      >
                        <Edit2 className="w-4 h-4" />
                      </button>
                    </>
                  )}
                </div>
              ))}
              <div className="pt-3 border-t border-border flex justify-between items-center">
                <span className="font-medium">Total</span>
                <span className={`font-medium ${isGroupTrip ? 'text-secondary' : 'text-primary'}`}>
                  {plan.totalCost}
                </span>
              </div>
            </div>
          </div>

          {/* Itinerary */}
          <div className="space-y-4">
            <h3>Day-by-Day Itinerary</h3>

            {itinerary.map((day, dayIndex) => (
              <div key={day.day} className="bg-card rounded-2xl p-5 shadow-sm border border-border">
                {/* Day Header */}
                <div className="mb-4">
                  <span className={`text-xs ${isGroupTrip ? 'text-secondary' : 'text-primary'} font-semibold`}>
                    DAY {day.day}
                  </span>
                  {editingDay === dayIndex ? (
                    <div className="flex items-center gap-2 mt-1">
                      <input
                        type="text"
                        value={day.title}
                        onChange={(e) => handleUpdateDayTitle(dayIndex, e.target.value)}
                        className="flex-1 px-3 py-2 bg-input-background rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary"
                      />
                      <button
                        onClick={() => setEditingDay(null)}
                        className="p-2 bg-primary text-primary-foreground rounded-lg"
                      >
                        <Check className="w-4 h-4" />
                      </button>
                    </div>
                  ) : (
                    <div className="flex items-center gap-2 mt-1">
                      <h4 className="text-sm flex-1">{day.title}</h4>
                      <button
                        onClick={() => setEditingDay(dayIndex)}
                        className="p-2 hover:bg-accent rounded-lg transition-colors"
                      >
                        <Edit2 className="w-4 h-4" />
                      </button>
                    </div>
                  )}
                </div>

                {/* Activities */}
                <div className="space-y-3">
                  {day.activities.map((activity, activityIndex) => (
                    <div key={activityIndex} className="border-l-2 border-border pl-4 relative">
                      <div className={`absolute -left-[9px] top-2 w-4 h-4 rounded-full ${isGroupTrip ? 'bg-secondary' : 'bg-primary'}`}></div>

                      {editingActivity?.dayIndex === dayIndex && editingActivity?.activityIndex === activityIndex ? (
                        <div className="space-y-2">
                          <input
                            type="text"
                            value={activity.time}
                            onChange={(e) => handleUpdateActivity(dayIndex, activityIndex, 'time', e.target.value)}
                            className="w-full px-3 py-2 bg-input-background rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-primary"
                            placeholder="Time"
                          />
                          <input
                            type="text"
                            value={activity.activity}
                            onChange={(e) => handleUpdateActivity(dayIndex, activityIndex, 'activity', e.target.value)}
                            className="w-full px-3 py-2 bg-input-background rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-primary"
                            placeholder="Activity"
                          />
                          <input
                            type="text"
                            value={activity.location}
                            onChange={(e) => handleUpdateActivity(dayIndex, activityIndex, 'location', e.target.value)}
                            className="w-full px-3 py-2 bg-input-background rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-primary"
                            placeholder="Location"
                          />
                          <div className="flex gap-2">
                            <button
                              onClick={() => setEditingActivity(null)}
                              className="flex-1 py-2 bg-primary text-primary-foreground rounded-lg text-sm"
                            >
                              <Check className="w-4 h-4 mx-auto" />
                            </button>
                            <button
                              onClick={() => handleRemoveActivity(dayIndex, activityIndex)}
                              className="px-4 py-2 bg-destructive text-destructive-foreground rounded-lg text-sm"
                            >
                              <Trash2 className="w-4 h-4" />
                            </button>
                          </div>
                        </div>
                      ) : (
                        <div>
                          <div className="flex items-center justify-between mb-1">
                            <span className="text-xs text-muted-foreground">{activity.time}</span>
                            <button
                              onClick={() => setEditingActivity({ dayIndex, activityIndex })}
                              className="p-1 hover:bg-accent rounded transition-colors"
                            >
                              <Edit2 className="w-3 h-3" />
                            </button>
                          </div>
                          <p className="text-sm font-medium mb-1">{activity.activity}</p>
                          <p className="text-xs text-muted-foreground">{activity.location}</p>
                        </div>
                      )}
                    </div>
                  ))}

                  {/* Add Activity Button */}
                  <button
                    onClick={() => handleAddActivity(dayIndex)}
                    className={`w-full py-2 border-2 border-dashed ${isGroupTrip ? 'border-secondary text-secondary' : 'border-primary text-primary'} rounded-lg flex items-center justify-center gap-2 hover:bg-accent transition-colors`}
                  >
                    <Plus className="w-4 h-4" />
                    <span className="text-sm">Add Activity</span>
                  </button>
                </div>
              </div>
            ))}
          </div>

          {/* Personal Notes */}
          <div className="bg-card rounded-2xl p-5 shadow-sm border border-border">
            <h4 className="mb-3">Personal Notes</h4>
            <textarea
              value={personalNotes}
              onChange={(e) => setPersonalNotes(e.target.value)}
              placeholder="Add any special notes, preferences, or reminders for this trip..."
              className="w-full h-24 px-4 py-3 bg-input-background rounded-xl resize-none focus:outline-none focus:ring-2 focus:ring-primary text-sm"
            />
          </div>
        </div>

        {/* Footer */}
        <div className="p-4 border-t border-border bg-card flex-shrink-0">
          <button
            onClick={handleSave}
            className={`w-full py-4 ${isGroupTrip ? 'bg-secondary text-secondary-foreground' : 'bg-primary text-primary-foreground'} rounded-2xl font-medium hover:shadow-lg transition-all active:scale-[0.98]`}
          >
            Save Customizations
          </button>
        </div>
      </div>

      <style>{`
        @keyframes fadeIn {
          from { opacity: 0; }
          to { opacity: 1; }
        }
        @keyframes slideInRight {
          from { transform: translateX(100%); }
          to { transform: translateX(0); }
        }
        .animate-fadeIn {
          animation: fadeIn 0.2s ease-out;
        }
        .animate-slideInRight {
          animation: slideInRight 0.3s ease-out;
        }
      `}</style>
    </div>
  );
}
