import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../shared/data/trips_data.dart';
import '../../shared/models/trip.dart';
import '../../shared/data/destinations_data.dart';
import '../../shared/models/destination.dart';

class TripDetailsPage extends ConsumerStatefulWidget {
  final String id;

  const TripDetailsPage({super.key, required this.id});

  @override
  ConsumerState<TripDetailsPage> createState() => _TripDetailsPageState();
}

class _TripDetailsPageState extends ConsumerState<TripDetailsPage> {
  String _activeTab = 'itinerary';
  int? _expandedDay = 1;
  List<String> _notes = [];
  List<String> _photos = [];
  bool _isInitialized = false;
  bool _hasGalleryPermission = false;

  @override
  void initState() {
    super.initState();
    // Pre-initialize to avoid any undefined issues on Web
    _notes = [];
    _photos = [];
    _initializeLocalData();
  }

  void _initializeLocalData() {
    if (_isInitialized) return;
    
    try {
      final trip = mockTrips.firstWhere(
        (t) => t.id == widget.id,
        orElse: () => mockTrips.first,
      );
      
      // Use cast to ensure we're getting a real list and handle potential JS undefined
      _notes = List<String>.from(trip.notes as dynamic ?? <String>[]);
      _photos = List<String>.from(trip.photos as dynamic ?? <String>[]);
      _isInitialized = true;
    } catch (e) {
      // Fallback to empty lists if anything goes wrong
      _notes = [];
      _photos = [];
      _isInitialized = true;
    }
  }

  void _showNoteDialog({String? initialText, int? index}) {
    final controller = TextEditingController(text: initialText);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(index == null ? 'Add Travel Note' : 'Edit Travel Note'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter your note here...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  if (index == null) {
                    _notes.add(controller.text.trim());
                  } else {
                    _notes[index] = controller.text.trim();
                  }
                });
                Navigator.pop(context);
              }
            },
            child: Text(index == null ? 'Add' : 'Save'),
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

  LatLng _getCenterLatLng(Trip trip) {
    if (trip.destination.toLowerCase().contains('samal') || trip.name.toLowerCase().contains('samal')) {
      return const LatLng(7.0833, 125.7167); // Samal
    } else if (trip.destination.toLowerCase().contains('apo')) {
      return const LatLng(7.0067, 125.2728); // Mt. Apo
    } else if (trip.destination.toLowerCase().contains('eden')) {
      return const LatLng(7.1907, 125.4553);
    } else if (trip.destination.toLowerCase().contains('dahican')) {
      return const LatLng(6.9544, 126.2331);
    }
    return const LatLng(7.0736, 125.6110); // Davao City
  }

  List<Marker> _getMarkers(Trip trip, Color primaryColor) {
    final List<Marker> markers = [];
    final Set<String> addedLocations = {};

    LatLng defaultCenter = const LatLng(7.0736, 125.6110);
    if (trip.destination.toLowerCase().contains('samal') || trip.name.toLowerCase().contains('samal')) {
      defaultCenter = const LatLng(7.0833, 125.7167);
    } else if (trip.destination.toLowerCase().contains('apo')) {
      defaultCenter = const LatLng(7.0067, 125.2728);
    }

    for (var day in trip.itinerary) {
      for (var act in day.activities) {
        final loc = act.location.toLowerCase();
        LatLng? coords;
        String title = act.activity;
        IconData icon = LucideIcons.mapPin;
        Color markerColor = primaryColor;

        if (loc.contains('hagimit')) {
          coords = const LatLng(6.8667, 125.3333);
          icon = LucideIcons.droplets;
          markerColor = Colors.blue;
          title = 'Hagimit Falls';
        } else if (loc.contains('samal') || loc.contains('pearl farm')) {
          coords = const LatLng(7.0833, 125.7167);
          icon = LucideIcons.compass;
          markerColor = Colors.orange;
          title = 'Samal Island Beach';
        } else if (loc.contains('apo')) {
          coords = const LatLng(7.0067, 125.2728);
          icon = LucideIcons.mountain;
          markerColor = Colors.green;
          title = 'Mt. Apo';
        } else if (loc.contains('eagle')) {
          coords = const LatLng(7.2333, 125.3667);
          icon = LucideIcons.bird;
          markerColor = Colors.red;
          title = 'Philippine Eagle Center';
        } else if (loc.contains('dahican') || loc.contains('mati')) {
          coords = const LatLng(6.9544, 126.2331);
          icon = LucideIcons.waves;
          markerColor = Colors.teal;
          title = 'Dahican Beach';
        } else if (loc.contains('monfort')) {
          coords = const LatLng(7.1333, 125.6500);
          icon = LucideIcons.shield;
          markerColor = Colors.purple;
          title = 'Monfort Bat Sanctuary';
        } else if (loc.contains('malagos')) {
          coords = const LatLng(7.2500, 125.3833);
          icon = LucideIcons.flower;
          markerColor = Colors.pink;
          title = 'Malagos Garden Resort';
        } else if (loc.contains('eden')) {
          coords = const LatLng(7.1907, 125.4553);
          icon = LucideIcons.trees;
          markerColor = Colors.green;
          title = 'Eden Nature Park';
        } else if (loc.contains('davao city') || loc.contains('sasa')) {
          coords = const LatLng(7.0736, 125.6110);
          icon = LucideIcons.mapPin;
          markerColor = Colors.grey;
          title = 'Davao City / Wharf';
        }

        if (coords != null && !addedLocations.contains(coords.toString())) {
          addedLocations.add(coords.toString());
          markers.add(
            Marker(
              point: coords,
              width: 60,
              height: 60,
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(title),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: markerColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                        ],
                      ),
                      child: Icon(icon, color: Colors.white, size: 14),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 2),
                        ],
                      ),
                      child: Text(
                        act.location,
                        style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black87),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      }
    }

    if (markers.isEmpty) {
      markers.add(
        Marker(
          point: defaultCenter,
          width: 60,
          height: 60,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(LucideIcons.mapPin, color: Colors.white, size: 14),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  trip.destination,
                  style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black87),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return markers;
  }

  List<Polyline> _getPolylines(Trip trip, Color primaryColor) {
    final List<LatLng> points = [];
    final Set<String> addedPoints = {};

    for (var day in trip.itinerary) {
      for (var act in day.activities) {
        final loc = act.location.toLowerCase();
        LatLng? coords;

        if (loc.contains('hagimit')) {
          coords = const LatLng(6.8667, 125.3333);
        } else if (loc.contains('samal') || loc.contains('pearl farm')) {
          coords = const LatLng(7.0833, 125.7167);
        } else if (loc.contains('apo')) {
          coords = const LatLng(7.0067, 125.2728);
        } else if (loc.contains('eagle')) {
          coords = const LatLng(7.2333, 125.3667);
        } else if (loc.contains('dahican') || loc.contains('mati')) {
          coords = const LatLng(6.9544, 126.2331);
        } else if (loc.contains('monfort')) {
          coords = const LatLng(7.1333, 125.6500);
        } else if (loc.contains('malagos')) {
          coords = const LatLng(7.2500, 125.3833);
        } else if (loc.contains('eden')) {
          coords = const LatLng(7.1907, 125.4553);
        } else if (loc.contains('davao city') || loc.contains('sasa')) {
          coords = const LatLng(7.0736, 125.6110);
        }

        if (coords != null && !addedPoints.contains(coords.toString())) {
          addedPoints.add(coords.toString());
          points.add(coords);
        }
      }
    }

    if (points.length < 2) return [];

    return [
      Polyline(
        points: points,
        strokeWidth: 4.0,
        color: primaryColor,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    _initializeLocalData();

    final trip = mockTrips.firstWhere(
      (t) => t.id == widget.id,
      orElse: () => mockTrips.first,
    );

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;
    final budgetProgress = trip.budget.spent / trip.budget.total;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Header Image with Back button
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
                trip.image,
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
                    trip.name,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(LucideIcons.mapPin, size: 18, color: colorScheme.onSurface.withValues(alpha: 0.6)),
                      const SizedBox(width: 8),
                      Text(
                        trip.destination,
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
                        '${DateFormat('MMM d, yyyy').format(trip.startDate)} - ${DateFormat('MMM d, yyyy').format(trip.endDate)}',
                        style: TextStyle(fontSize: 16, color: colorScheme.onSurface.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Trip Summary
                  _CardContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trip Summary',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          trip.summary,
                          style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7), height: 1.5),
                        ),
                      ],
                    ),
                  ),

                  // Travel Notes
                  _CardContainer(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(LucideIcons.stickyNote, size: 20, color: primaryColor),
                                const SizedBox(width: 10),
                                Text(
                                  'Travel Notes',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () => _showNoteDialog(),
                              icon: const Icon(LucideIcons.plus, size: 20),
                              style: IconButton.styleFrom(
                                backgroundColor: primaryColor.withValues(alpha: 0.1),
                                foregroundColor: primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if ((_notes ?? []).length == 0)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: Text(
                                'No notes yet. Add one to remember important details!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          )
                        else
                          ...List.generate((_notes ?? []).length, (index) {
                            final note = _notes[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text('•', style: TextStyle(color: primaryColor, fontSize: 18)),
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
                                        onPressed: () => _showNoteDialog(initialText: note, index: index),
                                        icon: const Icon(LucideIcons.pencil, size: 16),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        onPressed: () => _deleteNote(index),
                                        icon: const Icon(LucideIcons.trash2, size: 16),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        color: colorScheme.error.withValues(alpha: 0.6),
                                        visualDensity: VisualDensity.compact,
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

                  // Photo Memories
                  _CardContainer(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(LucideIcons.camera, size: 20, color: primaryColor),
                                const SizedBox(width: 10),
                                Text(
                                  'Photo Memories',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: _showPhotoDialog,
                              icon: const Icon(LucideIcons.plus, size: 20),
                              style: IconButton.styleFrom(
                                backgroundColor: primaryColor.withValues(alpha: 0.1),
                                foregroundColor: primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if ((_photos ?? []).length == 0)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Column(
                              children: [
                                Icon(LucideIcons.camera, size: 48, color: colorScheme.onSurface.withValues(alpha: 0.2)),
                                const SizedBox(height: 12),
                                Text(
                                  'No photos yet. Capture your memories!', 
                                  style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4))
                                ),
                              ],
                            ),
                          )
                        else
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: (_photos ?? []).length,
                            itemBuilder: (context, index) => ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                (_photos ?? [])[index], 
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.broken_image, color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Tabs
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _TabButton(
                          label: 'Itinerary',
                          isActive: _activeTab == 'itinerary',
                          onTap: () => setState(() => _activeTab = 'itinerary'),
                        ),
                        _TabButton(
                          label: 'Route',
                          isActive: _activeTab == 'route',
                          onTap: () => setState(() => _activeTab = 'route'),
                        ),
                        _TabButton(
                          label: 'Transport',
                          isActive: _activeTab == 'transport',
                          onTap: () => setState(() => _activeTab = 'transport'),
                        ),
                        _TabButton(
                          label: 'Budget',
                          isActive: _activeTab == 'budget',
                          onTap: () => setState(() => _activeTab = 'budget'),
                        ),
                        _TabButton(
                          label: 'Destinations',
                          isActive: _activeTab == 'destinations',
                          onTap: () => setState(() => _activeTab = 'destinations'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tab Content
                  if (_activeTab == 'itinerary')
                    ...(trip.itinerary ?? []).map((day) => _ItineraryDayCard(
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
                              Icon(LucideIcons.navigation, size: 20, color: primaryColor),
                              const SizedBox(width: 10),
                              Text(
                                'Route Optimization', 
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: SizedBox(
                              height: 250,
                              width: double.infinity,
                              child: FlutterMap(
                                options: MapOptions(
                                  initialCenter: _getCenterLatLng(trip),
                                  initialZoom: 10.0,
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName: 'com.lakbayplus.app',
                                  ),
                                  PolylineLayer(
                                    polylines: _getPolylines(trip, primaryColor),
                                  ),
                                  MarkerLayer(
                                    markers: _getMarkers(trip, primaryColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total Distance', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6))),
                              Text('~45 km', style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Estimated Travel Time', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6))),
                              Text('2.5 hours', style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                            ],
                          ),
                        ],
                      ),
                    ),

                  if (_activeTab == 'transport')
                    ...(trip.transport ?? []).map((t) => _TransportCard(transport: t)),

                  if (_activeTab == 'budget')
                    _CardContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(LucideIcons.wallet, size: 20, color: primaryColor),
                              const SizedBox(width: 10),
                              Text(
                                'Personal Budget', 
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _BudgetRow(label: 'Total Budget', value: trip.budget.total),
                          _BudgetRow(label: 'Spent', value: trip.budget.spent, color: primaryColor),
                          _BudgetRow(label: 'Remaining', value: trip.budget.total - trip.budget.spent),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: budgetProgress,
                              minHeight: 12,
                              backgroundColor: colorScheme.onSurface.withValues(alpha: 0.05),
                              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Text(
                              '${(budgetProgress * 100).toStringAsFixed(0)}% of budget used',
                              style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 12),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Expense Breakdown', 
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface)
                          ),
                          const SizedBox(height: 16),
                          ... (trip.budget.categories ?? []).map((cat) => Padding(
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
                                    value: cat.amount / trip.budget.total,
                                    minHeight: 8,
                                    backgroundColor: colorScheme.onSurface.withValues(alpha: 0.05),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _parseColor(cat.color),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colorScheme.onSurface.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Daily Spending Limit', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5))),
                                Text(
                                  '₱${NumberFormat('#,###').format(trip.budget.daily)}', 
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (_activeTab == 'destinations')
                    Builder(
                      builder: (context) {
                        Destination? matchedDest;
                        try {
                          matchedDest = destinations.firstWhere(
                            (d) => d.name.toLowerCase().contains(trip.destination.toLowerCase()) ||
                                   trip.destination.toLowerCase().contains(d.name.toLowerCase()) ||
                                   trip.name.toLowerCase().contains(d.name.toLowerCase())
                          );
                        } catch (_) {
                          for (var d in destinations) {
                            for (var day in trip.itinerary) {
                              for (var act in day.activities) {
                                if (act.location.toLowerCase().contains(d.name.toLowerCase()) ||
                                    d.name.toLowerCase().contains(act.location.toLowerCase())) {
                                  matchedDest = d;
                                  break;
                                }
                              }
                              if (matchedDest != null) break;
                            }
                            if (matchedDest != null) break;
                          }
                        }

                        if (matchedDest == null) {
                          return _CardContainer(
                            child: Column(
                              children: [
                                Icon(LucideIcons.mapPin, size: 48, color: colorScheme.onSurface.withValues(alpha: 0.2)),
                                const SizedBox(height: 12),
                                Text(
                                  'No custom destination metadata matched for "${trip.destination}". Check your trip settings to match Samal Island, Eden Nature Park, Mt. Apo, Dahican Beach, or Malagos Garden Resort!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5)),
                                ),
                              ],
                            ),
                          );
                        }

                        return _CardContainer(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      matchedDest.image,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 80,
                                        height: 80,
                                        color: colorScheme.primary.withValues(alpha: 0.1),
                                        child: Icon(LucideIcons.image, color: primaryColor),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          matchedDest.name,
                                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(LucideIcons.mapPin, size: 14, color: primaryColor),
                                            const SizedBox(width: 4),
                                            Text(
                                              matchedDest.location,
                                              style: TextStyle(fontSize: 14, color: colorScheme.onSurface.withValues(alpha: 0.6)),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(LucideIcons.star, size: 14, color: Colors.amber),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${matchedDest.rating} / 5.0 Rating',
                                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Text(
                                matchedDest.description,
                                style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7), height: 1.5),
                              ),
                              const Divider(height: 32),
                              
                              // Pricing Section
                              Text(
                                'Pricing Details & Packages',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                              ),
                              const SizedBox(height: 12),
                              _DetailRow(label: 'Entrance Fee', value: matchedDest.entranceFee, icon: LucideIcons.ticket),
                              if (matchedDest.overnightFee != null)
                                _DetailRow(label: 'Overnight Fee', value: matchedDest.overnightFee!, icon: LucideIcons.moon),
                              _DetailRow(label: 'Operating Hours', value: matchedDest.operatingHours.replaceAll('\n', ' | '), icon: LucideIcons.clock),
                              
                              const SizedBox(height: 20),
                              
                              // Accessibility flags
                              Text(
                                'Accessibility & Family Features',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  if (matchedDest.accessibility.isKidFriendly)
                                    _AccessibilityBadge(label: 'Kid-Friendly', icon: LucideIcons.smile, color: Colors.green),
                                  if (matchedDest.accessibility.isWheelchairAccessible)
                                    _AccessibilityBadge(label: 'Wheelchair Accessible', icon: LucideIcons.accessibility, color: Colors.blue),
                                  if (matchedDest.accessibility.isPetFriendly)
                                    _AccessibilityBadge(label: 'Pet-Friendly', icon: LucideIcons.dog, color: Colors.orange),
                                  if (matchedDest.accessibility.isElderlyFriendly)
                                    _AccessibilityBadge(label: 'Elderly-Friendly', icon: LucideIcons.heart, color: Colors.red),
                                ],
                              ),
                              const Divider(height: 32),
                              
                              // Activities prices list
                              if (matchedDest.activityPrices != null && matchedDest.activityPrices!.isNotEmpty) ...[
                                Text(
                                  'Experience & Activity Rates',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                                ),
                                const SizedBox(height: 8),
                                ...matchedDest.activityPrices!.map((ap) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          ap.name,
                                          style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
                                        ),
                                      ),
                                      Text(
                                        '${ap.price}${ap.isPerPerson ? ' / pax' : ''}',
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor),
                                      ),
                                    ],
                                  ),
                                )),
                                const Divider(height: 32),
                              ],

                              // Accommodations
                              if (matchedDest.accommodations != null && matchedDest.accommodations!.isNotEmpty) ...[
                                Text(
                                  'Lodging & Accommodations',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                                ),
                                const SizedBox(height: 12),
                                ...matchedDest.accommodations!.map((ac) => Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: colorScheme.onSurface.withValues(alpha: 0.03),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            ac.type,
                                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                                          ),
                                          Text(
                                            ac.price,
                                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: primaryColor),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        ac.description,
                                        style: TextStyle(fontSize: 13, color: colorScheme.onSurface.withValues(alpha: 0.6)),
                                      ),
                                    ],
                                  ),
                                )),
                                const Divider(height: 32),
                              ],

                              // Quick Travel Info
                              Text(
                                'Travel Guide Info',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                              ),
                              const SizedBox(height: 12),
                              _DetailRow(label: 'Best Time to Visit', value: matchedDest.bestTimeToVisit, icon: LucideIcons.sun),
                              _DetailRow(label: 'Travel Time', value: matchedDest.estimatedTravelTime, icon: LucideIcons.hourglass),
                              _DetailRow(label: 'How to Get There', value: matchedDest.howToGetThere, icon: LucideIcons.bus),
                              _DetailRow(label: 'Meal Plan Guide', value: matchedDest.mealPlanDetails, icon: LucideIcons.utensilsCrossed),
                              
                              if (matchedDest.whatToBring.isNotEmpty) ...[
                                const Divider(height: 32),
                                Text(
                                  'What to Bring Checklist',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: matchedDest.whatToBring.map((item) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: primaryColor.withValues(alpha: 0.15)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(LucideIcons.check, size: 14, color: primaryColor),
                                        const SizedBox(width: 6),
                                        Text(
                                          item,
                                          style: TextStyle(fontSize: 13, color: colorScheme.onSurface.withValues(alpha: 0.8)),
                                        ),
                                      ],
                                    ),
                                  )).toList(),
                                ),
                              ],
                            ],
                          ),
                        );
                      }
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String colorStr) {
    if (colorStr.startsWith('#')) {
      return Color(int.parse(colorStr.replaceFirst('#', '0xFF')));
    }
    return Colors.teal;
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
  final VoidCallback onTap;

  const _TabButton({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? primaryColor : colorScheme.surface,
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

class _ItineraryDayCard extends StatelessWidget {
  final ItineraryDay day;
  final bool isExpanded;
  final VoidCallback onTap;

  const _ItineraryDayCard({required this.day, required this.isExpanded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;

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
                      Text('Day ${day.day}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                      Text(day.title, style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 14)),
                    ],
                  ),
                  Icon(isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown, color: colorScheme.onSurface.withValues(alpha: 0.4)),
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
                        child: Text(act.time, style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
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
                                Text(act.location, style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 12)),
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

class _TransportCard extends StatelessWidget {
  final TransportInfo transport;
  const _TransportCard({required this.transport});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;

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
                decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(LucideIcons.bus, color: primaryColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(transport.mode, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                    Text('${transport.from} → ${transport.to}', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12)),
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

class _BudgetRow extends StatelessWidget {
  final String label;
  final double value;
  final Color? color;

  const _BudgetRow({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 14)),
          Text(
            '₱${NumberFormat('#,###').format(value)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color ?? colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DetailRow({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: primaryColor),
          const SizedBox(width: 12),
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccessibilityBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _AccessibilityBadge({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

