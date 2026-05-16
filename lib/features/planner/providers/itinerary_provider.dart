import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/planner_models.dart';

class ItineraryState {
  final PlannerItineraryPlan plan;

  ItineraryState({required this.plan});

  ItineraryState copyWith({PlannerItineraryPlan? plan}) {
    return ItineraryState(plan: plan ?? this.plan);
  }
}

class ItineraryNotifier extends Notifier<PlannerItineraryPlan> {
  final PlannerItineraryPlan initialPlan;

  ItineraryNotifier(this.initialPlan);

  @override
  PlannerItineraryPlan build() {
    return initialPlan;
  }

  void updateDayTitle(int dayIndex, String newTitle) {
    final newItinerary = [...state.itinerary];
    final day = newItinerary[dayIndex];
    newItinerary[dayIndex] = PlannerItineraryDay(
      day: day.day,
      title: newTitle,
      activities: day.activities,
    );
    state = PlannerItineraryPlan(
      title: state.title,
      type: state.type,
      totalCost: state.totalCost,
      duration: state.duration,
      highlights: state.highlights,
      costBreakdown: state.costBreakdown,
      itinerary: newItinerary,
    );
  }

  void updateActivity(int dayIndex, int activityIndex, PlannerActivity newActivity) {
    final newItinerary = [...state.itinerary];
    final day = newItinerary[dayIndex];
    final newActivities = [...day.activities];
    newActivities[activityIndex] = newActivity;
    
    newItinerary[dayIndex] = PlannerItineraryDay(
      day: day.day,
      title: day.title,
      activities: newActivities,
    );
    
    state = PlannerItineraryPlan(
      title: state.title,
      type: state.type,
      totalCost: state.totalCost,
      duration: state.duration,
      highlights: state.highlights,
      costBreakdown: state.costBreakdown,
      itinerary: newItinerary,
    );
  }

  void deleteActivity(int dayIndex, int activityIndex) {
    final newItinerary = [...state.itinerary];
    final day = newItinerary[dayIndex];
    final newActivities = [...day.activities];
    newActivities.removeAt(activityIndex);
    
    newItinerary[dayIndex] = PlannerItineraryDay(
      day: day.day,
      title: day.title,
      activities: newActivities,
    );
    
    state = PlannerItineraryPlan(
      title: state.title,
      type: state.type,
      totalCost: state.totalCost,
      duration: state.duration,
      highlights: state.highlights,
      costBreakdown: state.costBreakdown,
      itinerary: newItinerary,
    );
  }

  void addActivity(int dayIndex) {
    final newItinerary = [...state.itinerary];
    final day = newItinerary[dayIndex];
    final newActivities = [...day.activities];
    
    newActivities.add(PlannerActivity(
      time: '09:00 AM',
      activity: 'New Activity',
      location: 'Location Name',
    ));
    
    newItinerary[dayIndex] = PlannerItineraryDay(
      day: day.day,
      title: day.title,
      activities: newActivities,
    );
    
    state = PlannerItineraryPlan(
      title: state.title,
      type: state.type,
      totalCost: state.totalCost,
      duration: state.duration,
      highlights: state.highlights,
      costBreakdown: state.costBreakdown,
      itinerary: newItinerary,
    );
  }
}

final itineraryCustomizeProvider = NotifierProvider.family<ItineraryNotifier, PlannerItineraryPlan, PlannerItineraryPlan>((arg) {
  return ItineraryNotifier(arg);
});
