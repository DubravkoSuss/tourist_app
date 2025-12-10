import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/sights/sights_bloc.dart';
import '../../../domain/entities/sight.dart';

class MapScreen extends StatefulWidget {
  final Sight? sight;
  final double? initialLatitude;
  final double? initialLongitude;

  const MapScreen({
    super.key,
    this.sight,
    this.initialLatitude,
    this.initialLongitude,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  // Zagreb city center coordinates (default)
  late final LatLng _center;
  late final double _initialZoom;

  @override
  void initState() {
    super.initState();

    // Set initial center based on passed coordinates or default to Zagreb
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _center = LatLng(widget.initialLatitude!, widget.initialLongitude!);
      _initialZoom = 15.0; // Zoom closer when showing specific sight
    } else {
      _center = const LatLng(45.8150, 15.9819); // Zagreb city center
      _initialZoom = 13.0;
    }

    // Load sights when map opens
    context.read<SightsBloc>().add(LoadSightsEvent());
  }

  void _showSightDetails(Sight sight) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon and rating
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.place,
                            color: Colors.blue,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sight.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    sight.rating.toString(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Address
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 18, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            sight.address,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Description title
                    const Text(
                      'About',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Description
                    Text(
                      sight.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _mapController.move(
                                LatLng(sight.latitude, sight.longitude),
                                15.0,
                              );
                            },
                            icon: const Icon(Icons.zoom_in),
                            label: const Text('Zoom Here'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              // TODO: Add to favorites
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Added to favorites!'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.favorite_border),
                            label: const Text('Save'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Marker> _buildMarkers(List<Sight> sights) {
    // Define colors for variety
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
    ];

    return sights.asMap().entries.map((entry) {
      final index = entry.key;
      final sight = entry.value;
      final color = colors[index % colors.length];

      // Highlight the selected sight if provided
      final isSelected = widget.sight != null && sight.id == widget.sight!.id;

      return Marker(
        point: LatLng(sight.latitude, sight.longitude),
        width: 80,
        height: 80,
        child: GestureDetector(
          onTap: () => _showSightDetails(sight),
          child: Column(
            children: [
              Icon(
                Icons.place,
                color: isSelected ? Colors.red : color,
                size: isSelected ? 50 : 40, // Make selected marker bigger
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.red : Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  sight.name.split(' ')[0], // Show first word
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sight != null ? widget.sight!.name : 'Sights Map'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              _mapController.move(_center, _initialZoom);
            },
          ),
        ],
      ),
      body: BlocBuilder<SightsBloc, SightsState>(
        builder: (context, state) {
          // Handle loaded state - show map with markers
          if (state is SightsLoaded) {
            final markers = _buildMarkers(state.sights);

            return Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _center,
                    initialZoom: _initialZoom,
                    minZoom: 5.0,
                    maxZoom: 18.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.tourist_guide_app',
                      maxZoom: 19,
                    ),
                    MarkerLayer(
                      markers: markers,
                    ),
                  ],
                ),

                // Floating info card
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.place,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.sight != null
                                ? 'Viewing: ${widget.sight!.name}'
                                : '${state.sights.length} sights in Zagreb',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Zoom controls on the right side
                Positioned(
                  right: 16,
                  bottom: 100,
                  child: Column(
                    children: [
                      // Zoom In Button
                      FloatingActionButton(
                        heroTag: 'zoom_in',
                        mini: true,
                        backgroundColor: Colors.white,
                        onPressed: () {
                          final currentZoom = _mapController.camera.zoom;
                          _mapController.move(
                            _mapController.camera.center,
                            currentZoom + 1,
                          );
                        },
                        child: const Icon(
                          Icons.add,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Zoom Out Button
                      FloatingActionButton(
                        heroTag: 'zoom_out',
                        mini: true,
                        backgroundColor: Colors.white,
                        onPressed: () {
                          final currentZoom = _mapController.camera.zoom;
                          _mapController.move(
                            _mapController.camera.center,
                            currentZoom - 1,
                          );
                        },
                        child: const Icon(
                          Icons.remove,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // My Location Button
                      FloatingActionButton(
                        heroTag: 'my_location',
                        mini: true,
                        backgroundColor: Colors.white,
                        onPressed: () {
                          _mapController.move(_center, _initialZoom);
                        },
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          // Loading state
          if (state is SightsLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error state
          if (state is SightsError) {
            return Center(
              child: Text('Error: ${state.message}'),
            );
          }

          // Fallback
          return const Center(
            child: Text('Unknown state'),
          );
        },
      ),
    );
  }
}