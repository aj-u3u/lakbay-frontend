import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../shared/data/groups_data.dart';
import '../../shared/models/group_trip.dart';

class GroupDetailsPage extends ConsumerStatefulWidget {
  final String id;

  const GroupDetailsPage({super.key, required this.id});

  @override
  ConsumerState<GroupDetailsPage> createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends ConsumerState<GroupDetailsPage> {
  String _activeTab = 'itinerary';
  int? _expandedDay = 1;
  List<GroupMember> _members = [];
  late GroupBudget _budget;
  List<String> _notes = [];
  List<String> _photos = [];
  List<GroupTask> _tasks = [];
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _members = [];
    _initializeLocalData();
  }

  void _initializeLocalData() {
    if (_isInitialized) return;
    
    try {
      final group = mockGroupTrips.firstWhere(
        (g) => g.id == widget.id,
        orElse: () => mockGroupTrips.first,
      );
      
      _members = List<GroupMember>.from(group.members as dynamic ?? <GroupMember>[]);
      _budget = group.budget;
      _notes = List<String>.from(group.notes as dynamic ?? <String>[]);
      _photos = List<String>.from(group.photos as dynamic ?? <String>[]);
      _tasks = List<GroupTask>.from(group.tasks as dynamic ?? <GroupTask>[]);
      _isInitialized = true;
    } catch (e) {
      _members = [];
      _budget = GroupBudget(total: 0, perPerson: 0, spent: 0, categories: []);
      _notes = [];
      _photos = [];
      _tasks = [];
      _isInitialized = true;
    }
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    String selectedMember = _members.isNotEmpty ? _members.first.name : 'Unassigned';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'What needs to be done?',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedMember,
                decoration: const InputDecoration(
                  labelText: 'Assign to',
                  border: OutlineInputBorder(),
                ),
                items: _members.map((m) => DropdownMenuItem(
                  value: m.name,
                  child: Text(m.name),
                )).toList(),
                onChanged: (val) => setDialogState(() => selectedMember = val!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isNotEmpty) {
                  setState(() {
                    _tasks.add(GroupTask(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: titleController.text.trim(),
                      assignedTo: selectedMember,
                      completed: false,
                    ));
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleTask(int index) {
    setState(() {
      _tasks[index] = GroupTask(
        id: _tasks[index].id,
        title: _tasks[index].title,
        assignedTo: _tasks[index].assignedTo,
        completed: !_tasks[index].completed,
      );
    });
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  void _showNoteDialog({String? existingNote, int? index}) {
    final noteController = TextEditingController(text: existingNote);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingNote == null ? 'Add Note' : 'Edit Note'),
        content: TextField(
          controller: noteController,
          maxLines: 3,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter your travel note...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (noteController.text.trim().isNotEmpty) {
                setState(() {
                  if (index == null) {
                    _notes.insert(0, noteController.text.trim());
                  } else {
                    _notes[index] = noteController.text.trim();
                  }
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteNote(int index) {
    setState(() {
      _notes.removeAt(index);
    });
  }

  Future<void> _showPhotoDialog() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _photos.insert(0, image.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to access gallery')),
        );
      }
    }
  }

  void _updateTotalBudget() {
    final budgetController = TextEditingController(text: _budget.total.toInt().toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Total Budget'),
        content: TextField(
          controller: budgetController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Total Amount (₱)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newTotal = double.tryParse(budgetController.text) ?? _budget.total;
              setState(() {
                _budget = GroupBudget(
                  total: newTotal,
                  perPerson: _members.isEmpty ? newTotal : newTotal / _members.length,
                  spent: _budget.spent,
                  categories: _budget.categories,
                );
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editMemberContribution(int index) {
    final m = _members[index];
    final contribController = TextEditingController(text: m.contribution.toInt().toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Contribution: ${m.name}'),
        content: TextField(
          controller: contribController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Pledged Amount (₱)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newContrib = double.tryParse(contribController.text) ?? m.contribution;
              setState(() {
                _members[index] = GroupMember(
                  id: m.id,
                  name: m.name,
                  avatar: m.avatar,
                  isLeader: m.isLeader,
                  contribution: newContrib,
                  spent: m.spent,
                );
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _removeMember(int index) {
    if (_members[index].isLeader) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot remove the group leader')),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Member?'),
        content: Text('Are you sure you want to remove ${_members[index].name} from the group?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() {
                _members.removeAt(index);
                // Recalculate per person budget
                _budget = GroupBudget(
                  total: _budget.total,
                  perPerson: _members.isEmpty ? _budget.total : _budget.total / _members.length,
                  spent: _budget.spent,
                  categories: _budget.categories,
                );
              });
              Navigator.pop(context);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddMemberDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Group Member'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter member name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                setState(() {
                  _members.add(GroupMember(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text.trim(),
                    avatar: 'https://api.dicebear.com/7.x/avataaars/png?seed=${nameController.text.trim()}',
                    isLeader: false,
                    contribution: 0,
                    spent: 0,
                  ));
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final group = mockGroupTrips.firstWhere((g) => g.id == widget.id, orElse: () => mockGroupTrips.first);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final secondaryColor = colorScheme.secondary;
    final leader = _members.firstWhere((m) => m.isLeader, orElse: () => _members.isNotEmpty ? _members.first : GroupMember(id: '', name: 'N/A', avatar: '', isLeader: true, contribution: 0, spent: 0));
    final teamMembers = _members.where((m) => !m.isLeader).toList();
    final completedTasksCount = _tasks.where((t) => t.completed).length;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            automaticallyImplyLeading: false,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: colorScheme.surface.withValues(alpha: 0.9),
                child: IconButton(
                  icon: Icon(LucideIcons.arrowLeft, color: colorScheme.onSurface, size: 20),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                group.image,
                fit: BoxFit.cover,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(LucideIcons.mapPin, size: 18, color: colorScheme.onSurface.withValues(alpha: 0.6)),
                      const SizedBox(width: 8),
                      Text(
                        group.destination,
                        style: TextStyle(fontSize: 16, color: colorScheme.onSurface.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(LucideIcons.calendar, size: 18, color: colorScheme.onSurface.withValues(alpha: 0.6)),
                      const SizedBox(width: 8),
                      Text(
                        '${DateFormat('MMM d').format(group.startDate)} - ${DateFormat('MMM d, yyyy').format(group.endDate)}',
                        style: TextStyle(fontSize: 16, color: colorScheme.onSurface.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _CardContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trip Summary', 
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)
                        ),
                        const SizedBox(height: 8),
                        Text(
                          group.summary, 
                          style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7), height: 1.5)
                        ),
                      ],
                    ),
                  ),

                  _CardContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(LucideIcons.users, size: 20, color: secondaryColor),
                                const SizedBox(width: 10),
                                Text(
                                  'Members (${_members.length})',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                _SmallIconButton(
                                  icon: LucideIcons.userPlus, 
                                  onTap: _showAddMemberDialog,
                                ),
                                const SizedBox(width: 8),
                                _SmallIconButton(
                                  icon: LucideIcons.wallet, 
                                  onTap: () => _showBudgetModal(context, group),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Leader', 
                          style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 12)
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            CircleAvatar(radius: 20, backgroundImage: NetworkImage(leader.avatar)),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  leader.name, 
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colorScheme.onSurface)
                                ),
                                Text(
                                  'Trip organizer', 
                                  style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12)
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Team', 
                          style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 12)
                        ),
                        const SizedBox(height: 12),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisExtent: 50, // Fixed height per item for stability
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: teamMembers.length,
                          itemBuilder: (context, index) {
                            final m = teamMembers[index];
                            return Row(
                              children: [
                                CircleAvatar(radius: 14, backgroundImage: NetworkImage(m.avatar)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    m.name, 
                                    style: TextStyle(fontSize: 13, color: colorScheme.onSurface), 
                                    overflow: TextOverflow.ellipsis
                                  )
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  _CardContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(LucideIcons.squareCheck, size: 20, color: secondaryColor),
                                const SizedBox(width: 10),
                                Text(
                                  'Group Tasks (${completedTasksCount}/${_tasks.length})',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                                ),
                              ],
                            ),
                            _SmallIconButton(
                              icon: LucideIcons.plus, 
                              onTap: _showAddTaskDialog,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_tasks.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text('No tasks assigned yet', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4))),
                            ),
                          ),
                        ..._tasks.asMap().entries.map((entry) {
                          final index = entry.key;
                          final task = entry.value;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.onSurface.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () => _toggleTask(index),
                                  child: Icon(
                                    task.completed ? LucideIcons.circleCheck : LucideIcons.circle,
                                    color: task.completed ? secondaryColor : colorScheme.onSurface.withValues(alpha: 0.3),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        task.title,
                                        style: TextStyle(
                                          fontSize: 14,
                                          decoration: task.completed ? TextDecoration.lineThrough : null,
                                          color: task.completed ? colorScheme.onSurface.withValues(alpha: 0.4) : colorScheme.onSurface,
                                        ),
                                      ),
                                      Text(
                                        task.assignedTo, 
                                        style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withValues(alpha: 0.5))
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(LucideIcons.trash2, size: 16),
                                  onPressed: () => _deleteTask(index),
                                  color: Colors.red.withValues(alpha: 0.3),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  // Travel Notes Section
                  _CardContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(LucideIcons.stickyNote, size: 20, color: secondaryColor),
                                const SizedBox(width: 10),
                                Text(
                                  'Travel Notes', 
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)
                                ),
                              ],
                            ),
                            _SmallIconButton(
                              icon: LucideIcons.plus, 
                              onTap: () => _showNoteDialog(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if ((_notes ?? []).length == 0)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: Text(
                                'No notes added yet', 
                                style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4))
                              ),
                            ),
                          ),
                        ...(_notes ?? []).asMap().entries.map((entry) {
                          final index = entry.key;
                          final note = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text('•', style: TextStyle(color: secondaryColor, fontSize: 18)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    note,
                                    style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(LucideIcons.pencil, size: 14),
                                      onPressed: () => _showNoteDialog(existingNote: note, index: index),
                                      color: colorScheme.onSurface.withValues(alpha: 0.3),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    const SizedBox(width: 4),
                                    IconButton(
                                      icon: const Icon(LucideIcons.trash2, size: 14),
                                      onPressed: () => _deleteNote(index),
                                      color: Colors.red.withValues(alpha: 0.3),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  // Photo Memories Section
                  _CardContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(LucideIcons.camera, size: 20, color: secondaryColor),
                                const SizedBox(width: 10),
                                Text(
                                  'Photo Memories', 
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)
                                ),
                              ],
                            ),
                            _SmallIconButton(
                              icon: LucideIcons.plus, 
                              onTap: _showPhotoDialog,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if ((_photos ?? []).length == 0)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Column(
                              children: [
                                Center(
                                  child: Icon(
                                    LucideIcons.image, 
                                    size: 48, 
                                    color: colorScheme.onSurface.withValues(alpha: 0.1)
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No photos uploaded yet', 
                                  style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4))
                                ),
                              ],
                            ),
                          ),
                        if ((_photos ?? []).length > 0)
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              mainAxisExtent: 100, // Fixed height for photo cells
                            ),
                            itemCount: _photos.length,
                            itemBuilder: (context, index) => ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                _photos[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: colorScheme.onSurface.withValues(alpha: 0.05),
                                  child: const Icon(LucideIcons.imageOff, color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _TabButton(
                          label: 'Itinerary',
                          isActive: _activeTab == 'itinerary',
                          color: secondaryColor,
                          onTap: () => setState(() => _activeTab = 'itinerary'),
                        ),
                        _TabButton(
                          label: 'Route',
                          isActive: _activeTab == 'route',
                          color: secondaryColor,
                          onTap: () => setState(() => _activeTab = 'route'),
                        ),
                        _TabButton(
                          label: 'Transport',
                          isActive: _activeTab == 'transport',
                          color: secondaryColor,
                          onTap: () => setState(() => _activeTab = 'transport'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (_activeTab == 'itinerary')
                    ...(group.itinerary ?? []).map((day) => _GroupItineraryDayCard(
                      day: day,
                      isExpanded: _expandedDay == day.day,
                      onTap: () => setState(() => _expandedDay = _expandedDay == day.day ? null : day.day),
                    )),
                  
                  if (_activeTab == 'route')
                    _CardContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(LucideIcons.navigation, size: 20, color: secondaryColor),
                              const SizedBox(width: 10),
                              Text(
                                'Route Optimization', 
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: colorScheme.onSurface.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(LucideIcons.mapPin, size: 40, color: colorScheme.onSurface.withValues(alpha: 0.2)),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Interactive Map of ${group.destination}', 
                                    style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4))
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (_activeTab == 'transport')
                    ...(group.transport ?? []).map((t) => _GroupTransportCard(transport: t)),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBudgetModal(
    BuildContext context, 
    GroupTrip group, 
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return _GroupBudgetModal(
            group: group,
            budget: _budget,
            members: _members,
            onEditTotal: () {
              final budgetController = TextEditingController(text: _budget.total.toInt().toString());
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Edit Total Budget'),
                  content: TextField(
                    controller: budgetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Total Amount (₱)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    ElevatedButton(
                      onPressed: () {
                        final newTotal = double.tryParse(budgetController.text) ?? _budget.total;
                        setState(() {
                          _budget = GroupBudget(
                            total: newTotal,
                            perPerson: _members.isEmpty ? newTotal : newTotal / _members.length,
                            spent: _budget.spent,
                            categories: _budget.categories,
                          );
                        });
                        setModalState(() {}); // Rebuild the modal
                        Navigator.pop(context);
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              );
            },
            onEditMember: (index) {
              final m = _members[index];
              final contribController = TextEditingController(text: m.contribution.toInt().toString());
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Edit Contribution: ${m.name}'),
                  content: TextField(
                    controller: contribController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Pledged Amount (₱)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    ElevatedButton(
                      onPressed: () {
                        final newContrib = double.tryParse(contribController.text) ?? m.contribution;
                        setState(() {
                          _members[index] = GroupMember(
                            id: m.id,
                            name: m.name,
                            avatar: m.avatar,
                            isLeader: m.isLeader,
                            contribution: newContrib,
                            spent: m.spent,
                          );
                        });
                        setModalState(() {}); // Rebuild the modal
                        Navigator.pop(context);
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              );
            },
            onRemoveMember: (index) {
              if (_members[index].isLeader) return;
              
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Remove Member?'),
                  content: Text('Are you sure you want to remove ${_members[index].name}?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _members.removeAt(index);
                          _budget = GroupBudget(
                            total: _budget.total,
                            perPerson: _members.isEmpty ? _budget.total : _budget.total / _members.length,
                            spent: _budget.spent,
                            categories: _budget.categories,
                          );
                        });
                        setModalState(() {}); // Rebuild the modal
                        Navigator.pop(context);
                      },
                      child: const Text('Remove', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _SmallIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _SmallIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(
        backgroundColor: secondaryColor.withValues(alpha: 0.1),
        foregroundColor: secondaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _GroupBudgetModal extends StatelessWidget {
  final GroupTrip group;
  final GroupBudget budget;
  final List<GroupMember> members;
  final VoidCallback onEditTotal;
  final Function(int) onEditMember;
  final Function(int) onRemoveMember;

  const _GroupBudgetModal({
    required this.group,
    required this.budget,
    required this.members,
    required this.onEditTotal,
    required this.onEditMember,
    required this.onRemoveMember,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final secondaryColor = colorScheme.secondary;
    final progress = budget.spent / (budget.total > 0 ? budget.total : 1);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Shared Budget', 
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onSurface)
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context), 
                  icon: Icon(LucideIcons.x, color: colorScheme.onSurface)
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Budget', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5))),
                    Row(
                      children: [
                        Text(
                          '₱${NumberFormat('#,###').format(budget.total)}', 
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colorScheme.onSurface)
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(LucideIcons.pencil, size: 18, color: secondaryColor),
                          onPressed: onEditTotal,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Per Person', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5))),
                    Text(
                      '₱${NumberFormat('#,###').format(budget.perPerson)}', 
                      style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Spent', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5))),
                    Text(
                      '₱${NumberFormat('#,###').format(budget.spent)}', 
                      style: TextStyle(color: secondaryColor, fontWeight: FontWeight.bold)
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 12,
                    backgroundColor: colorScheme.onSurface.withValues(alpha: 0.05),
                    valueColor: AlwaysStoppedAnimation<Color>(secondaryColor),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Member Contributions', 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)
                ),
                const SizedBox(height: 16),
                ...(members ?? []).asMap().entries.map((entry) {
                  final index = entry.key;
                  final m = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(radius: 20, backgroundImage: NetworkImage(m.avatar)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    m.name, 
                                    style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)
                                  ),
                                  if (m.isLeader)
                                    Container(
                                      margin: const EdgeInsets.only(left: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: secondaryColor.withValues(alpha: 0.1), 
                                        borderRadius: BorderRadius.circular(10)
                                      ),
                                      child: Text(
                                        'Leader', 
                                        style: TextStyle(color: secondaryColor, fontSize: 10, fontWeight: FontWeight.bold)
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Pledged: ₱${NumberFormat('#,###').format(m.contribution)}  •  Spent: ₱${NumberFormat('#,###').format(m.spent)}',
                                style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(LucideIcons.pencil, size: 16),
                              onPressed: () => onEditMember(index),
                              color: colorScheme.onSurface.withValues(alpha: 0.4),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 8),
                            if (!m.isLeader)
                              IconButton(
                                icon: const Icon(LucideIcons.trash2, size: 16),
                                onPressed: () => onRemoveMember(index),
                                color: Colors.red.withValues(alpha: 0.5),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 32),
                Text(
                  'Expense Breakdown', 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)
                ),
                const SizedBox(height: 16),
                ...(group.budget.categories ?? []).map((cat) => Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(cat.name, style: TextStyle(fontSize: 14, color: colorScheme.onSurface)),
                          Text(
                            '₱${NumberFormat('#,###').format(cat.amount)}', 
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colorScheme.onSurface)
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: cat.amount / group.budget.total,
                          minHeight: 8,
                          backgroundColor: colorScheme.onSurface.withValues(alpha: 0.05),
                          valueColor: AlwaysStoppedAnimation<Color>(Color(int.parse(cat.color.replaceFirst('#', '0xFF')))),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupItineraryDayCard extends StatelessWidget {
  final GroupItineraryDay day;
  final bool isExpanded;
  final VoidCallback onTap;

  const _GroupItineraryDayCard({required this.day, required this.isExpanded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final secondaryColor = colorScheme.secondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Day ${day.day}', 
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)
                      ),
                      Text(
                        day.title, 
                        style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 14)
                      ),
                    ],
                  ),
                  Icon(
                    isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown, 
                    color: colorScheme.onSurface.withValues(alpha: 0.4)
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: (day.activities ?? []).map((act) => Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 70,
                        child: Text(act.time, style: TextStyle(color: secondaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(act.activity, style: TextStyle(fontSize: 14, color: colorScheme.onSurface)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(LucideIcons.mapPin, size: 12, color: colorScheme.onSurface.withValues(alpha: 0.4)),
                                const SizedBox(width: 4),
                                Text(
                                  act.location, 
                                  style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 12)
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _GroupTransportCard extends StatelessWidget {
  final GroupTransportInfo transport;
  const _GroupTransportCard({required this.transport});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final secondaryColor = colorScheme.secondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: secondaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(LucideIcons.bus, color: secondaryColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(transport.mode, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                    Text(
                      '${transport.from} → ${transport.to}', 
                      style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12)
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Fare', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 12)),
                    Text(transport.fare, style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Duration', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 12)),
                    Text(transport.duration, style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardContainer extends StatelessWidget {
  final Widget child;
  const _CardContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  const _TabButton({required this.label, required this.isActive, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? color : colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (!isActive) BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : colorScheme.onSurface.withValues(alpha: 0.6),
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
