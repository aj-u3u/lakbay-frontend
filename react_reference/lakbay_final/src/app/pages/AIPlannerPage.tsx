import { useState, useRef, useEffect } from 'react';
import { useLocation, useNavigate } from 'react-router';
import { ArrowLeft, Send, Sparkles, FileText } from 'lucide-react';
import { ItineraryPreviewModal } from '../components/ItineraryPreviewModal';
import { CustomizeItineraryModal } from '../components/CustomizeItineraryModal';
import { TripDetailsPreviewModal } from '../components/TripDetailsPreviewModal';
import type { Destination } from '../data/destinations';

interface Message {
  id: string;
  sender: 'ai' | 'user';
  text: string;
  options?: string[];
  showDetailsButton?: boolean;
}

interface PlannerState {
  destination?: Destination;
  isSolo?: boolean;
  budget?: string;
  date?: string;
  duration?: string;
  preferences?: string;
  groupSize?: string;
  destinationName?: string;
}

type ConversationStep =
  | 'destination'
  | 'budget'
  | 'date'
  | 'duration'
  | 'preferences'
  | 'groupSize'
  | 'generating'
  | 'complete'
  | 'confirmation'
  | 'postCustomization';

export function AIPlannerPage() {
  const location = useLocation();
  const navigate = useNavigate();
  const state = location.state as PlannerState | undefined;

  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState('');
  const [plannerData, setPlannerData] = useState<PlannerState>({
    destination: state?.destination,
    isSolo: state?.isSolo,
  });
  const [currentStep, setCurrentStep] = useState<ConversationStep>('destination');
  const [showItineraryModal, setShowItineraryModal] = useState(false);
  const [showCustomizeModal, setShowCustomizeModal] = useState(false);
  const [showTripDetailsModal, setShowTripDetailsModal] = useState(false);
  const [selectedPlanType, setSelectedPlanType] = useState<'budget' | 'balanced' | 'premium' | null>(null);
  const [customizedPlan, setCustomizedPlan] = useState<any>(null);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  // Determine color scheme based on trip type
  const isGroupTrip = state?.isSolo === false;

  const getItineraryPlan = (type: 'budget' | 'balanced' | 'premium') => {
    const destinationName = state?.destination?.name || plannerData.destinationName || 'your destination';
    const duration = plannerData.duration || '3 days';

    const plans = {
      budget: {
        title: 'Budget-Friendly Plan',
        type: 'budget' as const,
        totalCost: isGroupTrip ? '₱4,500/person' : '₱4,500',
        duration,
        highlights: isGroupTrip ? [
          'Affordable group accommodations (shared rooms)',
          'Local transportation with group discounts',
          'Group meals at local restaurants',
          'Free or low-cost group activities',
          'Perfect for budget-conscious groups',
        ] : [
          'Affordable accommodations with great reviews',
          'Local transportation and tricycle rides',
          'Street food and local restaurant dining',
          'Free or low-cost attractions and beaches',
          'Perfect for backpackers and budget travelers',
        ],
        costBreakdown: [
          { category: 'Accommodation', amount: '₱1,500' },
          { category: 'Food & Dining', amount: '₱1,200' },
          { category: 'Transportation', amount: '₱800' },
          { category: 'Activities', amount: '₱700' },
          { category: 'Miscellaneous', amount: '₱300' },
        ],
        itinerary: [
          {
            day: 1,
            title: 'Arrival & Exploration',
            activities: [
              { time: '09:00 AM', activity: 'Arrive and check-in', location: 'Budget hostel' },
              { time: '11:00 AM', activity: 'Local market tour', location: 'Downtown market' },
              { time: '01:00 PM', activity: 'Lunch at local eatery', location: 'Carenderia' },
              { time: '03:00 PM', activity: 'Beach exploration', location: 'Public beach' },
              { time: '06:00 PM', activity: 'Street food dinner', location: 'Night market' },
            ],
          },
          {
            day: 2,
            title: 'Adventure Day',
            activities: [
              { time: '07:00 AM', activity: 'Breakfast at hostel', location: 'Hostel' },
              { time: '08:00 AM', activity: 'Hiking or nature walk', location: 'Local trail' },
              { time: '12:00 PM', activity: 'Packed lunch picnic', location: 'Scenic viewpoint' },
              { time: '02:00 PM', activity: 'Swimming and relaxation', location: 'Free beach access' },
              { time: '07:00 PM', activity: 'Dinner with locals', location: 'Local restaurant' },
            ],
          },
          {
            day: 3,
            title: 'Departure',
            activities: [
              { time: '08:00 AM', activity: 'Breakfast and check-out', location: 'Hostel' },
              { time: '10:00 AM', activity: 'Last-minute souvenir shopping', location: 'Local shops' },
              { time: '12:00 PM', activity: 'Depart for home', location: 'Bus terminal' },
            ],
          },
        ],
      },
      balanced: {
        title: 'Balanced Experience',
        type: 'balanced' as const,
        totalCost: isGroupTrip ? '₱8,500/person' : '₱8,500',
        duration,
        highlights: isGroupTrip ? [
          'Comfortable group-friendly accommodations',
          'Private group transport for convenience',
          'Group dining at popular restaurants',
          'Mix of group activities and free time',
          'Best value for group experiences',
        ] : [
          'Comfortable mid-range accommodations',
          'Mix of local and tourist transportation',
          'Variety of dining experiences',
          'Popular attractions and hidden gems',
          'Best value for money and experience',
        ],
        costBreakdown: [
          { category: 'Accommodation', amount: '₱3,000' },
          { category: 'Food & Dining', amount: '₱2,500' },
          { category: 'Transportation', amount: '₱1,500' },
          { category: 'Activities', amount: '₱1,200' },
          { category: 'Miscellaneous', amount: '₱300' },
        ],
        itinerary: [
          {
            day: 1,
            title: 'Welcome & Beach Time',
            activities: [
              { time: '09:00 AM', activity: 'Hotel check-in', location: '3-star beachfront hotel' },
              { time: '11:00 AM', activity: 'Welcome lunch', location: 'Hotel restaurant' },
              { time: '01:00 PM', activity: 'Beach activities', location: 'Resort beach' },
              { time: '04:00 PM', activity: 'Sunset viewing', location: 'Beach bar' },
              { time: '07:00 PM', activity: 'Seafood dinner', location: 'Recommended restaurant' },
            ],
          },
          {
            day: 2,
            title: 'Island Adventure',
            activities: [
              { time: '07:00 AM', activity: 'Breakfast buffet', location: 'Hotel' },
              { time: '09:00 AM', activity: 'Island hopping tour', location: 'Multiple islands' },
              { time: '12:00 PM', activity: 'Beach BBQ lunch', location: 'Island' },
              { time: '03:00 PM', activity: 'Snorkeling session', location: 'Coral reef' },
              { time: '06:00 PM', activity: 'Return and dinner', location: 'Local restaurant' },
            ],
          },
          {
            day: 3,
            title: 'Culture & Departure',
            activities: [
              { time: '08:00 AM', activity: 'Breakfast and check-out', location: 'Hotel' },
              { time: '10:00 AM', activity: 'Cultural site visit', location: 'Local attraction' },
              { time: '12:00 PM', activity: 'Farewell lunch', location: 'Popular café' },
              { time: '02:00 PM', activity: 'Depart for home', location: 'Ferry terminal' },
            ],
          },
        ],
      },
      premium: {
        title: 'Premium Adventure',
        type: 'premium' as const,
        totalCost: isGroupTrip ? '₱15,000/person' : '₱15,000',
        duration,
        highlights: isGroupTrip ? [
          'Luxury group suites or villas',
          'Private group transportation and transfers',
          'Exclusive group dining experiences',
          'Premium group activities and private tours',
          'VIP group treatment and concierge service',
        ] : [
          'Luxury resort or boutique hotel stay',
          'Private transportation and transfers',
          'Fine dining and exclusive experiences',
          'Premium activities and guided tours',
          'VIP treatment and personalized service',
        ],
        costBreakdown: [
          { category: 'Accommodation', amount: '₱6,500' },
          { category: 'Food & Dining', amount: '₱3,500' },
          { category: 'Transportation', amount: '₱2,000' },
          { category: 'Activities', amount: '₱2,500' },
          { category: 'Miscellaneous', amount: '₱500' },
        ],
        itinerary: [
          {
            day: 1,
            title: 'Luxury Arrival',
            activities: [
              { time: '09:00 AM', activity: 'Private transfer from port', location: 'VIP lounge' },
              { time: '10:00 AM', activity: 'Resort check-in with welcome drinks', location: '5-star resort' },
              { time: '12:00 PM', activity: 'Gourmet lunch', location: 'Resort fine dining' },
              { time: '02:00 PM', activity: 'Spa and wellness session', location: 'Resort spa' },
              { time: '06:00 PM', activity: 'Sunset cocktails', location: 'Private beach' },
              { time: '07:30 PM', activity: 'Chef\'s special dinner', location: 'Beachfront restaurant' },
            ],
          },
          {
            day: 2,
            title: 'Premium Experience',
            activities: [
              { time: '07:00 AM', activity: 'Breakfast in bed', location: 'Resort room' },
              { time: '09:00 AM', activity: 'Private yacht tour', location: 'Exclusive islands' },
              { time: '12:00 PM', activity: 'Luxury picnic lunch', location: 'Private island' },
              { time: '02:00 PM', activity: 'Scuba diving with instructor', location: 'Premium dive site' },
              { time: '05:00 PM', activity: 'Return and refresh', location: 'Resort' },
              { time: '07:00 PM', activity: 'Fine dining experience', location: 'Signature restaurant' },
            ],
          },
          {
            day: 3,
            title: 'Relaxed Departure',
            activities: [
              { time: '08:00 AM', activity: 'Leisure breakfast', location: 'Resort terrace' },
              { time: '10:00 AM', activity: 'Final spa treatment', location: 'Resort spa' },
              { time: '12:00 PM', activity: 'Farewell lunch', location: 'Resort' },
              { time: '02:00 PM', activity: 'Private transfer to port', location: 'VIP service' },
            ],
          },
        ],
      },
    };

    return plans[type];
  };

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const addMessage = (text: string, sender: 'ai' | 'user', options?: string[], showDetailsButton?: boolean) => {
    setMessages(prev => [...prev, {
      id: Date.now().toString(),
      sender,
      text,
      options,
      showDetailsButton,
    }]);
  };

  useEffect(() => {
    addMessage("Hi! I'm your AI Travel Assistant 👋 Tell me about your ideal trip.", 'ai');

    setTimeout(() => {
      if (state?.destination) {
        addMessage(
          `Great choice! ${state.destination.name} is beautiful. Let's plan your ${
            state.isSolo ? 'solo' : 'group'
          } trip there. What's your budget for this trip?`,
          'ai'
        );
        setCurrentStep('budget');
      } else if (state?.isSolo === true) {
        addMessage("Perfect! Let's plan your solo adventure. Which destination interests you in Davao Region?", 'ai');
        setCurrentStep('destination');
      } else if (state?.isSolo === false) {
        addMessage("Awesome! Group travel is so much fun. Which destination would your group like to visit?", 'ai');
        setCurrentStep('destination');
      }
    }, 500);
  }, []);

  const handleNextStep = (userInput: string) => {
    addMessage(userInput, 'user');

    setTimeout(() => {
      switch (currentStep) {
        case 'destination':
          setPlannerData(prev => ({ ...prev, destinationName: userInput }));
          addMessage("Excellent choice! What's your budget for this trip? (e.g., ₱5,000)", 'ai');
          setCurrentStep('budget');
          break;

        case 'budget':
          setPlannerData(prev => ({ ...prev, budget: userInput }));
          addMessage("When would you like to go? Please provide your travel date. (e.g., June 15, 2026)", 'ai');
          setCurrentStep('date');
          break;

        case 'date':
          setPlannerData(prev => ({ ...prev, date: userInput }));
          addMessage("How many days will you be staying? (e.g., 3 days)", 'ai');
          setCurrentStep('duration');
          break;

        case 'duration':
          setPlannerData(prev => ({ ...prev, duration: userInput }));

          if (state?.isSolo === false) {
            addMessage("How many people will be in your group? (e.g., 4 people)", 'ai');
            setCurrentStep('groupSize');
          } else {
            addMessage("Any specific preferences? (e.g., adventure activities, relaxation, food tours)", 'ai');
            setCurrentStep('preferences');
          }
          break;

        case 'groupSize':
          setPlannerData(prev => ({ ...prev, groupSize: userInput }));
          addMessage("Any specific preferences for your group? (e.g., adventure activities, relaxation, food tours)", 'ai');
          setCurrentStep('preferences');
          break;

        case 'preferences':
          setPlannerData(prev => ({ ...prev, preferences: userInput }));
          setCurrentStep('generating');

          addMessage(
            `Perfect! I'm generating ${state?.isSolo ? '3 solo travel options' : '3 group travel options'} for ${
              state?.destination?.name || plannerData.destinationName
            }. This will take just a moment... ✨`,
            'ai'
          );

          setTimeout(() => {
            const destinationName = state?.destination?.name || plannerData.destinationName || 'your destination';
            addMessage(
              `Here are 3 personalized itinerary options for your trip to ${destinationName}:`,
              'ai',
              [
                `Budget-Friendly Plan - ${plannerData.duration}, ₱${plannerData.budget}`,
                `Balanced Experience - ${plannerData.duration}, ₱${plannerData.budget}`,
                `Premium Adventure - ${plannerData.duration}, ₱${plannerData.budget}`,
              ]
            );
            setCurrentStep('complete');
          }, 2000);
          break;
      }
    }, 600);
  };

  const handleSend = () => {
    if (!input.trim() || currentStep === 'generating' || currentStep === 'complete') return;
    handleNextStep(input);
    setInput('');
  };

  const handleOptionSelect = (option: string, planType: 'budget' | 'balanced' | 'premium') => {
    setSelectedPlanType(planType);
    setShowItineraryModal(true);
  };

  const handlePlanSelect = () => {
    const planName = selectedPlanType === 'budget'
      ? 'Budget-Friendly Plan'
      : selectedPlanType === 'balanced'
      ? 'Balanced Experience'
      : 'Premium Adventure';

    addMessage(planName, 'user');
    setShowItineraryModal(false);

    setTimeout(() => {
      addMessage(
        `Great choice! Would you like to customize this itinerary further, or shall we finalize your trip?`,
        'ai',
        ['Customize itinerary', 'Finalize trip']
      );
      setCurrentStep('confirmation');
    }, 800);
  };

  const handleConfirmationSelect = (option: string) => {
    addMessage(option, 'user');

    setTimeout(() => {
      if (option === 'Customize itinerary') {
        addMessage(
          `Perfect! Let's customize your trip. You can edit activities, adjust timings, and add personal touches.`,
          'ai'
        );

        setTimeout(() => {
          setShowCustomizeModal(true);
        }, 800);
      } else {
        addMessage(
          `Excellent! Your ${state?.isSolo ? 'trip' : 'group trip'} has been finalized. Let's get ready for an amazing adventure!`,
          'ai'
        );

        setTimeout(() => {
          navigate(state?.isSolo ? '/trips' : '/groups');
        }, 1500);
      }
    }, 800);
  };

  const handleCustomizationSave = (customized: any, notes: string) => {
    setShowCustomizeModal(false);
    setCustomizedPlan({ ...customized, personalNotes: notes });

    setTimeout(() => {
      const activityCount = customized.itinerary.reduce((total: number, day: any) => total + day.activities.length, 0);

      addMessage(
        `Perfect! I've saved your customized ${customized.title}. Your trip includes ${customized.itinerary.length} days with ${activityCount} activities and a total budget of ${customized.totalCost}.`,
        'ai',
        undefined,
        true
      );

      setTimeout(() => {
        addMessage(
          "Are you satisfied with your customized itinerary, or would you like to make more changes?",
          'ai',
          ["I'm satisfied, finalize my trip", "Make more changes"]
        );
        setCurrentStep('postCustomization');
      }, 1000);
    }, 500);
  };

  const handlePostCustomizationSelect = (option: string) => {
    addMessage(option, 'user');

    setTimeout(() => {
      if (option === "Make more changes") {
        addMessage(
          `No problem! Let's refine your itinerary further.`,
          'ai'
        );

        setTimeout(() => {
          setShowCustomizeModal(true);
        }, 800);
      } else {
        addMessage(
          `Perfect! Your customized ${state?.isSolo ? 'trip' : 'group trip'} is now finalized. Get ready for an amazing adventure!`,
          'ai'
        );

        setTimeout(() => {
          navigate(state?.isSolo ? '/trips' : '/groups');
        }, 1500);
      }
    }, 800);
  };

  return (
    <div className="h-screen bg-background flex flex-col">
      <div className={`bg-gradient-to-r ${isGroupTrip ? 'from-secondary to-secondary/80' : 'from-primary to-primary/80'} text-white p-6 flex items-center gap-4 shadow-lg flex-shrink-0`}>
        <button
          onClick={() => navigate(-1)}
          className="p-2 hover:bg-white/20 rounded-full transition-colors"
        >
          <ArrowLeft className="w-6 h-6" />
        </button>
        <div className="flex-1">
          <h3 className="flex items-center gap-2">
            <Sparkles className="w-5 h-5" />
            AI Travel Assistant
          </h3>
          <p className="text-white/80 text-sm">Planning your perfect {isGroupTrip ? 'group' : 'solo'} trip</p>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto p-6 space-y-4">
        {messages.map((message) => (
          <div
            key={message.id}
            className={`flex ${message.sender === 'user' ? 'justify-end' : 'justify-start'}`}
          >
            <div
              className={`max-w-[80%] rounded-2xl p-4 ${
                message.sender === 'user'
                  ? isGroupTrip
                    ? 'bg-secondary text-secondary-foreground ml-auto'
                    : 'bg-primary text-primary-foreground ml-auto'
                  : 'bg-card shadow-sm'
              }`}
            >
              <p>{message.text}</p>
              {message.showDetailsButton && (
                <button
                  onClick={() => setShowTripDetailsModal(true)}
                  className={`mt-3 w-full py-3 px-4 ${isGroupTrip ? 'bg-secondary text-secondary-foreground' : 'bg-primary text-primary-foreground'} rounded-xl flex items-center justify-center gap-2 hover:shadow-lg transition-all`}
                >
                  <FileText className="w-4 h-4" />
                  <span className="text-sm font-medium">View Full Trip Details</span>
                </button>
              )}
              {message.options && (
                <div className="mt-4 space-y-2">
                  {message.options.map((option, idx) => {
                    const isItineraryOption = option.includes('Budget-Friendly') || option.includes('Balanced') || option.includes('Premium');
                    const isConfirmationOption = option.includes('Customize') || option.includes('Finalize');
                    const isPostCustomizationOption = option.includes("I'm satisfied") || option.includes("Make more changes");

                    let planType: 'budget' | 'balanced' | 'premium' | undefined;
                    if (option.includes('Budget-Friendly')) planType = 'budget';
                    else if (option.includes('Balanced')) planType = 'balanced';
                    else if (option.includes('Premium')) planType = 'premium';

                    return (
                      <button
                        key={idx}
                        onClick={() => {
                          if (isItineraryOption && planType) {
                            handleOptionSelect(option, planType);
                          } else if (isConfirmationOption) {
                            handleConfirmationSelect(option);
                          } else if (isPostCustomizationOption) {
                            handlePostCustomizationSelect(option);
                          }
                        }}
                        className={`w-full p-3 rounded-xl text-left transition-colors text-sm ${
                          isGroupTrip
                            ? 'bg-secondary/10 hover:bg-secondary/20'
                            : 'bg-primary/10 hover:bg-primary/20'
                        }`}
                      >
                        {option}
                      </button>
                    );
                  })}
                </div>
              )}
            </div>
          </div>
        ))}
        <div ref={messagesEndRef} />
      </div>

      <div className="p-4 border-t border-border bg-card flex-shrink-0">
        <div className="flex gap-2">
          <input
            type="text"
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyPress={(e) => e.key === 'Enter' && handleSend()}
            placeholder="Type your message..."
            disabled={currentStep === 'generating' || currentStep === 'complete' || currentStep === 'confirmation' || currentStep === 'postCustomization'}
            className={`flex-1 px-4 py-3 bg-input-background rounded-2xl focus:outline-none focus:ring-2 ${isGroupTrip ? 'focus:ring-secondary' : 'focus:ring-primary'} disabled:opacity-50`}
          />
          <button
            onClick={handleSend}
            disabled={!input.trim() || currentStep === 'generating' || currentStep === 'complete' || currentStep === 'confirmation' || currentStep === 'postCustomization'}
            className={`p-3 ${isGroupTrip ? 'bg-secondary text-secondary-foreground' : 'bg-primary text-primary-foreground'} rounded-2xl hover:shadow-lg transition-all disabled:opacity-50 disabled:cursor-not-allowed active:scale-[0.95]`}
          >
            <Send className="w-6 h-6" />
          </button>
        </div>
      </div>

      {showItineraryModal && selectedPlanType && (
        <ItineraryPreviewModal
          plan={getItineraryPlan(selectedPlanType)}
          onClose={() => setShowItineraryModal(false)}
          onSelect={handlePlanSelect}
          isGroupTrip={isGroupTrip}
        />
      )}

      {showCustomizeModal && selectedPlanType && (
        <CustomizeItineraryModal
          plan={customizedPlan || getItineraryPlan(selectedPlanType)}
          onClose={() => setShowCustomizeModal(false)}
          onSave={handleCustomizationSave}
          isGroupTrip={isGroupTrip}
        />
      )}

      {showTripDetailsModal && customizedPlan && (
        <TripDetailsPreviewModal
          planTitle={customizedPlan.title}
          totalCost={customizedPlan.totalCost}
          duration={customizedPlan.duration}
          itinerary={customizedPlan.itinerary}
          costBreakdown={customizedPlan.costBreakdown}
          personalNotes={customizedPlan.personalNotes}
          onClose={() => setShowTripDetailsModal(false)}
          isGroupTrip={isGroupTrip}
        />
      )}
    </div>
  );
}
