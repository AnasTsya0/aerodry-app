// Global app state — shared mutable data across screens.
// Using simple top-level variables (no provider/riverpod needed for this scope).

// ─── Device model ─────────────────────────────────────────────────────────────

class DeviceModel {
  final String name;
  final String location;

  const DeviceModel({required this.name, required this.location});
}

// ─── Device list ──────────────────────────────────────────────────────────────

/// All registered devices. Pre-seeded with 2 defaults.
List<DeviceModel> deviceList = [
  DeviceModel(name: 'House, Aero Dry', location: 'Tangerang, House'),
  DeviceModel(name: 'Boarding House, Aero Dry', location: 'Jakarta, Boarding House'),
];

/// Index of the currently active/online device.
int activeDeviceIndex = 0;

// ─── Search history ───────────────────────────────────────────────────────────

/// Persists across SearchLocationScreen opens — grows when user clicks a result.
List<String> searchHistory = [];

void addToSearchHistory(String location) {
  if (!searchHistory.contains(location)) {
    searchHistory.insert(0, location);
  }
}
