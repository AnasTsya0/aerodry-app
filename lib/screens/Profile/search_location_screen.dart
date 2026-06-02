import 'package:flutter/material.dart';
import 'package:aerodry_app/services/location_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:aerodry_app/screens/profile/location_maps_screen.dart';
import 'package:aerodry_app/constants/app_state.dart';

// Global saved addresses list shared across screens
List<String> savedAddresses = [
  'Bintaro, Jakarta City',
  'Ciledug, Tangerang City',
];

class SearchLocationScreen extends StatefulWidget {
  const SearchLocationScreen({super.key});

  @override
  State<SearchLocationScreen> createState() => _SearchLocationScreenState();
}

class _SearchLocationScreenState extends State<SearchLocationScreen> {
  bool isHistory = true;

  final TextEditingController searchController = TextEditingController();
  String searchText = '';
  List<dynamic> searchResults = [];
  String selectedLocation = '';

  /// Adds a location to the global persistent history.
  void _addToHistory(String location) {
    addToSearchHistory(location);
    // Trigger rebuild to reflect updated history
    if (mounted) setState(() {});
  }

  Future<void> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    if (!mounted) return;

    final currentLocation = await LocationService.reverseLocation(
      position.latitude,
      position.longitude,
    );

    if (!mounted) return;

    final nav = Navigator.of(context);

    final result = await nav.push(
      MaterialPageRoute(
        builder: (_) => LocationMapsScreen(
          locationName: currentLocation,
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      ),
    );

    if (result != null) {
      _addToHistory(result as String);
      nav.pop(result);
    }
  }

  void _clearSearch() {
    searchController.clear();
    setState(() {
      searchText = '';
      searchResults = [];
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Read from global persistent history
    final historyLocations = searchHistory;
    final locations = isHistory ? historyLocations : savedAddresses;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF4FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 37),
          child: Column(
            children: [
              const SizedBox(height: 30),

              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFF4C75D8),
                      size: 22,
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Locations',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0B3B7A),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 30),
                ],
              ),

              const SizedBox(height: 30),

              // ── Search bar + use current location ──
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F4F4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search,
                            size: 17,
                            color: Colors.grey,
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: TextField(
                              controller: searchController,
                              onChanged: (value) async {
                                setState(() {
                                  searchText = value;
                                });

                                if (value.isNotEmpty) {
                                  final results =
                                      await LocationService.searchLocation(value);
                                  if (mounted) {
                                    setState(() {
                                      searchResults = results;
                                    });
                                  }
                                } else {
                                  setState(() {
                                    searchResults = [];
                                  });
                                }
                              },
                              decoration: const InputDecoration(
                                isCollapsed: true,
                                border: InputBorder.none,
                                hintText: 'Search location',
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ),

                          // ── X icon to clear search ──
                          if (searchText.isNotEmpty)
                            GestureDetector(
                              onTap: _clearSearch,
                              child: const Padding(
                                padding: EdgeInsets.only(left: 6),
                                child: Icon(
                                  Icons.close,
                                  size: 17,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: getCurrentLocation,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.my_location,
                              size: 16,
                              color: Color(0xFF005DFF),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Use current location',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── History / Saved address tabs OR Search results ──
              if (searchText.isEmpty) ...[
                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(17, 12, 17, 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          _TabButton(
                            title: 'History',
                            icon: Icons.access_time,
                            active: isHistory,
                            onTap: () => setState(() => isHistory = true),
                          ),
                          const SizedBox(width: 8),
                          _TabButton(
                            title: 'Saved address',
                            icon: Icons.bookmark_border,
                            active: !isHistory,
                            onTap: () => setState(() => isHistory = false),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      if (locations.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'No locations yet',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      else
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: locations.map((location) {
                            return GestureDetector(
                              onTap: () {
                                setState(() => selectedLocation = location);
                                if (!isHistory) {
                                  _addToHistory(location);
                                }
                                Navigator.pop(context, location);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.place_rounded,
                                      size: 15,
                                      color: Color(0xFF0B4EA2),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        location,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    if (selectedLocation == location)
                                      const Icon(
                                        Icons.check_circle,
                                        size: 17,
                                        color: Color(0xFF0B4EA2),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ] else ...[
                const SizedBox(height: 12),

                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(17, 14, 17, 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        const Text(
                          'Search Results',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0B3B7A),
                          ),
                        ),

                        const SizedBox(height: 14),

                        for (final location in searchResults) ...[
                          Builder(builder: (ctx) {
                            final dName = location['display_name'] as String;
                            final lat = double.parse(location['lat'] as String);
                            final lon = double.parse(location['lon'] as String);

                            return GestureDetector(
                              onTap: () async {
                                // Record in history immediately on tap
                                _addToHistory(dName);

                                final nav = Navigator.of(ctx);
                                final result = await nav.push(
                                  MaterialPageRoute(
                                    builder: (_) => LocationMapsScreen(
                                      locationName: dName,
                                      latitude: lat,
                                      longitude: lon,
                                    ),
                                  ),
                                );
                                if (result != null) {
                                  nav.pop(result);
                                }
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF7FAFF),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFFE3ECFF),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(top: 2),
                                      child: Icon(
                                        Icons.location_on_rounded,
                                        size: 18,
                                        color: Color(0xFF0B4EA2),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            dName.split(',').first,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF0B3B7A),
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            dName,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              height: 1.3,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF5E6D83),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _TabButton({
    required this.title,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF0B4EA2);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 22,
        padding: const EdgeInsets.symmetric(horizontal: 11),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFD6E7FF) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: blue, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, size: 13, color: blue),
            const SizedBox(width: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                color: blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
