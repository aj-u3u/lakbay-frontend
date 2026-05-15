class GroupTrip {
  final String id;
  final String name;
  final String destination;
  final String image;
  final DateTime startDate;
  final DateTime endDate;
  final String summary;
  final List<GroupMember> members;
  final GroupBudget budget;
  final List<GroupTask> tasks;
  final List<GroupItineraryDay> itinerary;
  final List<GroupTransportInfo> transport;
  final List<String> notes;
  final List<String> photos;

  GroupTrip({
    required this.id,
    required this.name,
    required this.destination,
    required this.image,
    required this.startDate,
    required this.endDate,
    required this.summary,
    required this.members,
    required this.budget,
    required this.tasks,
    required this.itinerary,
    required this.transport,
    required this.notes,
    required this.photos,
  });
}

class GroupMember {
  final String id;
  final String name;
  final String avatar;
  final bool isLeader;
  final double contribution;
  final double spent;

  GroupMember({
    required this.id,
    required this.name,
    required this.avatar,
    required this.isLeader,
    required this.contribution,
    required this.spent,
  });
}

class GroupTask {
  final String id;
  final String title;
  final String assignedTo;
  final bool completed;

  GroupTask({
    required this.id,
    required this.title,
    required this.assignedTo,
    required this.completed,
  });
}

class GroupBudget {
  final double total;
  final double perPerson;
  final double spent;
  final List<GroupBudgetCategory> categories;

  GroupBudget({
    required this.total,
    required this.perPerson,
    required this.spent,
    required this.categories,
  });
}

class GroupBudgetCategory {
  final String name;
  final double amount;
  final String color;

  GroupBudgetCategory({
    required this.name,
    required this.amount,
    required this.color,
  });
}

class GroupItineraryDay {
  final int day;
  final String title;
  final List<GroupTripActivity> activities;

  GroupItineraryDay({
    required this.day,
    required this.title,
    required this.activities,
  });
}

class GroupTripActivity {
  final String time;
  final String activity;
  final String location;

  GroupTripActivity({
    required this.time,
    required this.activity,
    required this.location,
  });
}

class GroupTransportInfo {
  final String from;
  final String to;
  final String mode;
  final String fare;
  final String duration;

  GroupTransportInfo({
    required this.from,
    required this.to,
    required this.mode,
    required this.fare,
    required this.duration,
  });
}
