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
      case PlannerStep.budget:
        final hasDigits = RegExp(r'\d').hasMatch(text);
        if (!hasDigits) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Please enter a valid numeric budget (e.g., 5000 or 5000 PHP).'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          return false;
        }
        break;
      case PlannerStep.duration:
        final hasDigits = RegExp(r'\d').hasMatch(text);
        if (!hasDigits) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Please enter a valid number of days (e.g., 3 or 3 days).'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          return false;
        }
        break;
      case PlannerStep.groupSize:
        final hasDigits = RegExp(r'\d').hasMatch(text);
        if (!hasDigits) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Please enter a valid number of people (e.g., 4 or 4 people).'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
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
          final budget = _plannerData['budget'] ?? '5000';
          final duration = _plannerData['duration'] ?? '3 days';
          final date = _plannerData['date'] ?? 'anytime';
          final groupSize = widget.isSolo ? '1 pax' : (_plannerData['groupSize'] ?? 'group');
          final preferences = _plannerData['preferences'] ?? 'chill';

          final prompt = "Plan a ${widget.isSolo ? 'solo' : 'group'} trip to $destination for $duration starting on $date with a budget of $budget, group size of $groupSize. Preferences: $preferences.";

          final apiService = ref.read(apiServiceProvider);
          final response = await apiService.getAIRecommendation(prompt);

          final results = response['results'] as List<dynamic>?;

          if (results == null || results.isEmpty) {
            _addMessage(
              "No specific spots found in the database. Here are general options instead:",
              Sender.ai,
              options: [
                "Budget-Friendly Plan - $duration, ₱$budget",
                "Balanced Experience - $duration, ₱$budget",
                "Premium Adventure - $duration, ₱$budget",
              ],
            );
          } else {
            _apiRecommendations = results.map((r) => r as Map<String, dynamic>).toList();

            final List<String> recommendedOptions = [];
            for (var i = 0; i < _apiRecommendations.length; i++) {
              final r = _apiRecommendations[i];
              final name = r['name'] as String;
              final cost = r['cost'] != null ? '₱${r['cost']}' : 'varies';
              recommendedOptions.add("Option ${i + 1}: $name ($cost)");
            }
            // Add custom balanced option as fallback
            recommendedOptions.add("Custom Balanced Experience");

            _addMessage(
              "Based on your preferences, the API recommends these top destinations. Please select one to view the itinerary details:",
              Sender.ai,
              options: recommendedOptions,
            );
          }
        } catch (e) {
          _addMessage(
            "I couldn't reach the API backend (${e.toString().replaceAll('Exception: ', '')}). Here are standard options instead:",
            Sender.ai,
            options: [
              "Budget-Friendly Plan - ${_plannerData['duration']}, ₱${_plannerData['budget']}",
              "Balanced Experience - ${_plannerData['duration']}, ₱${_plannerData['budget']}",
              "Premium Adventure - ${_plannerData['duration']}, ₱${_plannerData['budget']}",
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

  void _handleOptionSelect(String option) {
    Map<String, dynamic>? selectedDest;
    if (option.startsWith("Option ")) {
      final match = RegExp(r'Option (\d+):').firstMatch(option);
      if (match != null) {
        final idx = int.parse(match.group(1)!) - 1;
        if (idx >= 0 && idx < _apiRecommendations.length) {
          selectedDest = _apiRecommendations[idx];
        }
      }
    }

    String type = 'balanced';
    if (option.contains('Budget-Friendly') ||
        (selectedDest != null && selectedDest['vibes'].toString().toLowerCase().contains('budget'))) {
      type = 'budget';
    }
    if (option.contains('Premium') ||
        (selectedDest != null && selectedDest['vibes'].toString().toLowerCase().contains('luxury'))) {
      type = 'premium';
    }

    final String destName = selectedDest != null ? selectedDest['name'] : (_plannerData['destination'] ?? widget.destination?.name ?? 'Davao');
    final String destLocation = selectedDest != null ? 'Davao Region' : (widget.destination?.location ?? 'Davao Region');
    final String destDesc = selectedDest != null ? selectedDest['description'] : (widget.destination?.description ?? 'A wonderful place to visit in Davao Region.');
    final String operatingHours = selectedDest != null ? '08:00 AM - 05:00 PM' : (widget.destination?.operatingHours ?? 'Varies by activity');

    final plan = getMockItineraryPlan(
      type,
      !widget.isSolo,
      _plannerData['duration'] ?? '3 days',
      destName,
      destLocation,
      operatingHours,
      destDesc,
    );

    _selectedPlan = plan;
    context.push('/ai-plan-details', extra: plan);
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
