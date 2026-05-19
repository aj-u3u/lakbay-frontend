import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../shared/models/destination.dart';
import 'models/planner_models.dart';
import 'models/mock_plans.dart';
import 'widgets/itinerary_preview_modal.dart';
import '../../app/api_service.dart';

enum Sender { ai, user }

class ChatMessage {
  final String id;
  final Sender sender;
  final String text;
  final List<String>? options;
  final bool showDetailsButton;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    this.options,
    this.showDetailsButton = false,
  });
}

enum PlannerStep {
  destination,
  budget,
  date,
  duration,
  preferences,
  groupSize,
  generating,
  complete,
  confirmation,
  postCustomization
}

class AIPlannerPage extends ConsumerStatefulWidget {
  final Destination? destination;
  final bool isSolo;

  const AIPlannerPage({super.key, this.destination, required this.isSolo});

  @override
  ConsumerState<AIPlannerPage> createState() => _AIPlannerPageState();
}

class _AIPlannerPageState extends ConsumerState<AIPlannerPage> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  PlannerStep _currentStep = PlannerStep.destination;
  bool _isGenerating = false;

  final Map<String, String> _plannerData = {};
  PlannerItineraryPlan? _selectedPlan;
  List<Map<String, dynamic>> _apiRecommendations = [];
  String _selectedBudgetTier = 'balanced';

  @override
  void initState() {
    super.initState();
    _startConversation();
  }

  void _startConversation() {
    _addMessage("Hi! I'm your AI Travel Assistant 👋 Tell me about your ideal trip.", Sender.ai);

    Timer(const Duration(milliseconds: 500), () {
      if (widget.destination != null) {
        _addMessage(
          "Great choice! ${widget.destination!.name} is beautiful. Let's plan your ${widget.isSolo ? 'solo' : 'group'} trip there. What's your budget for this trip?",
          Sender.ai,
        );
        setState(() => _currentStep = PlannerStep.budget);
      } else {
        _addMessage(
          "Perfect! Let's plan your ${widget.isSolo ? 'solo adventure' : 'group fun'}. Which destination interests you in Davao Region?",
          Sender.ai,
        );
        setState(() => _currentStep = PlannerStep.destination);
      }
    });
  }

  void _addMessage(String text, Sender sender, {List<String>? options, bool showDetailsButton = false}) {
    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().toString(),
        sender: sender,
        text: text,
        options: options,
        showDetailsButton: showDetailsButton,
      ));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  bool _validateInput(String text) {
    switch (_currentStep) {
      case PlannerStep.destination:
        final hasLetters = RegExp(r'[a-zA-Z]').hasMatch(text);
        final containsOnlySpecial = RegExp(r'^[^a-zA-Z0-9]+$').hasMatch(text);
        
        final davaoPattern = RegExp(
          r'\b(eden|samal|apo|eagle|dahican|mati|monfort|bat|malagos|hagimit|davao)\b',
          caseSensitive: false,
        );
        final isValidDavaoPlace = davaoPattern.hasMatch(text);

        if (!hasLetters || text.length < 3 || containsOnlySpecial || !isValidDavaoPlace) {
          _inputController.clear();
          _addMessage(text, Sender.user);
          Timer(const Duration(milliseconds: 500), () {
            _addMessage(
              'I can only plan trips for Davao Region destinations! Please enter a valid Davao place (e.g., "Samal Island", "Eden Nature Park", "Mt. Apo", "Dahican Beach", "Malagos", or "Davao City").',
              Sender.ai,
            );
          });
          return false;
        }
        break;
      case PlannerStep.budget:
        final hasDigits = RegExp(r'\d').hasMatch(text);
        if (!hasDigits) {
          _inputController.clear();
          _addMessage(text, Sender.user);
          Timer(const Duration(milliseconds: 500), () {
            _addMessage(
              'Please enter a valid numeric budget (e.g., 5000 or 5000 PHP).',
              Sender.ai,
            );
          });
          return false;
        }
        
        final digitMatch = RegExp(r'(\d+)').firstMatch(text.replaceAll(',', ''));
        if (digitMatch != null) {
          final double budget = double.parse(digitMatch.group(1)!);
          if (budget < 300) {
            _inputController.clear();
            _addMessage(text, Sender.user);
            Timer(const Duration(milliseconds: 500), () {
              _addMessage(
                'A budget of ₱${budget.toStringAsFixed(0)} is extremely low for a trip. A minimum starting budget of at least ₱500 is recommended to cover basic local travel, food, and entry fees. Please enter a realistic budget.',
                Sender.ai,
              );
            });
            return false;
          }
        }
        break;
      case PlannerStep.date:
        final whenRegex = RegExp(
          r'(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec|tomorrow|today|now|next|week|month|year|day|anytime|flexible|summer|winter|spring|autumn|fall|weekend|monday|tuesday|wednesday|thursday|friday|saturday|sunday|mon|tue|wed|thu|fri|sat|sun|\b\d{4}\b|\b\d{1,2}[-/]\d{1,2})',
          caseSensitive: false,
        );
        if (!whenRegex.hasMatch(text) || text.length < 2) {
          _inputController.clear();
          _addMessage(text, Sender.user);
          Timer(const Duration(milliseconds: 500), () {
            _addMessage(
              'Please enter a valid travel date or timeframe (e.g., "June 15", "next week", "tomorrow", or "flexible").',
              Sender.ai,
            );
          });
          return false;
        }
        break;
      case PlannerStep.duration:
        // 1. Check if user is typing a new higher budget in response to the warning (e.g. they typed "5000 PHP" or "₱3000")
        final numberMatch = RegExp(r'(\d+)').firstMatch(text.replaceAll(',', ''));
        if (numberMatch != null) {
          final val = int.parse(numberMatch.group(1)!);
          final prevBudgetStr = _plannerData['budget'] ?? '0';
          final prevBudgetMatch = RegExp(r'(\d+)').firstMatch(prevBudgetStr.replaceAll(',', ''));
          final prevBudget = prevBudgetMatch != null ? int.parse(prevBudgetMatch.group(1)!) : 0;
          
          if (val > prevBudget && (text.contains('₱') || text.toLowerCase().contains('php') || val >= 1000)) {
            _plannerData['budget'] = text;
            _inputController.clear();
            _addMessage(text, Sender.user);
            Timer(const Duration(milliseconds: 500), () {
              _addMessage(
                'Got it! Budget updated to $text. Now, how many days will you be staying?',
                Sender.ai,
              );
            });
            return false;
          }
        }

        // 2. Validate normal duration digits
        final hasDigits = RegExp(r'\d').hasMatch(text);
        if (!hasDigits) {
          _inputController.clear();
          _addMessage(text, Sender.user);
          Timer(const Duration(milliseconds: 500), () {
            _addMessage(
              'Please enter a valid number of days (e.g., 3 or 3 days).',
              Sender.ai,
            );
          });
          return false;
        }

        // 3. Perform budget vs. duration sanity check
        final daysMatch = RegExp(r'(\d+)').firstMatch(text);
        if (daysMatch != null) {
          final int days = int.parse(daysMatch.group(1)!);
          final String budgetStr = _plannerData['budget'] ?? '0';
          final budgetDigits = RegExp(r'(\d+)').firstMatch(budgetStr.replaceAll(',', ''));
          if (budgetDigits != null) {
            final double budget = double.parse(budgetDigits.group(1)!);
            final String destination = _plannerData['destination'] ?? widget.destination?.name ?? 'Davao';
            
            double minBudgetPerDay = 800.0;
            if (destination.toLowerCase().contains('apo')) {
              minBudgetPerDay = 2500.0;
            } else if (destination.toLowerCase().contains('eden')) {
              minBudgetPerDay = 1500.0;
            } else if (destination.toLowerCase().contains('samal')) {
              minBudgetPerDay = 1200.0;
            }

            final double minRequiredBudget = minBudgetPerDay * days;

            if (budget < minRequiredBudget) {
              _inputController.clear();
              _addMessage(text, Sender.user);
              Timer(const Duration(milliseconds: 500), () {
                _addMessage(
                  'A budget of ₱${budget.toStringAsFixed(0)} is not enough for a $days-day trip to $destination. A realistic minimum is around ₱${minRequiredBudget.toStringAsFixed(0)} (approx. ₱${minBudgetPerDay.toStringAsFixed(0)}/day to cover local entry fees, travel, food, and basic stays).\n\nPlease enter a shorter duration (e.g., "1 day"), or update your budget by typing a higher amount (e.g., "₱5000").',
                  Sender.ai,
                );
              });
              return false;
            }
          }
        }
        break;
      case PlannerStep.groupSize:
        final hasDigits = RegExp(r'\d').hasMatch(text);
        if (!hasDigits) {
          _inputController.clear();
          _addMessage(text, Sender.user);
          Timer(const Duration(milliseconds: 500), () {
            _addMessage(
              'Please enter a valid number of people (e.g., 4 or 4 people).',
              Sender.ai,
            );
          });
          return false;
        }
        break;
      case PlannerStep.preferences:
        final hasLetters = RegExp(r'[a-zA-Z]').hasMatch(text);
        if (!hasLetters || text.length < 3) {
          _inputController.clear();
          _addMessage(text, Sender.user);
          Timer(const Duration(milliseconds: 500), () {
            _addMessage(
              'Please enter your trip preferences or type "none" / "any" if you do not have any specific preferences.',
              Sender.ai,
            );
          });
          return false;
        }
        break;
      default:
        break;
    }
    return true;
  }

  TextInputType _getKeyboardType() {
    switch (_currentStep) {
      case PlannerStep.budget:
      case PlannerStep.duration:
      case PlannerStep.groupSize:
        return TextInputType.number;
      default:
        return TextInputType.text;
    }
  }

  void _handleSend() {
    if (_inputController.text.trim().isEmpty || _isGenerating) return;
    final text = _inputController.text.trim();
    if (!_validateInput(text)) return;
    _inputController.clear();
    _handleNextStep(text);
  }

  void _handleNextStep(String userInput) async {
    _addMessage(userInput, Sender.user);

    await Future.delayed(const Duration(milliseconds: 800));

    switch (_currentStep) {
      case PlannerStep.destination:
        _plannerData['destination'] = userInput;
        _addMessage("Excellent choice! What's your budget for this trip? (e.g., ₱5,000)", Sender.ai);
        setState(() => _currentStep = PlannerStep.budget);
        break;

      case PlannerStep.budget:
        _plannerData['budget'] = userInput;
        _addMessage("When would you like to go? Please provide your travel date. (e.g., June 15, 2026)", Sender.ai);
        setState(() => _currentStep = PlannerStep.date);
        break;

      case PlannerStep.date:
        _plannerData['date'] = userInput;
        _addMessage("How many days will you be staying? (e.g., 3 days)", Sender.ai);
        setState(() => _currentStep = PlannerStep.duration);
        break;

      case PlannerStep.duration:
        _plannerData['duration'] = userInput;
        if (!widget.isSolo) {
          _addMessage("How many people will be in your group? (e.g., 4 people)", Sender.ai);
          setState(() => _currentStep = PlannerStep.groupSize);
        } else {
          _addMessage("Any specific preferences? (e.g., adventure, relaxation, food tours)", Sender.ai);
          setState(() => _currentStep = PlannerStep.preferences);
        }
        break;

      case PlannerStep.groupSize:
        _plannerData['groupSize'] = userInput;
        _addMessage("Any specific preferences for your group? (e.g., adventure, relaxation)", Sender.ai);
        setState(() => _currentStep = PlannerStep.preferences);
        break;

      case PlannerStep.preferences:
        _plannerData['preferences'] = userInput;
        setState(() {
          _currentStep = PlannerStep.generating;
          _isGenerating = true;
        });
        _addMessage(
          "Perfect! I'm calling the AI recommendations API to find the best spots for ${_plannerData['destination'] ?? widget.destination?.name ?? 'Davao'}... ✨",
          Sender.ai,
        );

        try {
          final destination = _plannerData['destination'] ?? widget.destination?.name ?? 'Davao';
          final budget = _plannerData['budget'] ?? '₱5,000';
          final duration = _plannerData['duration'] ?? '3 days';
          final groupSize = _plannerData['groupSize'] ?? (widget.isSolo ? '1' : '4');
          final preferences = _plannerData['preferences'] ?? 'any';

          final apiPrompt = "Plan a $duration trip to $destination for $groupSize people with a budget of $budget. Preferences: $preferences";

          final response = await ref.read(apiServiceProvider).getAIRecommendation(apiPrompt);
          final List<dynamic> results = response['results'] ?? [];
          
          setState(() {
            _apiRecommendations = List<Map<String, dynamic>>.from(results);
          });

          if (_apiRecommendations.isNotEmpty) {
            _addMessage(
              "Perfect! I queried our AI and Neon database and calculated the absolute best travel options for you! 🌟 Select your desired budget range to view the recommended destinations in that tier:",
              Sender.ai,
              options: [
                "Low Budget",
                "Budget",
                "High Budget",
              ],
            );
          } else {
            // Fallback if no matching destinations returned from database
            _addMessage(
              "Fantastic! Based on your parameters and preferences, I have generated three optimized itinerary plans for **$destination** ($duration). Please select the tier you'd like to view:",
              Sender.ai,
              options: [
                "Low Budget",
                "Budget",
                "High Budget",
              ],
            );
          }
        } catch (e) {
          final destination = _plannerData['destination'] ?? widget.destination?.name ?? 'Davao';
          _addMessage(
            "Great! Let's choose the itinerary tier for your trip to $destination:",
            Sender.ai,
            options: [
              "Low Budget",
              "Budget",
              "High Budget",
            ],
          );
        } finally {
          setState(() {
            _currentStep = PlannerStep.complete;
            _isGenerating = false;
          });
        }
        break;
      default:
        break;
    }
  }

  Destination parseDestinationFromJson(Map<String, dynamic> json) {
    return Destination(
      id: json['id']?.toString() ?? 'dynamic_${DateTime.now().millisecondsSinceEpoch}',
      name: json['name'] ?? '',
      district: json['district'] ?? 'Davao Region',
      image: (json['image'] != null && json['image'].toString().isNotEmpty) 
          ? json['image'] 
          : 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800',
      description: json['description'] ?? '',
      category: List<String>.from(json['category'] ?? []),
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      location: (json['location'] != null && json['location'].toString().isNotEmpty) 
          ? json['location'] 
          : (json['district'] ?? 'Davao Region'),
      entranceFee: (json['entranceFee'] != null && json['entranceFee'].toString().isNotEmpty) 
          ? json['entranceFee'] 
          : 'Free Entry',
      overnightFee: json['overnightFee'],
      operatingHours: (json['operatingHours'] != null && json['operatingHours'].toString().isNotEmpty) 
          ? json['operatingHours'] 
          : 'Open 24/7',
      activities: List<String>.from(json['activities'] ?? []),
      activityPrices: (json['activityPrices'] as List?)?.map((ap) => ActivityPrice(
        name: ap['name'] ?? '',
        price: ap['price']?.toString() ?? '',
        isPerPerson: ap['isPerPerson'] ?? true,
      )).toList(),
      accommodations: (json['accommodations'] as List?)?.map((ac) => Accommodation(
        type: ac['type'] ?? '',
        price: ac['price']?.toString() ?? '',
        description: ac['description'] ?? '',
      )).toList(),
      mealInclusions: json['mealInclusions'] ?? 'Meal options available on-site.',
      travelNotes: json['travelNotes'] ?? 'Enjoy your adventure!',
      coordinates: Coordinates(
        lat: (json['lat'] as num?)?.toDouble() ?? 7.0,
        lng: (json['lng'] as num?)?.toDouble() ?? 125.0,
      ),
      bestTimeToVisit: json['bestTimeToVisit'] ?? 'Dry season (November to May)',
      howToGetThere: json['howToGetThere'] ?? 'Local land transportation from Davao City Center.',
      estimatedTravelTime: json['estimatedTravelTime'] ?? '1 to 2 hours from center.',
      whatToBring: List<String>.from(json['whatToBring'] ?? ['Cash', 'Camera', 'Comfortable clothes']),
      mealPlanDetails: json['mealPlanDetails'] ?? 'Try the authentic local dishes nearby.',
      accessibility: AccessibilityInfo(
        isKidFriendly: json['accessibility']?['isKidFriendly'] ?? true,
        isWheelchairAccessible: json['accessibility']?['isWheelchairAccessible'] ?? false,
        isPetFriendly: json['accessibility']?['isPetFriendly'] ?? false,
        isElderlyFriendly: json['accessibility']?['isElderlyFriendly'] ?? true,
      ),
    );
  }

  PlannerItineraryPlan getItineraryPlanFromDestination(
    Destination dest,
    String type,
    bool isGroupTrip,
    String duration,
  ) {
    int numDays = 3;
    final daysMatch = RegExp(r'(\d+)').firstMatch(duration);
    if (daysMatch != null) {
      numDays = int.parse(daysMatch.group(1)!);
    }

    // Calculate realistic base cost based on selected budget type and fees
    double baseCost = 2500.0;
    if (type == 'balanced') baseCost = 6500.0;
    if (type == 'premium') baseCost = 14500.0;

    if (dest.entranceFee.contains('350') || dest.entranceFee.contains('550') || dest.entranceFee.contains('150')) {
      baseCost += 1000.0;
    } else if (dest.entranceFee.contains('2,000') || dest.entranceFee.contains('5,000') || dest.entranceFee.contains('3,500')) {
      baseCost += 4000.0;
    }

    final costDisplay = isGroupTrip ? '₱${baseCost.toStringAsFixed(0)}/person' : '₱${baseCost.toStringAsFixed(0)}';

    final List<String> highlights = [];
    for (var act in dest.activities) {
      highlights.add('Enjoy exciting $act sessions');
    }
    if (highlights.length > 4) {
      highlights.removeRange(4, highlights.length);
    }
    if (highlights.isEmpty) {
      highlights.addAll([
        'Beautiful scenic views',
        'Relaxing atmosphere',
        'Local food trip',
        'Guided adventure activities',
      ]);
    }

    final accommodations = dest.accommodations ?? [];
    String stayCost = '₱1,500';
    if (type == 'budget') {
      stayCost = accommodations.isNotEmpty ? accommodations.first.price : '₱1,500';
    } else if (type == 'premium') {
      stayCost = accommodations.isNotEmpty ? accommodations.last.price : '₱6,500';
    } else {
      int midIdx = accommodations.length ~/ 2;
      stayCost = accommodations.isNotEmpty ? accommodations[midIdx].price : '₱3,000';
    }

    final List<PlannerAccommodationOption> accomOpts = accommodations.map((a) {
      return PlannerAccommodationOption(
        type: a.type,
        price: a.price,
        description: a.description,
      );
    }).toList();

    final activityPrices = dest.activityPrices ?? [];
    final List<PlannerActivityPrice> actPrices = activityPrices.map((ap) {
      return PlannerActivityPrice(
        name: ap.name,
        price: ap.price,
      );
    }).toList();

    final List<PlannerCostItem> costBreakdown = [
      PlannerCostItem(
        category: type == 'budget' ? 'Budget Stay' : (type == 'premium' ? 'Luxury Experience' : 'Comfort Package'),
        amount: stayCost,
        overnightFee: (dest.overnightFee != null && dest.overnightFee!.isNotEmpty) ? dest.overnightFee! : '₱0',
        entranceFee: dest.entranceFee,
        transportationFee: type == 'budget' ? '₱250' : (type == 'premium' ? '₱1,200' : '₱500'),
        foodFee: type == 'budget' ? '₱300' : (type == 'premium' ? '₱1,000' : '₱600'),
        operatingHours: dest.operatingHours,
        accommodations: accomOpts,
        activityPrices: actPrices,
      ),
    ];

    final List<PlannerItineraryDay> itinerary = [];
    final List<String> destActivities = dest.activities;

    for (int d = 1; d <= numDays; d++) {
      String dayTitle = 'Arrival & First Steps';
      final List<PlannerActivity> dayActivities = [];

      if (d == 1) {
        dayTitle = 'Arrival & Initial Experience';
        dayActivities.addAll([
          PlannerActivity(
            time: '08:30 AM',
            activity: 'Depart from Davao City Proper',
            location: 'Davao City',
          ),
          PlannerActivity(
            time: '10:00 AM',
            activity: 'Arrive at destination',
            location: dest.name,
          ),
          PlannerActivity(
            time: '11:00 AM',
            activity: 'Check-in and settle down',
            location: dest.name,
          ),
          PlannerActivity(
            time: '02:00 PM',
            activity: destActivities.isNotEmpty ? 'Start ${destActivities[0]}' : 'Sightseeing around the area',
            location: dest.name,
          ),
          PlannerActivity(
            time: '06:00 PM',
            activity: 'Welcome Dinner & Relaxation',
            location: dest.name,
          ),
        ]);
      } else if (d == numDays) {
        dayTitle = 'Last Day & Farewell';
        dayActivities.addAll([
          PlannerActivity(
            time: '08:00 AM',
            activity: 'Healthy Breakfast',
            location: dest.name,
          ),
          PlannerActivity(
            time: '09:30 AM',
            activity: destActivities.length > 2 
                ? 'Try out ${destActivities.last}' 
                : (destActivities.isNotEmpty ? 'Final ${destActivities[0]} session' : 'Morning Nature Walk'),
            location: dest.name,
          ),
          PlannerActivity(
            time: '11:30 AM',
            activity: 'Check-out & pack up bags',
            location: dest.name,
          ),
          PlannerActivity(
            time: '01:00 PM',
            activity: 'Late Lunch & Souvenir shopping',
            location: dest.name,
          ),
          PlannerActivity(
            time: '03:00 PM',
            activity: 'Depart back to Davao City',
            location: 'Davao City',
          ),
        ]);
      } else {
        dayTitle = 'Full Day Immersive Adventure';
        dayActivities.addAll([
          PlannerActivity(
            time: '07:30 AM',
            activity: 'Morning Breakfast & Prep',
            location: dest.name,
          ),
          PlannerActivity(
            time: '09:00 AM',
            activity: destActivities.length > 1 ? 'Enjoy ${destActivities[1]}' : 'Scenic Trekking & Exploration',
            location: dest.name,
          ),
          PlannerActivity(
            time: '12:00 PM',
            activity: 'Lunch and Rest',
            location: dest.name,
          ),
          PlannerActivity(
            time: '02:30 PM',
            activity: destActivities.length > 2 ? 'Do ${destActivities[2]}' : 'Afternoon relaxation and photo taking',
            location: dest.name,
          ),
          PlannerActivity(
            time: '06:30 PM',
            activity: 'Sunset Bonfire / Dinner Gathering',
            location: dest.name,
          ),
        ]);
      }

      itinerary.add(
        PlannerItineraryDay(
          day: d,
          title: dayTitle,
          activities: dayActivities,
        ),
      );
    }

    return PlannerItineraryPlan(
      title: '${type[0].toUpperCase()}${type.substring(1)} Experience - ${dest.name}',
      type: type,
      totalCost: costDisplay,
      duration: duration,
      destinationName: dest.name,
      destinationLocation: dest.location,
      destinationDescription: dest.description,
      highlights: highlights,
      costBreakdown: costBreakdown,
      itinerary: itinerary,
    );
  }

  void _handleOptionSelect(String option) {
    // A. First handle the tier selection ("Low Budget", "Budget", "High Budget")
    if (option == "Low Budget" || option == "Budget" || option == "High Budget") {
      setState(() {
        if (option == "Low Budget") {
          _selectedBudgetTier = 'budget';
        } else if (option == "Budget") {
          _selectedBudgetTier = 'balanced';
        } else {
          _selectedBudgetTier = 'premium';
        }
      });

      _addMessage(
        option,
        Sender.user,
      );

      // If we have dynamic recommendations, let's categorize them and show options!
      if (_apiRecommendations.isNotEmpty) {
        // Helper to categorize
        String getDestinationBudgetCategory(Map<String, dynamic> r) {
          final String name = (r['name'] as String? ?? '').toLowerCase();
          
          double entranceVal = 0.0;
          final entranceFeeStr = r['entranceFee']?.toString() ?? '';
          final entranceMatch = RegExp(r'(\d+)').firstMatch(entranceFeeStr.replaceAll(',', ''));
          if (entranceMatch != null) {
            entranceVal = double.tryParse(entranceMatch.group(1)!) ?? 0.0;
          }

          double lodgeVal = 0.0;
          final accommodations = r['accommodations'] as List? ?? [];
          if (accommodations.isNotEmpty) {
            final firstPriceStr = accommodations.first['price']?.toString() ?? '';
            final lodgeMatch = RegExp(r'(\d+)').firstMatch(firstPriceStr.replaceAll(',', ''));
            if (lodgeMatch != null) {
              lodgeVal = double.tryParse(lodgeMatch.group(1)!) ?? 0.0;
            }
          }

          final totalCostEst = entranceVal + lodgeVal;
          
          if (name.contains('pearl farm') || name.contains('apo') || totalCostEst > 6000) {
            return 'High Budget';
          } else if (name.contains('eden') || name.contains('malagos') || totalCostEst > 1200) {
            return 'Budget';
          } else {
            return 'Low Budget';
          }
        }

        // Filter recommendations for this option range
        final matchedPlaces = _apiRecommendations.where((r) => getDestinationBudgetCategory(r) == option).toList();
        
        if (matchedPlaces.isNotEmpty) {
          final List<String> placeNames = matchedPlaces.map((r) => r['name'] as String).toList();
          Timer(const Duration(milliseconds: 600), () {
            _addMessage(
              "Here are the best **$option** options matched from our database for your parameters. Select one to view its comparative custom itinerary:",
              Sender.ai,
              options: placeNames,
            );
          });
          return;
        } else {
          // If no recommendations matched this specific category, fall back to showing all recommended places
          final List<String> allPlaceNames = _apiRecommendations.map((r) => r['name'] as String).toList();
          Timer(const Duration(milliseconds: 600), () {
            _addMessage(
              "We didn't find any specific places in the database matching **$option** range, but here are the top matching destinations. Select one to view its itinerary in the **$option** tier:",
              Sender.ai,
              options: allPlaceNames,
            );
          });
          return;
        }
      } else {
        // Dynamic recommendations empty - fallback to single destination mock tier
        final String destName = _plannerData['destination'] ?? widget.destination?.name ?? 'Davao';
        final String destLocation = widget.destination?.location ?? 'Davao Region';
        final String destDesc = widget.destination?.description ?? 'A personalized AI itinerary for $destName.';
        final String operatingHours = widget.destination?.operatingHours ?? 'Varies by activity';

        final plan = getMockItineraryPlan(
          _selectedBudgetTier,
          !widget.isSolo,
          _plannerData['duration'] ?? '3 days',
          destName,
          destLocation,
          operatingHours,
          destDesc,
        );

        _selectedPlan = plan;
        Timer(const Duration(milliseconds: 400), () {
          context.push('/ai-plan-details', extra: plan);
        });
        return;
      }
    }

    // B. Second, handle when the user clicks a specific place option!
    _addMessage(option, Sender.user);

    if (_apiRecommendations.isNotEmpty) {
      // Find matching recommendation in our list
      Map<String, dynamic>? matchedJson;
      for (var r in _apiRecommendations) {
        if ((r['name'] as String).toLowerCase() == option.toLowerCase()) {
          matchedJson = r;
          break;
        }
      }
      
      // Fallback
      matchedJson ??= _apiRecommendations.first;

      final dest = parseDestinationFromJson(matchedJson);
      final plan = getItineraryPlanFromDestination(
        dest,
        _selectedBudgetTier,
        !widget.isSolo,
        _plannerData['duration'] ?? '3 days',
      );

      _selectedPlan = plan;
      Timer(const Duration(milliseconds: 400), () {
        context.push('/ai-plan-details', extra: plan);
      });
      return;
    }

    // Fallback if no api recommendations exist
    final String destName = _plannerData['destination'] ?? widget.destination?.name ?? 'Davao';
    final String destLocation = widget.destination?.location ?? 'Davao Region';
    final String destDesc = widget.destination?.description ?? 'A personalized AI itinerary for $destName.';
    final String operatingHours = widget.destination?.operatingHours ?? 'Varies by activity';

    final plan = getMockItineraryPlan(
      _selectedBudgetTier,
      !widget.isSolo,
      _plannerData['duration'] ?? '3 days',
      destName,
      destLocation,
      operatingHours,
      destDesc,
    );

    _selectedPlan = plan;
    Timer(const Duration(milliseconds: 400), () {
      context.push('/ai-plan-details', extra: plan);
    });
  }

  void _showItineraryModal(PlannerItineraryPlan plan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ItineraryPreviewModal(
        plan: plan,
        isGroupTrip: !widget.isSolo,
        onSelect: () {
          Navigator.pop(context);
          _handlePlanSelect(plan.title);
        },
      ),
    );
  }

  void _handlePlanSelect(String planTitle) {
    _addMessage(planTitle, Sender.user);
    Timer(const Duration(milliseconds: 800), () {
      _addMessage(
        "Great choice! Would you like to customize this itinerary further, or shall we finalize your trip?",
        Sender.ai,
        options: ["Customize itinerary", "Finalize trip"],
      );
      setState(() => _currentStep = PlannerStep.confirmation);
    });
  }

  void _handleConfirmation(String option) {
    _addMessage(option, Sender.user);
    Timer(const Duration(milliseconds: 800), () {
      if (option == "Customize itinerary" && _selectedPlan != null) {
        context.push('/customize-itinerary', extra: _selectedPlan);
      } else if (option == "View Itinerary" && _selectedPlan != null) {
        context.push('/ai-plan-details', extra: _selectedPlan);
      } else {
        _addMessage("Excellent! Your ${widget.isSolo ? 'trip' : 'group trip'} has been finalized.", Sender.ai);
        Timer(const Duration(seconds: 1), () => context.pop());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;
    final secondaryColor = colorScheme.secondary;
    final accentColor = widget.isSolo ? primaryColor : secondaryColor;
    final onAccentColor = widget.isSolo ? colorScheme.onPrimary : colorScheme.onSecondary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.isSolo 
                ? [primaryColor, primaryColor.withValues(alpha: 0.8)]
                : [secondaryColor, secondaryColor.withValues(alpha: 0.8)],
            ),
          ),
        ),
        title: Row(
          children: [
            Icon(LucideIcons.sparkles, size: 20, color: onAccentColor),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Travel Assistant', style: TextStyle(color: onAccentColor, fontSize: 16)),
                Text(
                  'Planning your perfect ${widget.isSolo ? 'solo' : 'group'} trip',
                  style: TextStyle(color: onAccentColor.withValues(alpha: 0.8), fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: onAccentColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message.sender == Sender.user;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Container(
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isUser ? accentColor : colorScheme.surface,
                          borderRadius: BorderRadius.circular(20).copyWith(
                            bottomRight: isUser ? const Radius.circular(0) : null,
                            bottomLeft: !isUser ? const Radius.circular(0) : null,
                          ),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
                          ],
                        ),
                        child: Text(
                          message.text,
                          style: TextStyle(
                            color: isUser ? onAccentColor : colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (message.options != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: message.options!.map((opt) => InkWell(
                              onTap: () {
                                if (_currentStep == PlannerStep.complete) {
                                  _handleOptionSelect(opt);
                                } else if (_currentStep == PlannerStep.confirmation) {
                                  _handleConfirmation(opt);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: accentColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  opt,
                                  style: TextStyle(color: accentColor, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                              ),
                            )).toList(),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(top: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    onSubmitted: (_) => _handleSend(),
                    style: TextStyle(color: colorScheme.onSurface),
                    keyboardType: _getKeyboardType(),
                    enabled: !_isGenerating && 
                             _currentStep != PlannerStep.complete && 
                             _currentStep != PlannerStep.confirmation,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: colorScheme.onSurface.withValues(alpha: 0.05),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: _handleSend,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(LucideIcons.send, color: onAccentColor, size: 24),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
